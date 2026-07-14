-- Projeto Fênix Estoque — V5.7.2.1
-- Diagnóstico SOMENTE DE LEITURA do dia operacional 14/07/2026.
-- Revenda-alvo: Várzea Gás.
--
-- Objetivo:
-- 1. confirmar se os lançamentos gravados fisicamente em 09/07/2026 estão
--    vinculados ao dia operacional 14/07/2026;
-- 2. levantar todas as dependências antes de qualquer limpeza;
-- 3. não alterar nenhum dado.
--
-- Este arquivo não contém DELETE, UPDATE, INSERT, TRUNCATE nem alteração de estrutura.

-- 1. Identificar o dia operacional exato.
SELECT
  r.id AS revenda_id,
  r.nome AS revenda,
  d.id AS dia_operacional_id,
  d.data_operacional,
  d.status::text AS status_dia
FROM public.revendas r
JOIN public.dias_operacionais d
  ON d.revenda_id = r.id
WHERE lower(trim(r.nome)) = lower('Várzea Gás')
  AND d.data_operacional = DATE '2026-07-14';

-- 2. Contar todos os registros conhecidos vinculados ao dia.
WITH dia_alvo AS (
  SELECT d.id
  FROM public.revendas r
  JOIN public.dias_operacionais d
    ON d.revenda_id = r.id
  WHERE lower(trim(r.nome)) = lower('Várzea Gás')
    AND d.data_operacional = DATE '2026-07-14'
),
aberturas_alvo AS (
  SELECT ca.id
  FROM public.conferencias_abertura ca
  WHERE ca.dia_operacional_id IN (SELECT id FROM dia_alvo)
),
fechamentos_alvo AS (
  SELECT f.id
  FROM public.fechamentos f
  WHERE f.dia_operacional_id IN (SELECT id FROM dia_alvo)
),
lancamentos_alvo AS (
  SELECT l.id
  FROM public.lancamentos l
  WHERE l.dia_operacional_id IN (SELECT id FROM dia_alvo)
)
SELECT 'dias_operacionais' AS tabela, count(*)::bigint AS registros
FROM public.dias_operacionais
WHERE id IN (SELECT id FROM dia_alvo)

UNION ALL

SELECT 'conferencias_abertura', count(*)::bigint
FROM public.conferencias_abertura
WHERE id IN (SELECT id FROM aberturas_alvo)

UNION ALL

SELECT 'itens_conferencia_abertura', count(*)::bigint
FROM public.itens_conferencia_abertura
WHERE conferencia_abertura_id IN (SELECT id FROM aberturas_alvo)

UNION ALL

SELECT 'lancamentos', count(*)::bigint
FROM public.lancamentos
WHERE id IN (SELECT id FROM lancamentos_alvo)

UNION ALL

SELECT 'movimentos_estoque', count(*)::bigint
FROM public.movimentos_estoque
WHERE dia_operacional_id IN (SELECT id FROM dia_alvo)
   OR lancamento_id IN (SELECT id FROM lancamentos_alvo)

UNION ALL

SELECT 'fechamentos', count(*)::bigint
FROM public.fechamentos
WHERE id IN (SELECT id FROM fechamentos_alvo)

UNION ALL

SELECT 'itens_fechamento', count(*)::bigint
FROM public.itens_fechamento
WHERE fechamento_id IN (SELECT id FROM fechamentos_alvo)

UNION ALL

SELECT 'divergencias_fechamento', count(*)::bigint
FROM public.divergencias_fechamento
WHERE fechamento_id IN (SELECT id FROM fechamentos_alvo)

UNION ALL

SELECT 'correcoes', count(*)::bigint
FROM public.correcoes c
WHERE c.lancamento_original_id IN (SELECT id FROM lancamentos_alvo)
   OR c.lancamento_correcao_id IN (SELECT id FROM lancamentos_alvo)
   OR c.movimento_original_id IN (
        SELECT me.id
        FROM public.movimentos_estoque me
        WHERE me.dia_operacional_id IN (SELECT id FROM dia_alvo)
           OR me.lancamento_id IN (SELECT id FROM lancamentos_alvo)
      )
   OR c.movimento_correcao_id IN (
        SELECT me.id
        FROM public.movimentos_estoque me
        WHERE me.dia_operacional_id IN (SELECT id FROM dia_alvo)
           OR me.lancamento_id IN (SELECT id FROM lancamentos_alvo)
      )

ORDER BY tabela;

-- 3. Auditar os lançamentos, incluindo a data/hora física de gravação.
-- O campo data_operacional vem do dia ao qual o lançamento está vinculado.
SELECT
  d.data_operacional,
  d.status::text AS status_dia,
  l.*
FROM public.revendas r
JOIN public.dias_operacionais d
  ON d.revenda_id = r.id
JOIN public.lancamentos l
  ON l.dia_operacional_id = d.id
WHERE lower(trim(r.nome)) = lower('Várzea Gás')
  AND d.data_operacional = DATE '2026-07-14'
ORDER BY l.data_hora, l.id;

-- 4. Auditar todos os movimentos gerados pelos lançamentos do dia.
SELECT
  d.data_operacional,
  l.data_hora AS data_hora_lancamento,
  l.id AS lancamento_id,
  l.tipo_lancamento,
  l.status::text AS status_lancamento,
  p.codigo AS produto,
  me.id AS movimento_id,
  me.tipo_movimento,
  me.quantidade,
  me.status::text AS status_movimento,
  me.movimento_vinculado_id
FROM public.revendas r
JOIN public.dias_operacionais d
  ON d.revenda_id = r.id
LEFT JOIN public.lancamentos l
  ON l.dia_operacional_id = d.id
LEFT JOIN public.movimentos_estoque me
  ON me.dia_operacional_id = d.id
 AND (l.id IS NULL OR me.lancamento_id = l.id)
LEFT JOIN public.produtos p
  ON p.id = me.produto_id
WHERE lower(trim(r.nome)) = lower('Várzea Gás')
  AND d.data_operacional = DATE '2026-07-14'
ORDER BY l.data_hora, l.id, me.tipo_movimento, me.id;

-- 5. Auditar abertura e fechamento do dia.
SELECT
  d.data_operacional,
  ca.id AS conferencia_abertura_id,
  f.id AS fechamento_id,
  d.status::text AS status_dia
FROM public.revendas r
JOIN public.dias_operacionais d
  ON d.revenda_id = r.id
LEFT JOIN public.conferencias_abertura ca
  ON ca.dia_operacional_id = d.id
LEFT JOIN public.fechamentos f
  ON f.dia_operacional_id = d.id
WHERE lower(trim(r.nome)) = lower('Várzea Gás')
  AND d.data_operacional = DATE '2026-07-14';

-- 6. Conferir as chaves estrangeiras que podem impedir ou ampliar uma limpeza.
SELECT
  c.conrelid::regclass AS tabela_filha,
  c.confrelid::regclass AS tabela_pai,
  c.conname AS restricao,
  pg_get_constraintdef(c.oid, true) AS definicao
FROM pg_constraint c
WHERE c.contype = 'f'
  AND c.confrelid IN (
    'public.dias_operacionais'::regclass,
    'public.conferencias_abertura'::regclass,
    'public.fechamentos'::regclass,
    'public.lancamentos'::regclass,
    'public.movimentos_estoque'::regclass
  )
ORDER BY
  c.confrelid::regclass::text,
  c.conrelid::regclass::text,
  c.conname;

-- PARE AQUI.
-- Envie os resultados para conferência antes de qualquer exclusão.
