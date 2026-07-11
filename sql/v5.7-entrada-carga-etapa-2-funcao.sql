-- Projeto Fênix Estoque — V5.7.1
-- ETAPA 2 DE 2: função segura de entrada de carga.
-- Pré-requisito: executar primeiro v5.7-entrada-carga-etapa-1-tipos.sql.
-- Revisão V5.7.1: autorização fail-closed, validações adicionais e proteção contra concorrência.

begin;

CREATE OR REPLACE FUNCTION public.registrar_entrada_carga_mvp(
  p_revenda_id uuid,
  p_data_operacional date,
  p_produto_codigo text,
  p_quantidade integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_dia_id uuid;
  v_dia_status text;
  v_produto_id uuid;
  v_lancamento_id uuid;
  v_movimento_cheio_id uuid;
  v_movimento_vazio_id uuid;
  v_vazios_disponiveis bigint;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado.';
  END IF;

  IF p_revenda_id IS NULL THEN
    RAISE EXCEPTION 'Revenda é obrigatória.';
  END IF;

  IF p_data_operacional IS NULL THEN
    RAISE EXCEPTION 'Data operacional é obrigatória.';
  END IF;

  IF public.usuario_autorizado_na_revenda(p_revenda_id) IS DISTINCT FROM TRUE THEN
    RAISE EXCEPTION 'Usuário sem autorização para esta revenda.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.revendas
    WHERE id = p_revenda_id
      AND ativa = true
  ) THEN
    RAISE EXCEPTION 'Revenda não encontrada ou inativa.';
  END IF;

  IF p_produto_codigo IS NULL OR trim(p_produto_codigo) = '' THEN
    RAISE EXCEPTION 'Produto é obrigatório.';
  END IF;

  IF p_quantidade IS NULL OR p_quantidade <= 0 THEN
    RAISE EXCEPTION 'Quantidade precisa ser maior que zero.';
  END IF;

  -- Bloqueia o dia operacional durante a validação e a gravação da carga.
  SELECT id, status::text
    INTO v_dia_id, v_dia_status
  FROM public.dias_operacionais
  WHERE revenda_id = p_revenda_id
    AND data_operacional = p_data_operacional
  LIMIT 1
  FOR UPDATE;

  IF v_dia_id IS NULL THEN
    RAISE EXCEPTION 'Dia operacional não encontrado. Faça a abertura antes da entrada de carga.';
  END IF;

  IF v_dia_status <> 'aberto' THEN
    RAISE EXCEPTION 'Entrada de carga permitida somente com o dia aberto.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.conferencias_abertura
    WHERE dia_operacional_id = v_dia_id
      AND status::text <> 'cancelada'
  ) THEN
    RAISE EXCEPTION 'Não existe abertura ativa para este dia operacional.';
  END IF;

  SELECT id
    INTO v_produto_id
  FROM public.produtos
  WHERE codigo = upper(trim(p_produto_codigo))
    AND ativo = true
    AND codigo IN ('P13', 'P05', 'P20', 'P45', 'AGUA')
  LIMIT 1;

  IF v_produto_id IS NULL THEN
    RAISE EXCEPTION 'Produto não encontrado ou inativo: %', p_produto_codigo;
  END IF;

  -- Serializa gravações na tabela de movimentos durante o cálculo do saldo.
  -- Leituras continuam liberadas; vendas e outras inserções aguardam a conclusão desta transação.
  LOCK TABLE public.movimentos_estoque IN SHARE ROW EXCLUSIVE MODE;

  -- Saldo atual de vazios:
  -- abertura + vendas com troca - venda de casco - saídas de vazios em cargas anteriores.
  SELECT
    coalesce((
      SELECT sum(ica.vazios_fisicos)
      FROM public.conferencias_abertura ca
      JOIN public.itens_conferencia_abertura ica
        ON ica.conferencia_abertura_id = ca.id
      WHERE ca.dia_operacional_id = v_dia_id
        AND ca.status::text <> 'cancelada'
        AND ica.produto_id = v_produto_id
    ), 0)
    + coalesce((
      SELECT sum(CASE
        WHEN me.tipo_movimento::text = 'venda_liquido' THEN me.quantidade
        WHEN me.tipo_movimento::text = 'venda_casco' THEN -me.quantidade
        WHEN me.tipo_movimento::text = 'saida_vazio' THEN -me.quantidade
        ELSE 0
      END)
      FROM public.movimentos_estoque me
      WHERE me.dia_operacional_id = v_dia_id
        AND me.produto_id = v_produto_id
        AND me.status::text = 'ativo'
    ), 0)
  INTO v_vazios_disponiveis;

  IF v_vazios_disponiveis < p_quantidade THEN
    RAISE EXCEPTION 'Vazios insuficientes. Disponível: %, solicitado: %.', v_vazios_disponiveis, p_quantidade;
  END IF;

  INSERT INTO public.lancamentos (
    dia_operacional_id,
    revenda_id,
    canal_venda_id,
    tipo_lancamento,
    data_hora,
    status,
    observacao
  ) VALUES (
    v_dia_id,
    p_revenda_id,
    NULL,
    'entrada_carga',
    now(),
    'ativo',
    'ENTRADA_CARGA_V5.7.1'
  )
  RETURNING id INTO v_lancamento_id;

  INSERT INTO public.movimentos_estoque (
    lancamento_id,
    dia_operacional_id,
    revenda_id,
    produto_id,
    canal_venda_id,
    tipo_movimento,
    quantidade,
    status,
    observacao
  ) VALUES (
    v_lancamento_id,
    v_dia_id,
    p_revenda_id,
    v_produto_id,
    NULL,
    'entrada_cheia',
    p_quantidade,
    'ativo',
    'ENTRADA_CARGA_CHEIOS_V5.7.1'
  )
  RETURNING id INTO v_movimento_cheio_id;

  INSERT INTO public.movimentos_estoque (
    lancamento_id,
    dia_operacional_id,
    revenda_id,
    produto_id,
    canal_venda_id,
    tipo_movimento,
    quantidade,
    movimento_vinculado_id,
    status,
    observacao
  ) VALUES (
    v_lancamento_id,
    v_dia_id,
    p_revenda_id,
    v_produto_id,
    NULL,
    'saida_vazio',
    p_quantidade,
    v_movimento_cheio_id,
    'ativo',
    'ENTRADA_CARGA_VAZIOS_V5.7.1'
  )
  RETURNING id INTO v_movimento_vazio_id;

  RETURN jsonb_build_object(
    'ok', true,
    'mensagem', 'Entrada de carga registrada com sucesso.',
    'dia_operacional_id', v_dia_id,
    'lancamento_id', v_lancamento_id,
    'movimento_entrada_cheia_id', v_movimento_cheio_id,
    'movimento_saida_vazio_id', v_movimento_vazio_id,
    'produto', upper(trim(p_produto_codigo)),
    'quantidade', p_quantidade,
    'cheios_adicionados', p_quantidade,
    'vazios_retirados', p_quantidade,
    'vazios_antes', v_vazios_disponiveis,
    'vazios_depois', v_vazios_disponiveis - p_quantidade
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.registrar_entrada_carga_mvp(uuid, date, text, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.registrar_entrada_carga_mvp(uuid, date, text, integer) FROM anon;
GRANT EXECUTE ON FUNCTION public.registrar_entrada_carga_mvp(uuid, date, text, integer) TO authenticated;

commit;

-- Teste de permissão esperado:
SELECT
  has_function_privilege('authenticated', 'public.registrar_entrada_carga_mvp(uuid,date,text,integer)', 'EXECUTE') AS authenticated_pode_executar,
  has_function_privilege('anon', 'public.registrar_entrada_carga_mvp(uuid,date,text,integer)', 'EXECUTE') AS anon_pode_executar,
  has_function_privilege('public', 'public.registrar_entrada_carga_mvp(uuid,date,text,integer)', 'EXECUTE') AS public_pode_executar;
