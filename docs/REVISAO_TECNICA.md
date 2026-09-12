# Revisão técnica aplicada

O trabalho original do grupo foi preservado e complementado. As seguintes correções foram aplicadas na cópia de trabalho:

1. Remoção de um parêntese excedente em `processamento_dados_2023.py`, que impedia a compilação.
2. Correção do mapeamento de modelo de trabalho, trabalho ideal, layoff e retorno presencial na SPEC de 2024.
3. Correção dos aliases de motivos de insatisfação na SPEC de 2025.
4. Padronização dos aliases de linguagens, clouds e BI em 2025 para comparação entre anos.
5. Criação de um Glue Job consolidado com parâmetros, deduplicação, limpeza e auditoria.
6. Inclusão de consultas analíticas, controles de qualidade e Notebook consolidado.
7. Substituição do Notebook 01 baseado em argumentos de Job por um Notebook Glue realmente interativo.
8. Separação das consultas analíticas em um Notebook SQL próprio, com 18 blocos executáveis.
9. Correção do alias `cloud_preferida` de 2024, que estava incorretamente nomeado como Power BI.
10. Inclusão de quatro exemplos de gráficos diretamente ligados aos agregados exportados.

## Atenções antes da execução

Os SQLs CTAS escrevem em caminhos fixos. Se as tabelas já tiverem sido criadas, `DROP TABLE` não remove os arquivos Parquet. Para reprocessar, limpe somente a pasta específica do ano e da camada, após confirmar o caminho.

O job consolidado preserva os nomes originais das colunas porque os SQLs SOT dependem deles. A padronização de nomes ocorre nas consultas SOT/SPEC, mantendo compatibilidade com o fluxo que o grupo já executou.

Como as bases estão no AWS Academy, a validação local garante estrutura e sintaxe Python/Notebook; a validação dos números deve ser concluída com os logs e resultados do Athena.
