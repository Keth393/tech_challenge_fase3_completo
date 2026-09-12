"""Gera os Notebooks 01, 02 e 03 a partir dos códigos versionados."""

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DELIVERABLE = ROOT / "entregavel_3"
NOTEBOOKS = DELIVERABLE / "notebooks"


def markdown(text):
    return {"cell_type": "markdown", "metadata": {}, "source": text.splitlines(keepends=True)}


def code(text):
    return {"cell_type": "code", "execution_count": None, "metadata": {}, "outputs": [],
            "source": text.splitlines(keepends=True)}


def write_notebook(path, cells, language="python", kernel="python3", display="Python 3"):
    payload = {
        "cells": cells,
        "metadata": {"kernelspec": {"display_name": display, "language": language, "name": kernel},
                     "language_info": {"name": language}},
        "nbformat": 4,
        "nbformat_minor": 5,
    }
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")


def build_ingestion_notebook():
    cells = [
        markdown(
            "# Notebook 01 — Ingestão, tratamento e catalogação\n\n"
            "**Ambiente:** AWS Glue Studio Notebook (PySpark).  \n"
            "**Entrada:** CSVs da camada Bronze no S3.  \n"
            "**Saída:** Parquet na Silver e tabelas no Glue Data Catalog.\n\n"
            "Este notebook é interativo e não depende de argumentos de Glue Job. "
            "Altere somente a configuração abaixo e execute as células em ordem."
        ),
        markdown("## 1. Configuração do ambiente"),
        code(
            "from awsglue.context import GlueContext\n"
            "from awsglue.dynamicframe import DynamicFrame\n"
            "from pyspark.context import SparkContext\n"
            "from pyspark.sql import functions as F\n\n"
            "BUCKET = 'tech-challenge-018298043465'\n"
            "DATABASE = 'tech_challenge_db'\n"
            "YEARS = [2023, 2024, 2025]\n\n"
            "sc = SparkContext.getOrCreate()\n"
            "glue_context = GlueContext(sc)\n"
            "spark = glue_context.spark_session\n"
            "print({'bucket': BUCKET, 'database': DATABASE, 'anos': YEARS})"
        ),
        markdown(
            "## 2. Funções de ingestão e tratamento\n\n"
            "Os nomes originais são preservados porque os SQLs SOT dependem deles. "
            "O tratamento remove espaços, converte texto vazio em nulo, identifica colunas "
            "totalmente vazias e elimina duplicidades."
        ),
        code(
            "def safe_col(name):\n"
            "    return F.col(f\"`{name.replace('`', '``')}`\")\n\n"
            "def read_bronze(year):\n"
            "    path = f's3://{BUCKET}/bases_origem_pesquisas/{year}/'\n"
            "    return (spark.read.option('header', True).option('quote', '\"')\n"
            "            .option('escape', '\"').option('multiLine', True)\n"
            "            .option('mode', 'PERMISSIVE').csv(path)\n"
            "            .withColumn('_arquivo_origem', F.input_file_name()))\n\n"
            "def clean_dataframe(raw, year):\n"
            "    if not raw.columns:\n"
            "        raise ValueError(f'Base {year} sem colunas')\n"
            "    types = dict(raw.dtypes)\n"
            "    clean = raw.select(*[(F.when(F.trim(safe_col(c)) == '', None)\n"
            "        .otherwise(F.trim(safe_col(c))).alias(c)\n"
            "        if types[c] == 'string' and c != '_arquivo_origem' else safe_col(c).alias(c))\n"
            "        for c in raw.columns])\n"
            "    business = [c for c in clean.columns if not c.startswith('_')]\n"
            "    counts = clean.agg(*[F.count(safe_col(c)).alias(f'nn_{i}')\n"
            "                         for i, c in enumerate(business)]).first().asDict()\n"
            "    all_null = [c for i, c in enumerate(business) if counts[f'nn_{i}'] == 0]\n"
            "    if len(all_null) == len(business):\n"
            "        raise ValueError(f'Todas as colunas da base {year} estão vazias')\n"
            "    key = business[0]\n"
            "    stats = clean.agg(F.count('*').alias('rows'), F.count(safe_col(key)).alias('keys'),\n"
            "                      F.countDistinct(safe_col(key)).alias('distinct_keys')).first()\n"
            "    dedup = clean.dropDuplicates([key]) if stats['rows'] == stats['keys'] else clean.dropDuplicates()\n"
            "    result = (dedup.withColumn('ano_pesquisa', F.lit(int(year)))\n"
            "              .withColumn('data_processamento', F.current_timestamp()))\n"
            "    result_count = result.count()\n"
            "    metrics = {'ano': year, 'linhas_lidas': stats['rows'], 'linhas_gravadas': result_count,\n"
            "               'duplicidades_removidas': stats['rows'] - result_count, 'chave': key,\n"
            "               'chaves_distintas': stats['distinct_keys'], 'colunas_totalmente_nulas': all_null}\n"
            "    return result, metrics"
        ),
        markdown("## 3. Processamento dos três anos e controle de qualidade"),
        code(
            "processed, quality_log = {}, []\n"
            "for year in YEARS:\n"
            "    raw = read_bronze(year)\n"
            "    if raw.limit(1).count() == 0:\n"
            "        raise ValueError(f'Base {year} vazia no S3')\n"
            "    result, metrics = clean_dataframe(raw, year)\n"
            "    processed[year] = result\n"
            "    quality_log.append(metrics)\n"
            "    print(metrics)\n"
            "    result.select('ano_pesquisa', '_arquivo_origem').show(3, truncate=False)"
        ),
        markdown(
            "## 4. Escrita em Parquet e catalogação\n\n"
            "O sink do Glue atualiza o Data Catalog e cria `pesquisas_2023`, "
            "`pesquisas_2024` e `pesquisas_2025`."
        ),
        code(
            "for year, dataframe in processed.items():\n"
            "    target = f's3://{BUCKET}/bases_finais_pesquisa/{year}/'\n"
            "    table = f'pesquisas_{year}'\n"
            "    dyf = DynamicFrame.fromDF(dataframe, glue_context, f'dyf_{year}')\n"
            "    sink = glue_context.getSink(path=target, connection_type='s3',\n"
            "        updateBehavior='UPDATE_IN_DATABASE', partitionKeys=[],\n"
            "        enableUpdateCatalog=True, transformation_ctx=f'sink_{year}')\n"
            "    sink.setCatalogInfo(catalogDatabase=DATABASE, catalogTableName=table)\n"
            "    sink.setFormat('glueparquet')\n"
            "    sink.writeFrame(dyf)\n"
            "    print(f'Catalogado: {DATABASE}.{table} -> {target}')"
        ),
        markdown("## 5. Verificação final e evidência"),
        code(
            "for year in YEARS:\n"
            "    table = f'{DATABASE}.pesquisas_{year}'\n"
            "    check = spark.table(table)\n"
            "    print(table, check.count(), 'linhas', len(check.columns), 'colunas')\n"
            "spark.createDataFrame(quality_log).orderBy('ano').show(truncate=False)"
        ),
        markdown(
            "## Resultado esperado\n\n"
            "Os CSVs foram lidos da Bronze, tratados, convertidos para Parquet e catalogados. "
            "Guarde prints desta célula e do histórico de execução."
        ),
    ]
    write_notebook(NOTEBOOKS / "01_ingestao_tratamento_catalogacao_glue.ipynb", cells,
                   "python", "pyspark", "PySpark — AWS Glue")


def build_transformations_notebook():
    cells = [markdown(
        "# Notebook 02 — Transformações SOT/Silver e SPEC/Gold\n\n"
        "**Ambiente:** Amazon Athena; execute uma célula SQL por vez.  \n"
        "**Entrada:** tabelas `pesquisas_<ano>` do Glue Catalog.  \n"
        "**Saída:** tabelas SOT e SPEC em Parquet no S3.\n\n"
        "SOT padroniza nomes técnicos; SPEC atribui nomes de negócio. Antes de repetir um CTAS, "
        "remova a tabela e limpe somente a pasta S3 daquela camada e ano."
    )]
    for year in (2023, 2024, 2025):
        for layer in ("sot", "spec"):
            filename = f"camada_{layer}_{year}.sql"
            sql = (DELIVERABLE / "athena" / "transformacoes" / filename).read_text(encoding="utf-8")
            label = "SOT / Silver" if layer == "sot" else "SPEC / Gold"
            cells.extend([markdown(f"## {year} — {label}\n\nCódigo integral de `{filename}`."), code(sql)])
    write_notebook(NOTEBOOKS / "02_transformacoes_sot_spec_athena.ipynb", cells,
                   "sql", "sql", "SQL — Amazon Athena")


def build_analytics_notebook():
    source = (DELIVERABLE / "athena" / "analises_executivas.sql").read_text(encoding="utf-8")
    matches = list(re.finditer(r"(?m)^-- (\d+)\) (.+)$", source))
    cells = [markdown(
        "# Notebook 03 — Consultas analíticas no Athena\n\n"
        "**Ambiente:** Amazon Athena; execute os blocos em ordem.  \n"
        "**Entrada:** tabelas SPEC/Gold.  \n"
        "**Saída:** resultados usados nas análises e gráficos.\n\n"
        "A consulta 1 cria a visão harmonizada. As demais apresentam quantidade, percentual "
        "e/ou base amostral. Exporte os resultados ou preserve o histórico do Athena."
    )]
    for index, match in enumerate(matches):
        end = matches[index + 1].start() if index + 1 < len(matches) else len(source)
        block = source[match.start():end].strip() + "\n"
        cells.extend([markdown(f"## Consulta {match.group(1)} — {match.group(2)}"), code(block)])
    write_notebook(NOTEBOOKS / "03_consultas_analiticas_athena.ipynb", cells,
                   "sql", "sql", "SQL — Amazon Athena")


if __name__ == "__main__":
    NOTEBOOKS.mkdir(parents=True, exist_ok=True)
    build_ingestion_notebook()
    build_transformations_notebook()
    build_analytics_notebook()
    print("Notebooks 01, 02 e 03 gerados com sucesso.")
