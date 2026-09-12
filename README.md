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

### SPEC — camada específica para análise

A SPEC é a camada final, criada a partir da SOT.

Os arquivos `camada_spec_2023.sql`, `camada_spec_2024.sql` e `camada_spec_2025.sql`:

- leem as tabelas SOT;
- transformam os nomes técnicos em nomes de negócio mais claros;
- organizam os dados para consultas, análises e gráficos;
- geram a camada final de consumo.

Ela pode ser entendida como a camada analítica, equivalente à **Gold**.

## Ordem de execução

Para cada ano, a ordem correta é:

1. Executar o código correspondente da pasta `glue/`.
2. Executar `camada_sot_<ano>.sql`.
3. Executar `camada_spec_<ano>.sql`.
4. Consultar os resultados no Amazon Athena.

Exemplo para 2023:

`Glue 2023 → SOT 2023 → SPEC 2023 → análise no Athena`

## Observação

Os códigos não armazenam credenciais da AWS. A execução deve ser realizada no ambiente AWS Academy do grupo.
