-- Tech Challenge - Fase 3
-- Execute cada bloco separadamente no Amazon Athena.

-- 1) View central com dimensões comparáveis nos três anos.
CREATE OR REPLACE VIEW tech_challenge_db.vw_mercado_dados AS
SELECT 2023 AS ano, id, genero, regiao_residencia, setor_atuacao, cargo_atual,
       nivel_cargo_atual, faixa_salarial, modelo_atual_de_trabalho
FROM tech_challenge_db.spec_pesquisas_2023
UNION ALL
SELECT 2024 AS ano, id, genero, regiao_residencia, setor_atuacao, cargo_atual,
       nivel_cargo_atual, faixa_salarial, modelo_atual_de_trabalho
FROM tech_challenge_db.spec_pesquisas_2024
UNION ALL
SELECT 2025 AS ano, token AS id, genero, regiao_residencia, setor_atuacao, cargo_atual,
       nivel_cargo_atual, faixa_salarial, modelo_atual_de_trabalho
FROM tech_challenge_db.spec_pesquisas_2025;

-- 2) Painel geral: respondentes, atuação em dados e liderança.
SELECT ano, COUNT(*) AS respondentes,
       COUNT_IF(cargo_atual IS NOT NULL) AS profissionais_com_cargo_informado,
       ROUND(100.0 * COUNT_IF(cargo_atual IS NOT NULL) / COUNT(*), 1) AS pct_com_cargo
FROM tech_challenge_db.vw_mercado_dados
GROUP BY ano ORDER BY ano;

-- 3) Cargos mais comuns: quantidade e percentual dentro do ano.
SELECT ano, cargo_atual, COUNT(*) AS quantidade,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY ano), 1) AS percentual
FROM tech_challenge_db.vw_mercado_dados
WHERE cargo_atual IS NOT NULL
GROUP BY ano, cargo_atual
ORDER BY ano, quantidade DESC;

-- 4) Evolução da senioridade.
SELECT ano, nivel_cargo_atual AS senioridade, COUNT(*) AS quantidade,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY ano), 1) AS percentual
FROM tech_challenge_db.vw_mercado_dados
WHERE nivel_cargo_atual IS NOT NULL
GROUP BY ano, nivel_cargo_atual
ORDER BY ano, quantidade DESC;

-- 5) Setores que mais empregam profissionais de dados.
SELECT ano, setor_atuacao, COUNT(*) AS quantidade,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY ano), 1) AS percentual
FROM tech_challenge_db.vw_mercado_dados
WHERE setor_atuacao IS NOT NULL AND cargo_atual IS NOT NULL
GROUP BY ano, setor_atuacao
ORDER BY ano, quantidade DESC;

-- 6) Modelo atual de trabalho. Compare os três anos, mas mantenha o tamanho
-- amostral no gráfico porque a formulação/roteamento do questionário mudou.
SELECT ano, modelo_atual_de_trabalho, COUNT(*) AS quantidade,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY ano), 1) AS percentual
FROM tech_challenge_db.vw_mercado_dados
WHERE modelo_atual_de_trabalho IS NOT NULL
GROUP BY ano, modelo_atual_de_trabalho
ORDER BY ano, quantidade DESC;

-- 7) Diversidade de gênero por ano.
SELECT ano, genero, COUNT(*) AS quantidade,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY ano), 1) AS percentual
FROM tech_challenge_db.vw_mercado_dados
WHERE genero IS NOT NULL
GROUP BY ano, genero
ORDER BY ano, quantidade DESC;

-- 8) Participação de mulheres por cargo e ano.
SELECT ano, cargo_atual, COUNT(*) AS total_cargo,
       COUNT_IF(LOWER(genero) LIKE 'femin%') AS mulheres,
       ROUND(100.0 * COUNT_IF(LOWER(genero) LIKE 'femin%') / COUNT(*), 1) AS pct_mulheres
FROM tech_challenge_db.vw_mercado_dados
WHERE cargo_atual IS NOT NULL AND genero IS NOT NULL
GROUP BY ano, cargo_atual
HAVING COUNT(*) >= 20
ORDER BY ano, pct_mulheres DESC;

-- 9) Participação de mulheres por senioridade e ano.
SELECT ano, nivel_cargo_atual AS senioridade, COUNT(*) AS total,
       ROUND(100.0 * COUNT_IF(LOWER(genero) LIKE 'femin%') / COUNT(*), 1) AS pct_mulheres
FROM tech_challenge_db.vw_mercado_dados
WHERE nivel_cargo_atual IS NOT NULL AND genero IS NOT NULL
GROUP BY ano, nivel_cargo_atual
ORDER BY ano, senioridade;

-- 10) Distribuição regional.
SELECT ano, regiao_residencia, COUNT(*) AS quantidade,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY ano), 1) AS percentual
FROM tech_challenge_db.vw_mercado_dados
WHERE regiao_residencia IS NOT NULL
GROUP BY ano, regiao_residencia
ORDER BY ano, quantidade DESC;

-- 11) Base tecnológica comparável. Flags são convertidas para 0/1.
WITH tecnologias AS (
  SELECT 2023 ano, id,
    CASE WHEN CAST(flag_utiliza_sql AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END usa_sql,
    CASE WHEN CAST(flag_utiliza_python AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END usa_python,
    CASE WHEN CAST(flag_utiliza_aws AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END usa_aws,
    CASE WHEN CAST(flag_utiliza_azure AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END usa_azure,
    CASE WHEN CAST(flag_utiliza_google_cloud AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END usa_gcp
  FROM tech_challenge_db.spec_pesquisas_2023
  UNION ALL
  SELECT 2024, id,
    CASE WHEN CAST(flag_utiliza_sql AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_utiliza_python AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_utiliza_aws AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_utiliza_azure AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_utiliza_google_cloud AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END
  FROM tech_challenge_db.spec_pesquisas_2024
  UNION ALL
  SELECT 2025, token,
    CASE WHEN CAST(flag_utiliza_sql AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_utiliza_python AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_utiliza_aws AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_utiliza_azure AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_utiliza_google_cloud AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END
  FROM tech_challenge_db.spec_pesquisas_2025
)
SELECT ano, tecnologia, ROUND(100.0 * SUM(adotou) / COUNT(*), 1) percentual
FROM tecnologias
CROSS JOIN UNNEST(
  ARRAY['SQL','Python','AWS','Azure','GCP'],
  ARRAY[usa_sql,usa_python,usa_aws,usa_azure,usa_gcp]
) AS t(tecnologia, adotou)
GROUP BY ano, tecnologia
ORDER BY tecnologia, ano;

-- 12) Salário estimado. O ponto médio é uma proxy das faixas da pesquisa.
WITH salarios AS (
  SELECT *, CASE
    WHEN LOWER(faixa_salarial) LIKE '%menos de r$ 1.000%' THEN 500
    WHEN faixa_salarial LIKE '%1.001%' AND faixa_salarial LIKE '%2.000%' THEN 1500
    WHEN faixa_salarial LIKE '%2.001%' AND faixa_salarial LIKE '%3.000%' THEN 2500
    WHEN faixa_salarial LIKE '%3.001%' AND faixa_salarial LIKE '%4.000%' THEN 3500
    WHEN faixa_salarial LIKE '%4.001%' AND faixa_salarial LIKE '%6.000%' THEN 5000
    WHEN faixa_salarial LIKE '%6.001%' AND faixa_salarial LIKE '%8.000%' THEN 7000
    WHEN faixa_salarial LIKE '%8.001%' AND faixa_salarial LIKE '%12.000%' THEN 10000
    WHEN faixa_salarial LIKE '%12.001%' AND faixa_salarial LIKE '%16.000%' THEN 14000
    WHEN faixa_salarial LIKE '%16.001%' AND faixa_salarial LIKE '%20.000%' THEN 18000
    WHEN faixa_salarial LIKE '%20.001%' AND faixa_salarial LIKE '%25.000%' THEN 22500
    WHEN faixa_salarial LIKE '%25.001%' AND faixa_salarial LIKE '%30.000%' THEN 27500
    WHEN faixa_salarial LIKE '%30.001%' AND faixa_salarial LIKE '%40.000%' THEN 35000
    WHEN LOWER(faixa_salarial) LIKE '%acima de r$ 40.000%' THEN 45000
  END AS salario_proxy
  FROM tech_challenge_db.vw_mercado_dados
)
SELECT ano, nivel_cargo_atual AS senioridade, COUNT(salario_proxy) AS base,
       ROUND(AVG(salario_proxy), 0) AS salario_medio_estimado,
       APPROX_PERCENTILE(salario_proxy, 0.5) AS salario_mediano_estimado
FROM salarios
WHERE salario_proxy IS NOT NULL AND nivel_cargo_atual IS NOT NULL
GROUP BY ano, nivel_cargo_atual
HAVING COUNT(salario_proxy) >= 20
ORDER BY ano, salario_mediano_estimado;

-- 13) Salário por gênero e senioridade em 2025.
WITH salarios_2025 AS (
  SELECT genero, nivel_cargo_atual, CASE
    WHEN LOWER(faixa_salarial) LIKE '%menos de r$ 1.000%' THEN 500
    WHEN faixa_salarial LIKE '%1.001%' AND faixa_salarial LIKE '%2.000%' THEN 1500
    WHEN faixa_salarial LIKE '%2.001%' AND faixa_salarial LIKE '%3.000%' THEN 2500
    WHEN faixa_salarial LIKE '%3.001%' AND faixa_salarial LIKE '%4.000%' THEN 3500
    WHEN faixa_salarial LIKE '%4.001%' AND faixa_salarial LIKE '%6.000%' THEN 5000
    WHEN faixa_salarial LIKE '%6.001%' AND faixa_salarial LIKE '%8.000%' THEN 7000
    WHEN faixa_salarial LIKE '%8.001%' AND faixa_salarial LIKE '%12.000%' THEN 10000
    WHEN faixa_salarial LIKE '%12.001%' AND faixa_salarial LIKE '%16.000%' THEN 14000
    WHEN faixa_salarial LIKE '%16.001%' AND faixa_salarial LIKE '%20.000%' THEN 18000
    WHEN faixa_salarial LIKE '%20.001%' AND faixa_salarial LIKE '%25.000%' THEN 22500
    WHEN faixa_salarial LIKE '%25.001%' AND faixa_salarial LIKE '%30.000%' THEN 27500
    WHEN faixa_salarial LIKE '%30.001%' AND faixa_salarial LIKE '%40.000%' THEN 35000
    WHEN LOWER(faixa_salarial) LIKE '%acima de r$ 40.000%' THEN 45000
  END salario_proxy
  FROM tech_challenge_db.vw_mercado_dados WHERE ano = 2025
)
SELECT genero, nivel_cargo_atual AS senioridade, COUNT(salario_proxy) base,
       APPROX_PERCENTILE(salario_proxy, 0.5) AS salario_mediano_estimado
FROM salarios_2025
WHERE salario_proxy IS NOT NULL AND genero IS NOT NULL AND nivel_cargo_atual IS NOT NULL
GROUP BY genero, nivel_cargo_atual
HAVING COUNT(salario_proxy) >= 20
ORDER BY senioridade, genero;

-- 14) Adoção das principais ferramentas de BI.
WITH bi AS (
  SELECT 2023 ano, id,
    CASE WHEN CAST(flag_utiliza_powerbi AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END power_bi,
    CASE WHEN CAST(flag_utiliza_tableau AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END tableau,
    CASE WHEN CAST(flag_utiliza_looker AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END looker
  FROM tech_challenge_db.spec_pesquisas_2023
  UNION ALL
  SELECT 2024, id,
    CASE WHEN CAST(flag_microsoft_powerbi AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_tableau AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_looker AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END
  FROM tech_challenge_db.spec_pesquisas_2024
  UNION ALL
  SELECT 2025, token,
    CASE WHEN CAST(flag_utiliza_powerbi AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_utiliza_tableau AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_looker AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END
  FROM tech_challenge_db.spec_pesquisas_2025
)
SELECT ano, ferramenta, SUM(adotou) quantidade,
       ROUND(100.0 * SUM(adotou) / COUNT(*), 1) percentual
FROM bi
CROSS JOIN UNNEST(ARRAY['Power BI','Tableau','Looker'], ARRAY[power_bi,tableau,looker]) t(ferramenta, adotou)
GROUP BY ano, ferramenta ORDER BY ferramenta, ano;

-- 15) IA generativa como prioridade da empresa (disponível em 2024 e 2025).
SELECT 2024 ano, ai_generativa_e_uma_prioridade_em_sua_empresa AS prioridade,
       COUNT(*) quantidade
FROM tech_challenge_db.spec_pesquisas_2024
WHERE ai_generativa_e_uma_prioridade_em_sua_empresa IS NOT NULL
GROUP BY ai_generativa_e_uma_prioridade_em_sua_empresa
UNION ALL
SELECT 2025, ai_generativa_e_llm_e_uma_prioridade, COUNT(*)
FROM tech_challenge_db.spec_pesquisas_2025
WHERE ai_generativa_e_llm_e_uma_prioridade IS NOT NULL
GROUP BY ai_generativa_e_llm_e_uma_prioridade
ORDER BY ano, quantidade DESC;

-- 16) Resultados corporativos com LLMs (pergunta nova em 2025).
SELECT empresa_esta_conseguindo_ter_bons_resultados_com_llms AS resultado,
       COUNT(*) quantidade,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) percentual
FROM tech_challenge_db.spec_pesquisas_2025
WHERE empresa_esta_conseguindo_ter_bons_resultados_com_llms IS NOT NULL
GROUP BY empresa_esta_conseguindo_ter_bons_resultados_com_llms
ORDER BY quantidade DESC;

-- 17) Barreiras de IA comparáveis em 2024 e 2025 (pergunta multiescolha).
WITH barreiras AS (
  SELECT 2024 ano, id,
    CASE WHEN CAST(flag_falta_de_compreensao_dos_casos_de_uso AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END casos_uso,
    CASE WHEN CAST(flag_dados_da_empresa_nao_estao_prontos_para_uso_de_ia_generativa AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END dados,
    CASE WHEN CAST(flag_retorno_sobre_investimento_roi_nao_comprovado_de_ia_generati AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END roi,
    CASE WHEN CAST(flag_falta_de_expertise_ou_falta_de_recursos AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END expertise
  FROM tech_challenge_db.spec_pesquisas_2024
  UNION ALL
  SELECT 2025, token,
    CASE WHEN CAST(flag_falta_de_compreensao_dos_casos_de_uso AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_dados_da_empresa_nao_estao_prontos_para_uso_de_ia_generativa AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_retorno_sobre_investimento_roi_nao_comprovado_de_ia_generativa AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END,
    CASE WHEN CAST(flag_falta_de_expertise_ou_falta_de_recursos AS VARCHAR) IN ('1','true','True') THEN 1 ELSE 0 END
  FROM tech_challenge_db.spec_pesquisas_2025
)
SELECT ano, barreira, SUM(marcou) quantidade,
       ROUND(100.0 * SUM(marcou) / COUNT(*), 1) percentual
FROM barreiras
CROSS JOIN UNNEST(
  ARRAY['Falta de compreensão dos casos de uso','Dados não estão prontos','ROI não comprovado','Falta de expertise/recursos'],
  ARRAY[casos_uso,dados,roi,expertise]
) t(barreira, marcou)
GROUP BY ano, barreira ORDER BY barreira, ano;

-- 18) Antes da apresentação, confirme tamanhos amostrais de cada recorte.
SELECT ano, COUNT(*) total,
       COUNT_IF(genero IS NULL) nulos_genero,
       COUNT_IF(cargo_atual IS NULL) nulos_cargo,
       COUNT_IF(regiao_residencia IS NULL) nulos_regiao,
       COUNT_IF(faixa_salarial IS NULL) nulos_salario
FROM tech_challenge_db.vw_mercado_dados
GROUP BY ano ORDER BY ano;
