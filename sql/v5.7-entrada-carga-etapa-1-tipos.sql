-- Projeto Fênix Estoque — V5.7
-- ETAPA 1 DE 2: preparar os tipos usados pela entrada de carga.
-- Execute este arquivo sozinho no SQL Editor do Supabase e aguarde a conclusão.
-- Depois execute v5.7-entrada-carga-etapa-2-funcao.sql.

DO $bloco$
DECLARE
  v_tipo_lancamento regtype;
  v_tipo_movimento regtype;
BEGIN
  SELECT a.atttypid::regtype
    INTO v_tipo_lancamento
  FROM pg_attribute a
  WHERE a.attrelid = 'public.lancamentos'::regclass
    AND a.attname = 'tipo_lancamento'
    AND a.attnum > 0
    AND NOT a.attisdropped;

  SELECT a.atttypid::regtype
    INTO v_tipo_movimento
  FROM pg_attribute a
  WHERE a.attrelid = 'public.movimentos_estoque'::regclass
    AND a.attname = 'tipo_movimento'
    AND a.attnum > 0
    AND NOT a.attisdropped;

  IF EXISTS (SELECT 1 FROM pg_type WHERE oid = v_tipo_lancamento AND typtype = 'e') THEN
    EXECUTE format('ALTER TYPE %s ADD VALUE IF NOT EXISTS %L', v_tipo_lancamento, 'entrada_carga');
  END IF;

  IF EXISTS (SELECT 1 FROM pg_type WHERE oid = v_tipo_movimento AND typtype = 'e') THEN
    EXECUTE format('ALTER TYPE %s ADD VALUE IF NOT EXISTS %L', v_tipo_movimento, 'saida_vazio');
  END IF;
END
$bloco$;

-- Conferência: deve retornar os valores entrada_carga e saida_vazio quando as colunas forem enum.
SELECT
  c.relname AS tabela,
  a.attname AS coluna,
  t.typname AS tipo,
  e.enumlabel AS valor
FROM pg_attribute a
JOIN pg_class c ON c.oid = a.attrelid
JOIN pg_type t ON t.oid = a.atttypid
LEFT JOIN pg_enum e ON e.enumtypid = t.oid
WHERE c.oid IN ('public.lancamentos'::regclass, 'public.movimentos_estoque'::regclass)
  AND a.attname IN ('tipo_lancamento', 'tipo_movimento')
  AND e.enumlabel IN ('entrada_carga', 'saida_vazio')
ORDER BY tabela, coluna, e.enumsortorder;
