# Guia passo a passo do Entregável 3

## O que o item 3 pede

O item 3 não é um relatório narrativo isolado. Ele pede a entrega organizada dos códigos que comprovam todo o caminho dos dados: ingestão, tratamento, transformação, catalogação, consultas analíticas e geração dos dados usados nos gráficos. Por isso, o núcleo deste pacote são quatro notebooks numerados na ordem de execução.

## Antes de começar

É necessário ter:

1. sessão ativa no AWS Academy;
2. bucket S3 do grupo acessível;
3. CSVs de 2023, 2024 e 2025 em `bases_origem_pesquisas/<ano>/`;
4. função IAM do Glue com acesso ao S3 e ao Glue Data Catalog;
5. banco `tech_challenge_db` criado;
6. pasta de resultados do Athena configurada.

Se o bucket ou banco tiver outro nome, altere as células de configuração dos Notebooks 01 e 04 e os caminhos `external_location` do Notebook 02.

## Passo 1 — Ingestão, tratamento e catalogação

Abra `01_ingestao_tratamento_catalogacao_glue.ipynb` no AWS Glue Studio Notebook.

O que ele faz:

1. inicia Spark e Glue;
2. lê os três CSVs da camada Bronze no S3;
3. preserva os nomes originais usados nos SQLs seguintes;
4. remove espaços nas extremidades e converte strings vazias em nulo;
5. identifica colunas totalmente vazias;
6. remove duplicidades pela primeira coluna quando ela é uma chave válida, com fallback para linha completa;
7. acrescenta ano, data de processamento e arquivo de origem;
8. grava Parquet na camada Silver;
9. registra as tabelas `pesquisas_2023`, `pesquisas_2024` e `pesquisas_2025` no Glue Data Catalog;
10. relê as tabelas catalogadas e mostra contagens para validação.

Evidências a guardar: log de métricas, três mensagens “Catalogado”, contagem final das tabelas, histórico verde do Notebook/Job e pastas Parquet no S3.

## Passo 2 — Transformações SOT e SPEC

Abra `02_transformacoes_sot_spec_athena.ipynb`. Copie/execute cada célula no Amazon Athena, na ordem apresentada.

Para cada ano:

1. execute SOT, que converte os nomes extensos do questionário em nomes técnicos;
2. execute SPEC, que converte os nomes técnicos em conceitos de negócio;
3. confira se a tabela criada possui linhas;
4. confirme a pasta Parquet correspondente no S3.

SOT funciona como padronização técnica da Silver. SPEC funciona como Gold, pronta para análises. São seis transformações no total: SOT e SPEC para 2023, 2024 e 2025.

Importante: consultas CTAS não sobrescrevem automaticamente um caminho que já contém arquivos. Para reprocessar, remova a tabela e limpe somente a pasta exata da camada/ano, depois de confirmar o caminho.

## Passo 3 — Consultas analíticas

Abra `03_consultas_analiticas_athena.ipynb` e execute os 18 blocos em ordem no Athena.

A primeira consulta cria `vw_mercado_dados`, unindo apenas dimensões comparáveis dos três anos. As demais geram resultados para:

- volume de respondentes;
- cargos e senioridade;
- setores e modelo de trabalho;
- gênero e participação feminina;
- regiões;
- linguagens e nuvens;
- remuneração estimada;
- ferramentas de BI;
- prioridade, resultados e barreiras de IA;
- controle final de nulos e tamanho amostral.

Evidências a guardar: histórico “Succeeded”, ID das consultas e CSVs de resultados das análises utilizadas na apresentação.

## Passo 4 — Dados dos gráficos e visualizações

Abra `04_geracao_dados_e_graficos_pyspark.ipynb` no Glue Studio Notebook.

O notebook:

1. lê as tabelas SPEC/Gold;
2. harmoniza os campos comparáveis;
3. calcula controles de qualidade;
4. cria agregados com quantidade, percentual e base amostral;
5. estima remuneração pelo ponto médio das faixas;
6. calcula adoção tecnológica e prioridade de IA;
7. grava cada conjunto em `analises_executivas/<nome>/` no S3;
8. produz exemplos reproduzíveis de gráficos de cargos, senioridade, regiões e tecnologias.

Somente agregados pequenos são convertidos para Pandas. A base completa permanece no Spark.

## Passo 5 — Conferência antes da entrega

1. execute `python entregavel_3/tests/validar_pacote.py` localmente ou no Codespace;
2. preencha `CHECKLIST_EXECUCAO.md`;
3. compare os números exportados com os gráficos do grupo;
4. inclua as evidências da AWS no relatório ou apresentação;
5. suba a pasta `entregavel_3` e os códigos originais no GitHub do grupo.

## O que está pronto e o que ainda depende do grupo

Pronto no pacote:

- quatro notebooks com código de PySpark e SQL;
- seis transformações SOT/SPEC completas;
- job Glue consolidado auxiliar;
- 18 consultas analíticas;
- código para exportar agregados e criar gráficos;
- metodologia, revisão, checklist e validação estática.

Ainda precisa ser feito no ambiente do grupo:

- executar os notebooks na AWS Academy;
- confirmar nomes reais do bucket, banco, tabelas e colunas;
- salvar logs, prints e IDs de execução;
- comparar os resultados numéricos com os gráficos já produzidos;
- ajustar qualquer diferença revelada pelos dados reais;
- enviar o link/ZIP conforme orientação da plataforma da disciplina.

Sem a execução na AWS não é correto afirmar que o pipeline foi validado ponta a ponta. O código está preparado, mas a evidência operacional permanece pendente.
