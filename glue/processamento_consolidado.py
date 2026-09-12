"""AWS Glue Job - ingestão, limpeza técnica e catalogação das pesquisas.

Parâmetros obrigatórios: --JOB_NAME e --ANO.
Parâmetros opcionais: --BUCKET e --DATABASE.
"""

import sys

from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql import functions as F


def optional_arg(name, default):
    flag = f"--{name}"
    return sys.argv[sys.argv.index(flag) + 1] if flag in sys.argv else default


def safe_col(name):
    """Referencia colunas com pontos, aspas ou acentos sem alterar o nome original."""
    return F.col(f"`{name.replace('`', '``')}`")


args = getResolvedOptions(sys.argv, ["JOB_NAME", "ANO"])
year = args["ANO"]
if year not in {"2023", "2024", "2025"}:
    raise ValueError("ANO deve ser 2023, 2024 ou 2025")

bucket = optional_arg("BUCKET", "tech-challenge-018298043465")
database = optional_arg("DATABASE", "tech_challenge_db")
source_path = f"s3://{bucket}/bases_origem_pesquisas/{year}/"
target_path = f"s3://{bucket}/bases_finais_pesquisa/{year}/"
table_name = f"pesquisas_{year}"

sc = SparkContext.getOrCreate()
glue_context = GlueContext(sc)
spark = glue_context.spark_session
job = Job(glue_context)
job.init(args["JOB_NAME"], args)

raw = (
    spark.read.option("header", True)
    .option("quote", '"')
    .option("escape", '"')
    .option("multiLine", True)
    .option("mode", "PERMISSIVE")
    .csv(source_path)
)

raw_count = raw.count()
if raw_count == 0 or not raw.columns:
    raise ValueError(f"Base {year} vazia em {source_path}")

# Os nomes originais são preservados porque os SQLs SOT do grupo os utilizam.
# Espaços e strings vazias são normalizados; colunas não textuais são preservadas.
types = dict(raw.dtypes)
clean = raw.select(
    *[
        F.when(F.trim(safe_col(c)) == "", None).otherwise(F.trim(safe_col(c))).alias(c)
        if types[c] == "string"
        else safe_col(c).alias(c)
        for c in raw.columns
    ]
)

# Uma única agregação verifica todas as colunas, evitando centenas de varreduras no S3.
non_null_counts = clean.agg(
    *[F.count(safe_col(c)).alias(f"nn_{i}") for i, c in enumerate(clean.columns)]
).first().asDict()
all_null_columns = [
    c for i, c in enumerate(clean.columns) if non_null_counts[f"nn_{i}"] == 0
]
if len(all_null_columns) == len(clean.columns):
    raise ValueError(f"Todas as colunas da base {year} estão vazias")

# A primeira coluna é a chave/t token nas três pesquisas. Mantemos um fallback seguro.
key_column = clean.columns[0]
key_stats = clean.agg(
    F.count("*").alias("rows"),
    F.count(safe_col(key_column)).alias("non_null_keys"),
    F.countDistinct(safe_col(key_column)).alias("distinct_keys"),
).first()
key_is_usable = key_stats["rows"] == key_stats["non_null_keys"]
deduplicated = clean.dropDuplicates([key_column]) if key_is_usable else clean.dropDuplicates()

result = (
    deduplicated.withColumn("ano_pesquisa", F.lit(int(year)))
    .withColumn("data_processamento", F.current_timestamp())
    .withColumn("arquivo_origem", F.input_file_name())
)
result_count = result.count()

print(
    {
        "ano": year,
        "origem": source_path,
        "destino": target_path,
        "linhas_lidas": raw_count,
        "linhas_gravadas": result_count,
        "duplicidades_removidas": raw_count - result_count,
        "quantidade_colunas": len(result.columns),
        "chave_deduplicacao": key_column if key_is_usable else "linha_completa",
        "chaves_distintas": key_stats["distinct_keys"],
        "colunas_totalmente_nulas": all_null_columns,
    }
)

dynamic_frame = DynamicFrame.fromDF(result, glue_context, f"state_of_data_{year}")
sink = glue_context.getSink(
    path=target_path,
    connection_type="s3",
    updateBehavior="UPDATE_IN_DATABASE",
    partitionKeys=[],
    enableUpdateCatalog=True,
    transformation_ctx=f"sink_{year}",
)
sink.setCatalogInfo(catalogDatabase=database, catalogTableName=table_name)
sink.setFormat("glueparquet")
sink.writeFrame(dynamic_frame)

job.commit()
