-- Projeto Fênix Estoque — V5.7.2
-- ETAPA 1 DE 2: liberar os valores usados pela entrada de carga.
--
-- Diagnóstico confirmado em 11/07/2026:
-- - lancamentos.tipo_lancamento é text com CHECK;
-- - movimentos_estoque.tipo_movimento é text com CHECK.
--
-- Esta versão preserva todos os valores já aceitos e acrescenta somente:
-- - entrada_carga em lancamentos.tipo_lancamento;
-- - saida_vazio em movimentos_estoque.tipo_movimento.
--
-- Execute este arquivo sozinho no SQL Editor do Supabase.
-- Depois execute v5.7-entrada-carga-etapa-2-funcao.sql.

BEGIN;

ALTER TABLE public.lancamentos
  DROP CONSTRAINT IF EXISTS lancamentos_tipo_lancamento_check;

ALTER TABLE public.lancamentos
  ADD CONSTRAINT lancamentos_tipo_lancamento_check
  CHECK (
    tipo_lancamento = ANY (
      ARRAY[
        'entrada'::text,
        'venda'::text,
        'ajuste'::text,
        'correcao'::text,
        'entrada_carga'::text
      ]
    )
  );

ALTER TABLE public.movimentos_estoque
  DROP CONSTRAINT IF EXISTS movimentos_estoque_tipo_movimento_check;

ALTER TABLE public.movimentos_estoque
  ADD CONSTRAINT movimentos_estoque_tipo_movimento_check
  CHECK (
    tipo_movimento = ANY (
      ARRAY[
        'entrada_cheia'::text,
        'venda_liquido'::text,
        'venda_casco'::text,
        'ajuste_entrada'::text,
        'ajuste_saida'::text,
        'correcao'::text,
        'saida_vazio'::text
      ]
    )
  );

COMMIT;

-- Conferência: deve retornar as duas restrições já contendo os novos valores.
SELECT
  c.conrelid::regclass AS tabela,
  c.conname AS restricao,
  pg_get_constraintdef(c.oid, true) AS definicao
FROM pg_constraint c
WHERE c.conrelid IN (
  'public.lancamentos'::regclass,
  'public.movimentos_estoque'::regclass
)
  AND c.conname IN (
    'lancamentos_tipo_lancamento_check',
    'movimentos_estoque_tipo_movimento_check'
  )
ORDER BY c.conrelid::regclass::text, c.conname;
