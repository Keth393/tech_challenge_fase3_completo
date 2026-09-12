# Entregável 3 - Scripts e códigos utilizados

Este diretório consolida os códigos do Tech Challenge - Fase 3. A solução processa as pesquisas State of Data Brasil de 2023, 2024 e 2025 no AWS Academy, usando Amazon S3, AWS Glue, Spark/PySpark, Glue Data Catalog e Amazon Athena.

## Arquitetura de dados

| Camada lógica | Local do projeto | Finalidade |
|---|---|---|
| Bronze | `bases_origem_pesquisas/<ano>/` | CSV original, preservado sem alteração |
| Silver | `bases_finais_pesquisa/<ano>/` e `camada_sot/<ano>/` | Parquet, limpeza técnica e padronização de nomes/tipos |
| Gold | `camada_spec/<ano>/` | Campos de negócio com nomes legíveis para consumo analítico |

O banco do Glue Data Catalog/Athena é `tech_challenge_db` e o bucket usado pelo grupo é `tech-challenge-018298043465`.

## Conteúdo

- `notebooks/01_ingestao_tratamento_catalogacao_glue.ipynb`: ingestão, limpeza, deduplicação, Parquet e catalogação.
- `notebooks/02_transformacoes_sot_spec_athena.ipynb`: códigos completos das camadas SOT/Silver e SPEC/Gold para os três anos.
- `notebooks/03_consultas_analiticas_athena.ipynb`: 18 consultas SQL reproduzíveis, incluindo a visão harmonizada e controles de qualidade.
- `notebooks/04_geracao_dados_e_graficos_pyspark.ipynb`: agregações PySpark, exportação dos dados analíticos e gráficos reproduzíveis.
- `glue/processamento_consolidado.py`: job parametrizado para os três anos; substitui a repetição dos jobs anuais e inclui limpeza e auditoria.
- `glue/jobs_originais/`: cópia dos três jobs anuais efetivamente produzidos pelo grupo, com a correção de sintaxe de 2023.
- `athena/analises_executivas.sql`: 18 blocos SQL que geram os conjuntos usados nas análises e gráficos.
- `athena/transformacoes/`: cópia consolidada dos seis SQLs SOT/SPEC também incorporados ao Notebook 02.
- `docs/METODOLOGIA.md`: critérios de comparabilidade, qualidade, remuneração e limitações.
- `docs/CHECKLIST_EXECUCAO.md`: passos e prints que comprovam a execução na AWS.
- `docs/REVISAO_TECNICA.md`: correções aplicadas e pontos de atenção.
- `docs/GUIA_PASSO_A_PASSO.md`: explicação para executar e comprovar cada etapa.
- `docs/MATRIZ_CONFORMIDADE.md`: relação direta entre cada exigência do item 3 e o código que a atende.
- `tests/validar_pacote.py`: validação local do pacote sem acessar a AWS.
- Os SQLs `camada_sot_*.sql` e `camada_spec_*.sql` permanecem nas pastas originais do repositório, pois contêm o mapeamento completo das perguntas de cada pesquisa.

## Ordem de execução na AWS

1. Confirmar os CSVs em `s3://tech-challenge-018298043465/bases_origem_pesquisas/<ano>/`.
2. No Glue Studio Notebook, executar o Notebook `01` para os três anos. Como alternativa operacional, executar `glue/processamento_consolidado.py` três vezes com `--ANO`.
3. No Athena, executar as células do Notebook `02`: primeiro SOT e depois SPEC para 2023, 2024 e 2025.
4. No Athena, executar as células do Notebook `03`. A consulta 1 cria a view harmonizada.
5. No Glue Studio Notebook, executar o Notebook `04` para gerar os agregados em Parquet e os gráficos.
6. Preencher o checklist e guardar prints/logs como evidência.

## Arquivos principais para entregar

Os quatro arquivos `.ipynb` da pasta `notebooks/` são o núcleo do entregável. Os `.py` e `.sql` são versões auxiliares para copiar diretamente em Glue Jobs e no editor do Athena.

## Parâmetros do Glue Job

```text
--JOB_NAME processamento-state-of-data
--ANO 2023
--BUCKET tech-challenge-018298043465
--DATABASE tech_challenge_db
```

## Controles de qualidade

O job registra no log:

- quantidade de linhas lidas e gravadas;
- quantidade de colunas;
- duplicidades removidas;
- colunas totalmente nulas;
- ano processado e instante do processamento.

O job interrompe a execução quando o ano é inválido, a base está vazia ou todas as colunas são vazias. A chave técnica é identificada entre `p0_id`, `id` e `token`; se nenhuma existir, a remoção de duplicidades considera a linha completa.

## Observações para reaplicação

- As consultas CTAS das camadas SOT e SPEC escrevem em caminhos fixos do S3. Antes de reexecutá-las, exclua a tabela anterior no Athena e limpe somente a pasta específica daquele ano.
- O AWS Academy pode encerrar a sessão e alterar credenciais temporárias; os códigos não armazenam chaves de acesso.
- As comparações entre anos respeitam mudanças no questionário. Indicadores de IA usam 2024 e 2025; resultados com LLMs estão disponíveis apenas em 2025.
- Salários são estimados pelo ponto médio das faixas e devem ser apresentados como aproximação, não como salário individual exato.

## Cobertura analítica

O pacote produz dados para estrutura do mercado, cargos, senioridade, setores, modelo de trabalho, diversidade de gênero, participação feminina por cargo e nível, distribuição regional, linguagens, cloud, ferramentas de BI, remuneração, prioridade de IA, resultados com LLMs e barreiras de adoção. Cada análise apresenta quantidade ou base amostral para apoiar uma leitura responsável.

## Evidência recomendada para a entrega

Salve prints do histórico de execução dos três Glue Jobs, das tabelas no Glue Data Catalog, das consultas concluídas no Athena e das três pastas no S3. Esses prints demonstram que os códigos deste diretório foram executados no ambiente obrigatório.

## Situação atual

O pacote de código está estruturado e passou por validação estática local. A execução ponta a ponta e a validação dos números dependem da sessão AWS Academy, dos CSVs no bucket e das permissões do grupo. Enquanto os notebooks não forem executados nesse ambiente e os resultados não forem comparados aos gráficos, essa parte deve ser marcada como **pendente**, não como concluída.
