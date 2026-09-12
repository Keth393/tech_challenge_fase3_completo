# Tech Challenge — Fase 3

Projeto de Engenharia de Dados desenvolvido para analisar as pesquisas **State of Data Brasil de 2023, 2024 e 2025**.

A solução utiliza Amazon S3, AWS Glue, PySpark, Glue Data Catalog e Amazon Athena para organizar e transformar os dados.

## Estrutura do repositório

- `docs/`: diagrama da arquitetura e gráficos do projeto.
- `glue/`: códigos PySpark responsáveis pela leitura dos arquivos no S3, conversão para Parquet e catalogação dos dados.
- `scripts/`: códigos SQL das camadas SOT e SPEC para 2023, 2024 e 2025.

## Fluxo dos dados

1. Os arquivos CSV originais são armazenados no Amazon S3.
2. Os scripts do AWS Glue leem os arquivos e geram dados em formato Parquet.
3. A camada SOT padroniza tecnicamente as colunas.
4. A camada SPEC prepara os campos para consultas e análises.
5. Os dados tratados são consultados no Amazon Athena e utilizados nos gráficos.

## O que são SOT e SPEC?

### SOT — Source of Truth

A SOT é a camada intermediária e funciona como uma **fonte de verdade técnica**.

Os arquivos `camada_sot_2023.sql`, `camada_sot_2024.sql` e `camada_sot_2025.sql`:

- leem as tabelas criadas pelo Glue;
- selecionam os campos necessários;
- substituem nomes extensos e complexos por nomes técnicos padronizados;
- gravam os resultados em Parquet.

Ela pode ser entendida como a camada de padronização, equivalente à **Silver**.
