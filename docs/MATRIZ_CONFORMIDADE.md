# Matriz de conformidade — Item 3

| Exigência | Onde é atendida | O que comprova | Situação |
|---|---|---|---|
| Scripts, notebooks e códigos organizados | `entregavel_3/README.md` e quatro notebooks numerados | Estrutura, ordem e finalidade documentadas | Pronto |
| Uso de Notebook | `notebooks/01` a `04` | Arquivos `.ipynb` com células reais de código | Pronto |
| Spark/PySpark | Notebooks `01` e `04` | Leitura, transformação, qualidade, agregação e escrita distribuída | Pronto em código; execução AWS pendente |
| SQL | Notebooks `02` e `03` | Seis CTAS SOT/SPEC e 18 consultas Athena | Pronto em código; execução Athena pendente |
| Ingestão | Notebook `01`, seção 2/3 | Leitura dos CSVs no S3 para 2023–2025 | Pronto em código; dados AWS pendentes |
| Tratamento | Notebook `01`, seção 2/3 | Trim, vazio para nulo, verificação de colunas vazias e deduplicação | Pronto em código; métricas reais pendentes |
| Transformação | Notebook `02` | SOT/Silver e SPEC/Gold para os três anos | Pronto em código; tabelas reais pendentes |
| Catalogação | Notebook `01`, seção 4/5 | `getSink`, `setCatalogInfo` e releitura pelo catálogo | Pronto em código; catálogo AWS pendente |
| Consultas analíticas | Notebook `03` | 18 blocos sobre mercado, diversidade, salário, tecnologia e IA | Pronto em código; resultados reais pendentes |
| Dados usados nas análises | Notebooks `03` e `04` | Resultados SQL e agregados Parquet com base e percentual | Pronto em código; exportações AWS pendentes |
| Dados usados nos gráficos | Notebook `04`, seções 7/8 | Escrita em `analises_executivas/` e função de gráficos | Pronto em código; reconciliação pendente |
| Qualidade e rastreabilidade | Notebooks `01`, `03`, `04`; metodologia e checklist | Contagens, nulos, duplicidades, base amostral e origem | Pronto em código; evidências pendentes |

## Interpretação da situação

“Pronto em código” significa que a implementação está presente e passou por validação estrutural/sintática local. “Execução pendente” significa que somente a conta AWS Academy do grupo pode comprovar que caminhos, permissões, esquemas e resultados funcionam com os dados reais.

## Critério para considerar o item 3 totalmente concluído

O item só deve ser marcado como 100% concluído quando todas as linhas com pendência tiverem evidência: execução bem-sucedida, tabelas no catálogo, arquivos no S3, resultados no Athena e números reconciliados com os gráficos.
