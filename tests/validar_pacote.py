"""Validação local do pacote, sem dependência de AWS ou PySpark."""

import ast
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DELIVERABLE = ROOT / "entregavel_3"

required = [
    DELIVERABLE / "README.md",
    DELIVERABLE / "glue" / "processamento_consolidado.py",
    DELIVERABLE / "athena" / "analises_executivas.sql",
    DELIVERABLE / "notebooks" / "01_ingestao_tratamento_catalogacao_glue.ipynb",
    DELIVERABLE / "notebooks" / "02_transformacoes_sot_spec_athena.ipynb",
    DELIVERABLE / "notebooks" / "03_consultas_analiticas_athena.ipynb",
    DELIVERABLE / "notebooks" / "04_geracao_dados_e_graficos_pyspark.ipynb",
    DELIVERABLE / "docs" / "METODOLOGIA.md",
    DELIVERABLE / "docs" / "CHECKLIST_EXECUCAO.md",
    DELIVERABLE / "docs" / "GUIA_PASSO_A_PASSO.md",
    DELIVERABLE / "docs" / "MATRIZ_CONFORMIDADE.md",
]

missing = [str(path.relative_to(ROOT)) for path in required if not path.exists()]
assert not missing, f"Arquivos obrigatórios ausentes: {missing}"

transformations = sorted((DELIVERABLE / "athena" / "transformacoes").glob("camada_*.sql"))
original_jobs = sorted((DELIVERABLE / "glue" / "jobs_originais").glob("processamento_dados_*.py"))
assert len(transformations) == 6, f"Esperados 6 SQLs SOT/SPEC, encontrados {len(transformations)}"
assert len(original_jobs) == 3, f"Esperados 3 jobs anuais, encontrados {len(original_jobs)}"

for script in list((ROOT / "Glue ").glob("*.py")) + list((DELIVERABLE / "glue").glob("*.py")):
    ast.parse(script.read_text(encoding="utf-8"), filename=str(script))

for notebook_path in (DELIVERABLE / "notebooks").glob("*.ipynb"):
    notebook = json.loads(notebook_path.read_text(encoding="utf-8"))
    assert notebook["nbformat"] == 4
    if notebook["metadata"]["language_info"]["name"] == "python":
        for number, cell in enumerate(notebook["cells"]):
            if cell["cell_type"] == "code":
                ast.parse("".join(cell["source"]), filename=f"{notebook_path.name}_cell_{number}")
    assert any(cell["cell_type"] == "code" for cell in notebook["cells"]), \
        f"Notebook sem código: {notebook_path.name}"

notebook_names = sorted(path.name for path in (DELIVERABLE / "notebooks").glob("*.ipynb"))
assert len(notebook_names) == 4, f"Esperados 4 notebooks, encontrados: {notebook_names}"

combined = "\n".join(path.read_text(encoding="utf-8").lower()
                     for path in (DELIVERABLE / "notebooks").glob("*.ipynb"))
for stage in ("ingestão", "tratamento", "transformações", "catalogação", "consultas analíticas", "gráficos"):
    assert stage in combined, f"Etapa não documentada nos notebooks: {stage}"

sql = (DELIVERABLE / "athena" / "analises_executivas.sql").read_text(encoding="utf-8").lower()
for required_term in ("create or replace view", "group by", "count_if", "unnest"):
    assert required_term in sql, f"Construção SQL ausente: {required_term}"

all_text = "\n".join(path.read_text(encoding="utf-8", errors="ignore")
                     for path in DELIVERABLE.rglob("*") if path.is_file())
for secret_marker in ("aws_" + "access_key_id", "aws_" + "secret_access_key", "aws_" + "session_token"):
    assert secret_marker not in all_text.lower(), f"Possível credencial encontrada: {secret_marker}"

print("Pacote válido: arquivos, Python, Notebook e construções SQL conferidos.")
