# Checklist de execução e evidências

## Antes de executar

- [ ] AWS Academy Lab iniciado.
- [ ] Região AWS confirmada.
- [ ] Bucket `tech-challenge-018298043465` disponível.
- [ ] CSVs 2023, 2024 e 2025 nas pastas de origem.
- [ ] Role do Glue com leitura e escrita no bucket e acesso ao catálogo.
- [ ] Resultado do Athena configurado em uma pasta exclusiva do S3.

## Pipeline

- [ ] Glue Job executado para 2023.
- [ ] Glue Job executado para 2024.
- [ ] Glue Job executado para 2025.
- [ ] Log de cada execução salvo.
- [ ] Tabelas `pesquisas_2023`, `pesquisas_2024` e `pesquisas_2025` no catálogo.
- [ ] SQLs SOT executados para os três anos.
- [ ] SQLs SPEC executados para os três anos.
- [ ] View `vw_mercado_dados` criada.

## Validação

- [ ] Total de linhas comparado com as bases originais.
- [ ] IDs distintos comparados com o total de linhas.
- [ ] Nulos das dimensões centrais registrados.
- [ ] Recortes abaixo de 20 respostas sinalizados.
- [ ] Percentuais de cada distribuição conferidos.
- [ ] Gráficos reconciliados com as consultas do Athena.

## Prints recomendados

1. Estrutura do bucket e das camadas no S3.
2. Histórico verde dos três Glue Jobs.
3. Tabelas no Glue Data Catalog.
4. Consulta da view no Athena com resultado.
5. Consulta de qualidade por ano.
6. Saída de pelo menos uma análise usada no material executivo.

## Entrega

- [ ] Notebook abre sem erro de JSON.
- [ ] Scripts não contêm credenciais.
- [ ] README apresenta a ordem de execução.
- [ ] Códigos e apresentação usam os mesmos conceitos e números.
- [ ] Diagrama está inserido no material executivo.
- [ ] ZIP final abre e todos os arquivos são legíveis.
