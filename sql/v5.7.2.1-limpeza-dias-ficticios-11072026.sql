-- Projeto Fênix Estoque — V5.7.2.1
-- Limpeza autorizada por Marco em 11/07/2026.
-- Escopo exclusivo: Várzea Gás, dias 11/07/2099 e 12/07/2099.
-- O script aborta integralmente diante de qualquer diferença nas contagens ou dependências.

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

LOCK TABLE
  public.dias_operacionais,
  public.conferencias_abertura,
  public.itens_conferencia_abertura,
  public.fechamentos,
  public.itens_fechamento,
  public.divergencias_fechamento,
  public.lancamentos,
  public.movimentos_estoque,
  public.correcoes
IN SHARE ROW EXCLUSIVE MODE;

CREATE TEMP TABLE tmp_fenix_dias_alvo
ON COMMIT DROP
AS
SELECT
  d.id,
  d.data_operacional,
  d.status::text AS status_dia
FROM public.revendas r
JOIN public.dias_operacionais d
  ON d.revenda_id = r.id
WHERE lower(trim(r.nome)) = lower('Várzea Gás')
  AND d.data_operacional IN (
    DATE '2099-07-11',
    DATE '2099-07-12'
  );

CREATE TEMP TABLE tmp_fenix_aberturas_alvo
ON COMMIT DROP
AS
SELECT ca.id
FROM public.conferencias_abertura ca
WHERE ca.dia_operacional_id IN (
  SELECT id FROM tmp_fenix_dias_alvo
);

CREATE TEMP TABLE tmp_fenix_fechamentos_alvo
ON COMMIT DROP
AS
SELECT f.id
FROM public.fechamentos f
WHERE f.dia_operacional_id IN (
  SELECT id FROM tmp_fenix_dias_alvo
);

CREATE TEMP TABLE tmp_fenix_lancamentos_alvo
ON COMMIT DROP
AS
SELECT l.id
FROM public.lancamentos l
WHERE l.dia_operacional_id IN (
  SELECT id FROM tmp_fenix_dias_alvo
);

CREATE TEMP TABLE tmp_fenix_movimentos_alvo
ON COMMIT DROP
AS
SELECT DISTINCT me.id
FROM public.movimentos_estoque me
WHERE me.dia_operacional_id IN (
        SELECT id FROM tmp_fenix_dias_alvo
      )
   OR me.lancamento_id IN (
        SELECT id FROM tmp_fenix_lancamentos_alvo
      );

DO $limpeza$
DECLARE
  v_contagem bigint;
  v_linhas integer;
BEGIN
  -- Guardas dos dois dias autorizados.
  SELECT count(*) INTO v_contagem
  FROM tmp_fenix_dias_alvo;

  IF v_contagem <> 2 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperados 2 dias fictícios, encontrados %.',
      v_contagem;
  END IF;

  SELECT count(*) INTO v_contagem
  FROM tmp_fenix_dias_alvo
  WHERE data_operacional = DATE '2099-07-11'
    AND status_dia = 'fechado';

  IF v_contagem <> 1 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: 11/07/2099 não corresponde ao dia fechado homologado.';
  END IF;

  SELECT count(*) INTO v_contagem
  FROM tmp_fenix_dias_alvo
  WHERE data_operacional = DATE '2099-07-12'
    AND status_dia = 'aberto';

  IF v_contagem <> 1 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: 12/07/2099 não corresponde ao dia aberto homologado.';
  END IF;

  -- Contagens homologadas.
  SELECT count(*) INTO v_contagem
  FROM tmp_fenix_aberturas_alvo;
  IF v_contagem <> 2 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperadas 2 aberturas, encontradas %.',
      v_contagem;
  END IF;

  SELECT count(*) INTO v_contagem
  FROM public.itens_conferencia_abertura
  WHERE conferencia_abertura_id IN (
    SELECT id FROM tmp_fenix_aberturas_alvo
  );
  IF v_contagem <> 10 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperados 10 itens de abertura, encontrados %.',
      v_contagem;
  END IF;

  SELECT count(*) INTO v_contagem
  FROM tmp_fenix_fechamentos_alvo;
  IF v_contagem <> 1 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperado 1 fechamento, encontrados %.',
      v_contagem;
  END IF;

  SELECT count(*) INTO v_contagem
  FROM public.itens_fechamento
  WHERE fechamento_id IN (
    SELECT id FROM tmp_fenix_fechamentos_alvo
  );
  IF v_contagem <> 5 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperados 5 itens de fechamento, encontrados %.',
      v_contagem;
  END IF;

  SELECT count(*) INTO v_contagem
  FROM public.divergencias_fechamento
  WHERE fechamento_id IN (
    SELECT id FROM tmp_fenix_fechamentos_alvo
  );
  IF v_contagem <> 0 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: foram encontradas % divergências inesperadas.',
      v_contagem;
  END IF;

  SELECT count(*) INTO v_contagem
  FROM tmp_fenix_lancamentos_alvo;
  IF v_contagem <> 2 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperados 2 lançamentos, encontrados %.',
      v_contagem;
  END IF;

  SELECT count(*) INTO v_contagem
  FROM public.lancamentos l
  WHERE l.id IN (
          SELECT id FROM tmp_fenix_lancamentos_alvo
        )
    AND l.tipo_lancamento = 'entrada_carga'
    AND l.status::text = 'ativo';
  IF v_contagem <> 2 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: os lançamentos não correspondem às 2 entradas de carga ativas homologadas.';
  END IF;

  SELECT count(*) INTO v_contagem
  FROM tmp_fenix_movimentos_alvo;
  IF v_contagem <> 4 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperados 4 movimentos, encontrados %.',
      v_contagem;
  END IF;

  SELECT count(*) INTO v_contagem
  FROM public.movimentos_estoque me
  JOIN public.produtos p
    ON p.id = me.produto_id
  WHERE me.id IN (
          SELECT id FROM tmp_fenix_movimentos_alvo
        )
    AND me.tipo_movimento = 'entrada_cheia'
    AND me.quantidade = 5
    AND me.status::text = 'ativo'
    AND p.codigo = 'P13';
  IF v_contagem <> 2 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperados 2 movimentos P13 de entrada_cheia com quantidade 5, encontrados %.',
      v_contagem;
  END IF;

  SELECT count(*) INTO v_contagem
  FROM public.movimentos_estoque me
  JOIN public.produtos p
    ON p.id = me.produto_id
  WHERE me.id IN (
          SELECT id FROM tmp_fenix_movimentos_alvo
        )
    AND me.tipo_movimento = 'saida_vazio'
    AND me.quantidade = 5
    AND me.status::text = 'ativo'
    AND p.codigo = 'P13';
  IF v_contagem <> 2 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperados 2 movimentos P13 de saida_vazio com quantidade 5, encontrados %.',
      v_contagem;
  END IF;

  SELECT count(*) INTO v_contagem
  FROM public.movimentos_estoque saida
  JOIN public.movimentos_estoque cheia
    ON cheia.id = saida.movimento_vinculado_id
  WHERE saida.id IN (
          SELECT id FROM tmp_fenix_movimentos_alvo
        )
    AND cheia.id IN (
          SELECT id FROM tmp_fenix_movimentos_alvo
        )
    AND saida.tipo_movimento = 'saida_vazio'
    AND cheia.tipo_movimento = 'entrada_cheia'
    AND saida.lancamento_id = cheia.lancamento_id
    AND saida.quantidade = cheia.quantidade;
  IF v_contagem <> 2 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: os pares entrada_cheia/saida_vazio não estão vinculados como homologado.';
  END IF;

  SELECT count(*) INTO v_contagem
  FROM public.correcoes c
  WHERE c.lancamento_original_id IN (
          SELECT id FROM tmp_fenix_lancamentos_alvo
        )
     OR c.lancamento_correcao_id IN (
          SELECT id FROM tmp_fenix_lancamentos_alvo
        )
     OR c.movimento_original_id IN (
          SELECT id FROM tmp_fenix_movimentos_alvo
        )
     OR c.movimento_correcao_id IN (
          SELECT id FROM tmp_fenix_movimentos_alvo
        );
  IF v_contagem <> 0 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: foram encontradas % correções vinculadas aos dados fictícios.',
      v_contagem;
  END IF;

  -- Retira somente os dois vínculos internos dos movimentos fictícios.
  UPDATE public.movimentos_estoque
  SET movimento_vinculado_id = NULL
  WHERE id IN (
          SELECT id FROM tmp_fenix_movimentos_alvo
        )
    AND movimento_vinculado_id IS NOT NULL;

  GET DIAGNOSTICS v_linhas = ROW_COUNT;
  IF v_linhas <> 2 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperados 2 vínculos internos, alterados %.',
      v_linhas;
  END IF;

  DELETE FROM public.movimentos_estoque
  WHERE id IN (
    SELECT id FROM tmp_fenix_movimentos_alvo
  );

  GET DIAGNOSTICS v_linhas = ROW_COUNT;
  IF v_linhas <> 4 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperados 4 movimentos excluídos, excluídos %.',
      v_linhas;
  END IF;

  DELETE FROM public.lancamentos
  WHERE id IN (
    SELECT id FROM tmp_fenix_lancamentos_alvo
  );

  GET DIAGNOSTICS v_linhas = ROW_COUNT;
  IF v_linhas <> 2 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperados 2 lançamentos excluídos, excluídos %.',
      v_linhas;
  END IF;

  -- A exclusão dos dias remove por cascata aberturas, fechamentos e seus itens.
  DELETE FROM public.dias_operacionais
  WHERE id IN (
    SELECT id FROM tmp_fenix_dias_alvo
  );

  GET DIAGNOSTICS v_linhas = ROW_COUNT;
  IF v_linhas <> 2 THEN
    RAISE EXCEPTION
      'Limpeza cancelada: esperados 2 dias excluídos, excluídos %.',
      v_linhas;
  END IF;

  -- Verificação interna antes do COMMIT.
  IF EXISTS (
    SELECT 1
    FROM public.movimentos_estoque
    WHERE id IN (SELECT id FROM tmp_fenix_movimentos_alvo)
  ) THEN
    RAISE EXCEPTION 'Limpeza cancelada: ainda existem movimentos fictícios.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.lancamentos
    WHERE id IN (SELECT id FROM tmp_fenix_lancamentos_alvo)
  ) THEN
    RAISE EXCEPTION 'Limpeza cancelada: ainda existem lançamentos fictícios.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.conferencias_abertura
    WHERE id IN (SELECT id FROM tmp_fenix_aberturas_alvo)
  ) THEN
    RAISE EXCEPTION 'Limpeza cancelada: ainda existem aberturas fictícias.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.fechamentos
    WHERE id IN (SELECT id FROM tmp_fenix_fechamentos_alvo)
  ) THEN
    RAISE EXCEPTION 'Limpeza cancelada: ainda existem fechamentos fictícios.';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.dias_operacionais
    WHERE id IN (SELECT id FROM tmp_fenix_dias_alvo)
  ) THEN
    RAISE EXCEPTION 'Limpeza cancelada: ainda existem dias fictícios.';
  END IF;
END
$limpeza$;

COMMIT;

-- Resultado final após o COMMIT.
SELECT
  CASE
    WHEN count(*) = 0 THEN 'LIMPEZA CONCLUÍDA'
    ELSE 'ATENÇÃO: AINDA EXISTEM DIAS FICTÍCIOS'
  END AS resultado,
  count(*)::bigint AS dias_ficticios_restantes
FROM public.revendas r
JOIN public.dias_operacionais d
  ON d.revenda_id = r.id
WHERE lower(trim(r.nome)) = lower('Várzea Gás')
  AND d.data_operacional IN (
    DATE '2099-07-11',
    DATE '2099-07-12'
  );
