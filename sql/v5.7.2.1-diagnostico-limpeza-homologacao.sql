-- Projeto Fênix Estoque — V5.7.2.1
-- Diagnóstico SOMENTE DE LEITURA antes da limpeza dos dados fictícios.
-- Não contém DELETE, UPDATE, TRUNCATE ou alteração de estrutura.
-- Dias-alvo: Várzea Gás em 11/07/2099 e 12/07/2099.

-- 1. Confirmar exatamente quais dias seriam considerados na limpeza.
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
  AND d.data_operacional IN (
    DATE '2099-07-11',
    DATE '2099-07-12'
  )
ORDER BY d.data_operacional;

-- 2. Contar os registros conhecidos vinculados aos dois dias fictícios.
WITH dias_alvo AS (
  SELECT d.id
  FROM public.revendas r
  JOIN public.dias_operacionais d
    ON d.revenda_id = r.id
  WHERE lower(trim(r.nome)) = lower('Várzea Gás')
    AND d.data_operacional IN (
      DATE '2099-07-11',
      DATE '2099-07-12'
    )
),
aberturas_alvo AS (
  SELECT ca.id
  FROM public.conferencias_abertura ca
  WHERE ca.dia_operacional_id IN (SELECT id FROM dias_alvo)
),
fechamentos_alvo AS (
  SELECT f.id
  FROM public.fechamentos f
  WHERE f.dia_operacional_id IN (SELECT id FROM dias_alvo)
),
lancamentos_alvo AS (
  SELECT l.id
  FROM public.lancamentos l
  WHERE l.dia_operacional_id IN (SELECT id FROM dias_alvo)
)
SELECT 'dias_operacionais' AS tabela, count(*)::bigint AS registros
FROM public.dias_operacionais
WHERE id IN (SELECT id FROM dias_alvo)

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
WHERE dia_operacional_id IN (SELECT id FROM dias_alvo)
   OR lancamento_id IN (SELECT id FROM lancamentos_alvo)

UNION ALL

SELECT 'fechamentos', count(*)::bigint
FROM public.fechamentos
WHERE id IN (SELECT id FROM fechamentos_alvo)

UNION ALL

SELECT 'itens_fechamento', count(*)::bigint
FROM public.itens_fechamento
WHERE fechamento_id IN (SELECT id FROM fechamentos_alvo)

ORDER BY tabela;

-- 3. Listar todas as chaves estrangeiras que apontam para as tabelas operacionais.
-- Esta conferência evita apagar dados sem conhecer dependências adicionais.
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

-- 4. Auditar lançamentos e movimentos dos dias fictícios.
SELECT
  d.data_operacional,
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
  AND d.data_operacional IN (
    DATE '2099-07-11',
    DATE '2099-07-12'
  )
ORDER BY
  d.data_operacional,
  l.data_hora,
  me.tipo_movimento;

-- Pare aqui e envie os resultados para conferência.
-- A limpeza só deve ser escrita e executada após autorização expressa do Marco.
