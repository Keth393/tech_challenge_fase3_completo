# Metodologia e decisões analíticas

## Objetivo de negócio

Transformar as pesquisas State of Data Brasil de 2023, 2024 e 2025 em evidências para uma instituição financeira decidir como contratar, capacitar e investir em Dados, Analytics e Inteligência Artificial.

## População e comparabilidade

Cada edição é uma pesquisa independente e não um painel das mesmas pessoas. Assim, uma mudança de percentual representa diferença entre amostras anuais, não evolução individual. Toda visualização deve apresentar o ano, o denominador e, quando relevante, a quantidade absoluta.

Perguntas e alternativas mudaram entre as edições. As regras adotadas são:

- comparar somente conceitos equivalentes;
- não interpretar opção inexistente como valor zero;
- sinalizar indicadores disponíveis em apenas um ou dois anos;
- apresentar recortes com menos de 20 respostas apenas com ressalva;
- separar ausência de resposta de resposta negativa;
- em perguntas de múltipla escolha, calcular adoção sobre quem recebeu/respondeu à pergunta, e não automaticamente sobre toda a pesquisa.

## Camadas

### Bronze - dados de origem

Os CSVs são preservados em `bases_origem_pesquisas/<ano>/`. A camada permite rastreabilidade e reprocessamento.

### Silver - padronização técnica

O Glue lê os CSVs, normaliza espaços e strings vazias, remove duplicidades pela chave da pesquisa, converte para Parquet e registra `pesquisas_<ano>` no Glue Data Catalog. Os SQLs SOT transformam os nomes extensos do questionário em identificadores técnicos.

### Gold - visão de negócio

Os SQLs SPEC renomeiam os campos para conceitos de negócio. A view `vw_mercado_dados` harmoniza apenas dimensões comparáveis e sustenta as consultas executivas.

## Qualidade

São controlados:

- linhas lidas e gravadas;
- chave distinta por ano;
- duplicidades removidas;
- campos totalmente vazios;
- nulos nas dimensões centrais;
- tamanho amostral de cada gráfico;
- coerência do ano e dos caminhos S3;
- existência das tabelas no catálogo.

## Remuneração

A pesquisa coleta faixas salariais. Quando for necessário um valor numérico, deve-se usar o ponto médio da faixa como *proxy*. O resultado é uma estimativa agregada e não deve ser chamado de salário individual exato. A faixa aberta superior exige uma hipótese explícita, mantida igual em todos os anos.

## Limitações

- amostra por conveniência, sujeita a viés de seleção;
- queda do total de respondentes ao longo do período;
- mudanças de alternativas e roteamento do questionário;
- recortes regionais pequenos, especialmente no Norte;
- indicadores de IA mais completos apenas em 2024 e 2025;
- associação não significa causalidade.

## Critério para insights

Um insight só deve entrar na apresentação se houver consulta reproduzível, denominador conhecido e coerência com a pergunta original. Recomendações devem ser ligadas a pelo menos um indicador e acompanhadas de uma ressalva quando a comparação tiver limitação.
