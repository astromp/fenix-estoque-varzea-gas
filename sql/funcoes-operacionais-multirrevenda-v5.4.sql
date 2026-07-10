-- Projeto Fênix Estoque — V5.4
-- Funções operacionais multi-revenda.
--
-- ESTRATÉGIA SEGURA
-- 1. Cria novas sobrecargas exigindo p_revenda_id.
-- 2. Mantém temporariamente as funções antigas da Várzea Gás.
-- 3. Não altera nem apaga histórico.
-- 4. Após homologar a nova tela, as assinaturas antigas serão bloqueadas.
--
-- IMPORTANTE
-- Execute este arquivo inteiro no SQL Editor do Supabase.

begin;

CREATE OR REPLACE FUNCTION public.consultar_status_dia_mvp(p_revenda_id uuid, p_data_operacional date)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_dia_id uuid;
  v_status_dia text;
  v_abertura_ativa boolean;
  v_qtd_lancamentos integer;
  v_qtd_movimentos integer;
  v_status_fechamento text;
  v_qtd_itens_inconsistentes integer;
begin
  if p_revenda_id is null then
    raise exception 'Revenda é obrigatória.';
  end if;

  if not exists (
    select 1
    from revendas
    where id = p_revenda_id
      and ativa = true
  ) then
    raise exception 'Revenda não encontrada ou inativa.';
  end if;

  select id, status::text
  into v_dia_id, v_status_dia
  from dias_operacionais
  where revenda_id = p_revenda_id
    and data_operacional = p_data_operacional
  limit 1;

  if v_dia_id is null then
    return jsonb_build_object(
      'ok', true,
      'data_operacional', p_data_operacional,
      'status_dia', 'sem_abertura',
      'mensagem', 'Dia ainda sem abertura da manhã.',
      'dia_operacional_id', null,
      'abertura_ativa', false,
      'qtd_lancamentos', 0,
      'qtd_movimentos', 0,
      'status_fechamento', null,
      'itens_inconsistentes', 0,
      'pode_abrir', true,
      'pode_lancar_venda', false,
      'pode_fechar', false,
      'pode_corrigir', false
    );
  end if;

  select exists (
    select 1
    from conferencias_abertura
    where dia_operacional_id = v_dia_id
      and status::text <> 'cancelada'
  )
  into v_abertura_ativa;

  select count(*)
  into v_qtd_lancamentos
  from lancamentos
  where dia_operacional_id = v_dia_id
    and status::text = 'ativo';

  select count(*)
  into v_qtd_movimentos
  from movimentos_estoque
  where dia_operacional_id = v_dia_id
    and status::text = 'ativo';

  select status::text
  into v_status_fechamento
  from fechamentos
  where dia_operacional_id = v_dia_id
  limit 1;

  select count(*)
  into v_qtd_itens_inconsistentes
  from itens_fechamento i
  join fechamentos f on f.id = i.fechamento_id
  where f.dia_operacional_id = v_dia_id
    and i.status::text = 'inconsistente';

  return jsonb_build_object(
    'ok', true,
    'data_operacional', p_data_operacional,
    'dia_operacional_id', v_dia_id,
    'status_dia', v_status_dia,
    'mensagem', case
      when v_status_dia = 'fechado'
        then 'Dia fechado. Estoque fechado, turno encerrado.'
      when v_status_dia = 'inconsistente'
        then 'Dia inconsistente. Revisar até corrigir.'
      when v_status_dia = 'aberto'
        then 'Dia aberto para operação.'
      else 'Status do dia: ' || coalesce(v_status_dia, 'indefinido')
    end,
    'abertura_ativa', v_abertura_ativa,
    'qtd_lancamentos', v_qtd_lancamentos,
    'qtd_movimentos', v_qtd_movimentos,
    'status_fechamento', v_status_fechamento,
    'itens_inconsistentes', v_qtd_itens_inconsistentes,
    'pode_abrir', false,
    'pode_lancar_venda', v_status_dia = 'aberto',
    'pode_fechar', v_status_dia = 'aberto' or v_status_dia = 'inconsistente',
    'pode_corrigir', v_status_dia = 'inconsistente'
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.registrar_abertura_mvp(p_revenda_id uuid, p_data_operacional date, p_itens jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_dia_id uuid;
  v_status text;
  v_conferencia_id uuid;
  v_qtd_itens integer;
begin
  if p_itens is null or jsonb_typeof(p_itens) <> 'array' then
    raise exception 'Itens da abertura precisam ser enviados em formato de lista.';
  end if;

  if p_revenda_id is null then
    raise exception 'Revenda é obrigatória.';
  end if;

  if not exists (
    select 1
    from revendas
    where id = p_revenda_id
      and ativa = true
  ) then
    raise exception 'Revenda não encontrada ou inativa.';
  end if;

  select id, status::text
  into v_dia_id, v_status
  from dias_operacionais
  where revenda_id = p_revenda_id
    and data_operacional = p_data_operacional
  limit 1;

  if v_dia_id is not null and v_status = 'fechado' then
    raise exception 'Este dia operacional já está fechado. Não é possível registrar nova abertura.';
  end if;

  if v_dia_id is null then
    insert into dias_operacionais (
      revenda_id,
      data_operacional,
      status,
      observacao
    )
    values (
      p_revenda_id,
      p_data_operacional,
      'aberto',
      'MVP_CELULAR_ABERTURA_TESTE'
    )
    returning id into v_dia_id;
  end if;

  if exists (
    select 1
    from conferencias_abertura
    where dia_operacional_id = v_dia_id
      and status::text <> 'cancelada'
      and coalesce(observacao, '') <> 'MVP_CELULAR_ABERTURA_TESTE'
  ) then
    raise exception 'Já existe abertura não criada pelo teste MVP para este dia.';
  end if;

  update conferencias_abertura
  set status = 'cancelada',
      observacao = 'MVP_CELULAR_ABERTURA_TESTE_CANCELADA'
  where dia_operacional_id = v_dia_id
    and status::text <> 'cancelada'
    and observacao = 'MVP_CELULAR_ABERTURA_TESTE';

  insert into conferencias_abertura (
    dia_operacional_id,
    revenda_id,
    data_hora,
    status,
    observacao
  )
  values (
    v_dia_id,
    p_revenda_id,
    now(),
    'registrada',
    'MVP_CELULAR_ABERTURA_TESTE'
  )
  returning id into v_conferencia_id;

  insert into itens_conferencia_abertura (
    conferencia_abertura_id,
    produto_id,
    cheios_fisicos,
    vazios_fisicos
  )
  select
    v_conferencia_id,
    p.id,
    x.cheios,
    x.vazios
  from jsonb_to_recordset(p_itens) as x(
    codigo text,
    cheios integer,
    vazios integer
  )
  join produtos p
    on p.codigo = x.codigo
   and p.ativo = true
  where p.codigo in ('P13', 'P05', 'P20', 'P45', 'AGUA')
    and x.cheios >= 0
    and x.vazios >= 0;

  get diagnostics v_qtd_itens = row_count;

  if v_qtd_itens <> 5 then
    raise exception 'A abertura precisa conter exatamente os 5 produtos: P13, P05, P20, P45 e AGUA.';
  end if;

  return jsonb_build_object(
    'ok', true,
    'mensagem', 'Abertura da manhã registrada com sucesso.',
    'dia_operacional_id', v_dia_id,
    'conferencia_abertura_id', v_conferencia_id,
    'itens_registrados', v_qtd_itens
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.registrar_venda_mvp(p_revenda_id uuid, p_data_operacional date, p_canal_nome text, p_produto_codigo text, p_quantidade_liquido integer, p_quantidade_casco integer DEFAULT 0)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_dia_id uuid;
  v_dia_status text;
  v_produto_id uuid;
  v_canal_id uuid;
  v_lancamento_id uuid;
  v_movimento_liquido_id uuid;
  v_movimento_casco_id uuid;
begin
  if p_canal_nome is null or trim(p_canal_nome) = '' then
    raise exception 'Canal de venda é obrigatório.';
  end if;

  if p_produto_codigo is null or trim(p_produto_codigo) = '' then
    raise exception 'Produto é obrigatório.';
  end if;

  if p_quantidade_liquido is null or p_quantidade_liquido <= 0 then
    raise exception 'Quantidade vendida do líquido precisa ser maior que zero.';
  end if;

  if p_quantidade_casco is null then
    p_quantidade_casco := 0;
  end if;

  if p_quantidade_casco < 0 then
    raise exception 'Quantidade de casco não pode ser negativa.';
  end if;

  if p_quantidade_casco > p_quantidade_liquido then
    raise exception 'Quantidade de cascos vendidos não pode ser maior que a venda do líquido.';
  end if;

  if p_revenda_id is null then
    raise exception 'Revenda é obrigatória.';
  end if;

  if not exists (
    select 1
    from revendas
    where id = p_revenda_id
      and ativa = true
  ) then
    raise exception 'Revenda não encontrada ou inativa.';
  end if;

  select id, status::text
  into v_dia_id, v_dia_status
  from dias_operacionais
  where revenda_id = p_revenda_id
    and data_operacional = p_data_operacional
  limit 1;

  if v_dia_id is null then
    raise exception 'Dia operacional não encontrado. Faça a abertura da manhã antes de lançar venda.';
  end if;

  if v_dia_status = 'fechado' then
    raise exception 'Este dia operacional já está fechado. Não é possível lançar venda.';
  end if;

  if not exists (
    select 1
    from conferencias_abertura
    where dia_operacional_id = v_dia_id
      and status::text <> 'cancelada'
  ) then
    raise exception 'Não existe abertura da manhã ativa para este dia.';
  end if;

  select id
  into v_produto_id
  from produtos
  where codigo = upper(trim(p_produto_codigo))
    and ativo = true
  limit 1;

  if v_produto_id is null then
    raise exception 'Produto não encontrado ou inativo: %', p_produto_codigo;
  end if;

  select id
  into v_canal_id
  from canais_venda
  where revenda_id = p_revenda_id
    and nome = p_canal_nome
    and ativo = true
  limit 1;

  if v_canal_id is null then
    raise exception 'Canal de venda não encontrado ou inativo: %', p_canal_nome;
  end if;

  insert into lancamentos (
    dia_operacional_id,
    revenda_id,
    canal_venda_id,
    tipo_lancamento,
    data_hora,
    status,
    observacao
  )
  values (
    v_dia_id,
    p_revenda_id,
    v_canal_id,
    'venda',
    now(),
    'ativo',
    'MVP_CELULAR_VENDA_TESTE'
  )
  returning id into v_lancamento_id;

  insert into movimentos_estoque (
    lancamento_id,
    dia_operacional_id,
    revenda_id,
    produto_id,
    canal_venda_id,
    tipo_movimento,
    quantidade,
    status,
    observacao
  )
  values (
    v_lancamento_id,
    v_dia_id,
    p_revenda_id,
    v_produto_id,
    v_canal_id,
    'venda_liquido',
    p_quantidade_liquido,
    'ativo',
    'MVP_CELULAR_VENDA_LIQUIDO_TESTE'
  )
  returning id into v_movimento_liquido_id;

  if p_quantidade_casco > 0 then
    insert into movimentos_estoque (
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
    )
    values (
      v_lancamento_id,
      v_dia_id,
      p_revenda_id,
      v_produto_id,
      v_canal_id,
      'venda_casco',
      p_quantidade_casco,
      v_movimento_liquido_id,
      'ativo',
      'MVP_CELULAR_VENDA_CASCO_TESTE'
    )
    returning id into v_movimento_casco_id;
  end if;

  return jsonb_build_object(
    'ok', true,
    'mensagem', 'Venda registrada com sucesso.',
    'dia_operacional_id', v_dia_id,
    'lancamento_id', v_lancamento_id,
    'movimento_liquido_id', v_movimento_liquido_id,
    'movimento_casco_id', v_movimento_casco_id,
    'canal', p_canal_nome,
    'produto', upper(trim(p_produto_codigo)),
    'quantidade_liquido', p_quantidade_liquido,
    'quantidade_casco', p_quantidade_casco
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.consultar_estoque_mvp(p_revenda_id uuid, p_data_operacional date)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_dia_id uuid;
  v_resultado jsonb;
begin
  if p_revenda_id is null then
    raise exception 'Revenda é obrigatória.';
  end if;

  if not exists (
    select 1
    from revendas
    where id = p_revenda_id
      and ativa = true
  ) then
    raise exception 'Revenda não encontrada ou inativa.';
  end if;

  select id
  into v_dia_id
  from dias_operacionais
  where revenda_id = p_revenda_id
    and data_operacional = p_data_operacional
  limit 1;

  if v_dia_id is null then
    raise exception 'Dia operacional não encontrado para a data informada.';
  end if;

  with abertura as (
    select
      ica.produto_id,
      sum(ica.cheios_fisicos) as cheios_abertura,
      sum(ica.vazios_fisicos) as vazios_abertura
    from conferencias_abertura ca
    join itens_conferencia_abertura ica
      on ica.conferencia_abertura_id = ca.id
    where ca.dia_operacional_id = v_dia_id
      and ca.status::text <> 'cancelada'
    group by ica.produto_id
  ),
  movimentos as (
    select
      me.produto_id,
      sum(case
        when me.tipo_movimento::text = 'entrada_cheia' then me.quantidade
        when me.tipo_movimento::text = 'venda_liquido' then -me.quantidade
        else 0
      end) as delta_cheios,
      sum(case
        when me.tipo_movimento::text = 'entrada_cheia' then -me.quantidade
        when me.tipo_movimento::text = 'venda_liquido' then me.quantidade
        when me.tipo_movimento::text = 'venda_casco' then -me.quantidade
        else 0
      end) as delta_vazios
    from movimentos_estoque me
    where me.dia_operacional_id = v_dia_id
      and me.status::text = 'ativo'
    group by me.produto_id
  ),
  estoque as (
    select
      p.codigo,
      p.nome,
      coalesce(a.cheios_abertura, 0) as cheios_abertura,
      coalesce(a.vazios_abertura, 0) as vazios_abertura,
      coalesce(m.delta_cheios, 0) as delta_cheios,
      coalesce(m.delta_vazios, 0) as delta_vazios,
      coalesce(a.cheios_abertura, 0) + coalesce(m.delta_cheios, 0) as cheios_calculados,
      coalesce(a.vazios_abertura, 0) + coalesce(m.delta_vazios, 0) as vazios_calculados,
      (
        coalesce(a.cheios_abertura, 0)
        + coalesce(m.delta_cheios, 0)
        + coalesce(a.vazios_abertura, 0)
        + coalesce(m.delta_vazios, 0)
      ) as total_calculado
    from produtos p
    left join abertura a on a.produto_id = p.id
    left join movimentos m on m.produto_id = p.id
    where p.ativo = true
      and p.codigo in ('P13', 'P05', 'P20', 'P45', 'AGUA')
    order by p.ordem_exibicao
  )
  select jsonb_build_object(
    'ok', true,
    'data_operacional', p_data_operacional,
    'dia_operacional_id', v_dia_id,
    'itens', coalesce(jsonb_agg(
      jsonb_build_object(
        'produto', codigo,
        'nome', nome,
        'cheios_abertura', cheios_abertura,
        'vazios_abertura', vazios_abertura,
        'delta_cheios', delta_cheios,
        'delta_vazios', delta_vazios,
        'cheios_calculados', cheios_calculados,
        'vazios_calculados', vazios_calculados,
        'total_calculado', total_calculado
      )
    ), '[]'::jsonb)
  )
  into v_resultado
  from estoque;

  return v_resultado;
end;
$function$;

CREATE OR REPLACE FUNCTION public.registrar_fechamento_mvp(p_revenda_id uuid, p_data_operacional date, p_itens jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_dia_id uuid;
  v_dia_status text;
  v_fechamento_id uuid;
  v_qtd_itens integer;
  v_qtd_inconsistentes integer;
  v_status_fechamento text;
  v_resultado jsonb;
begin
  if p_itens is null or jsonb_typeof(p_itens) <> 'array' then
    raise exception 'Itens do fechamento precisam ser enviados em formato de lista.';
  end if;

  if p_revenda_id is null then
    raise exception 'Revenda é obrigatória.';
  end if;

  if not exists (
    select 1
    from revendas
    where id = p_revenda_id
      and ativa = true
  ) then
    raise exception 'Revenda não encontrada ou inativa.';
  end if;

  select id, status::text into v_dia_id, v_dia_status
  from dias_operacionais
  where revenda_id = p_revenda_id
    and data_operacional = p_data_operacional
  limit 1;

  if v_dia_id is null then
    raise exception 'Dia operacional não encontrado. Faça a abertura da manhã antes do fechamento.';
  end if;

  if v_dia_status = 'fechado' then
    raise exception 'Este dia operacional já está fechado.';
  end if;

  if not exists (
    select 1
    from conferencias_abertura
    where dia_operacional_id = v_dia_id
      and status::text <> 'cancelada'
  ) then
    raise exception 'Não existe abertura da manhã ativa para este dia.';
  end if;

  create temporary table tmp_fechamento_mvp (
    produto_id uuid,
    codigo text,
    cheios_fisicos integer,
    vazios_fisicos integer,
    cheios_calculados integer,
    vazios_calculados integer,
    status_item text
  ) on commit drop;

  insert into tmp_fechamento_mvp (
    produto_id,
    codigo,
    cheios_fisicos,
    vazios_fisicos
  )
  select
    p.id,
    upper(trim(x.codigo)),
    x.cheios,
    x.vazios
  from jsonb_to_recordset(p_itens) as x(
    codigo text,
    cheios integer,
    vazios integer
  )
  join produtos p
    on p.codigo = upper(trim(x.codigo))
   and p.ativo = true
  where p.codigo in ('P13', 'P05', 'P20', 'P45', 'AGUA')
    and x.cheios >= 0
    and x.vazios >= 0;

  get diagnostics v_qtd_itens = row_count;

  if v_qtd_itens <> 5 then
    raise exception 'O fechamento precisa conter exatamente os 5 produtos: P13, P05, P20, P45 e AGUA.';
  end if;

  with abertura as (
    select
      ica.produto_id,
      sum(ica.cheios_fisicos) as cheios_abertura,
      sum(ica.vazios_fisicos) as vazios_abertura
    from conferencias_abertura ca
    join itens_conferencia_abertura ica
      on ica.conferencia_abertura_id = ca.id
    where ca.dia_operacional_id = v_dia_id
      and ca.status::text <> 'cancelada'
    group by ica.produto_id
  ),
  movimentos as (
    select
      me.produto_id,
      sum(case
        when me.tipo_movimento::text = 'entrada_cheia' then me.quantidade
        when me.tipo_movimento::text = 'venda_liquido' then -me.quantidade
        else 0
      end) as delta_cheios,
      sum(case
        when me.tipo_movimento::text = 'entrada_cheia' then -me.quantidade
        when me.tipo_movimento::text = 'venda_liquido' then me.quantidade
        when me.tipo_movimento::text = 'venda_casco' then -me.quantidade
        else 0
      end) as delta_vazios
    from movimentos_estoque me
    where me.dia_operacional_id = v_dia_id
      and me.status::text = 'ativo'
    group by me.produto_id
  ),
  calculado as (
    select
      t.produto_id,
      coalesce(a.cheios_abertura, 0) + coalesce(m.delta_cheios, 0) as cheios_calculados,
      coalesce(a.vazios_abertura, 0) + coalesce(m.delta_vazios, 0) as vazios_calculados
    from tmp_fechamento_mvp t
    left join abertura a on a.produto_id = t.produto_id
    left join movimentos m on m.produto_id = t.produto_id
  )
  update tmp_fechamento_mvp t
  set
    cheios_calculados = c.cheios_calculados,
    vazios_calculados = c.vazios_calculados,
    status_item = case
      when t.cheios_fisicos = c.cheios_calculados
       and t.vazios_fisicos = c.vazios_calculados
       and (t.cheios_fisicos + t.vazios_fisicos) = (c.cheios_calculados + c.vazios_calculados)
      then 'conferido'
      else 'inconsistente'
    end
  from calculado c
  where c.produto_id = t.produto_id;

  select count(*) into v_qtd_inconsistentes
  from tmp_fechamento_mvp
  where status_item = 'inconsistente';

  if v_qtd_inconsistentes = 0 then
    v_status_fechamento := 'conferido';
  else
    v_status_fechamento := 'inconsistente';
  end if;

  select id into v_fechamento_id
  from fechamentos
  where dia_operacional_id = v_dia_id
  limit 1;

  if v_fechamento_id is null then
    insert into fechamentos (
      dia_operacional_id,
      revenda_id,
      data_hora_inicio,
      data_hora_fim,
      status,
      observacao
    )
    values (
      v_dia_id,
      p_revenda_id,
      now(),
      now(),
      v_status_fechamento,
      'MVP_CELULAR_FECHAMENTO_TESTE'
    )
    returning id into v_fechamento_id;
  else
    update fechamentos
    set
      data_hora_fim = now(),
      status = v_status_fechamento,
      observacao = 'MVP_CELULAR_FECHAMENTO_REFEITO_TESTE'
    where id = v_fechamento_id;
  end if;

  delete from itens_fechamento
  where fechamento_id = v_fechamento_id;

  insert into itens_fechamento (
    fechamento_id,
    produto_id,
    cheios_calculados,
    vazios_calculados,
    cheios_fisicos,
    vazios_fisicos,
    status,
    observacao
  )
  select
    v_fechamento_id,
    produto_id,
    cheios_calculados,
    vazios_calculados,
    cheios_fisicos,
    vazios_fisicos,
    status_item,
    'MVP_CELULAR_FECHAMENTO_ITEM_TESTE'
  from tmp_fechamento_mvp;

  if v_qtd_inconsistentes = 0 then
    update dias_operacionais
    set status = 'fechado',
        fechado_em = now(),
        observacao = 'MVP_CELULAR_DIA_FECHADO_TESTE'
    where id = v_dia_id;
  else
    update dias_operacionais
    set status = 'inconsistente',
        observacao = 'MVP_CELULAR_DIA_INCONSISTENTE_TESTE'
    where id = v_dia_id;
  end if;

  select jsonb_build_object(
    'ok', true,
    'mensagem', case
      when v_qtd_inconsistentes = 0
      then 'Fechamento conferido com sucesso. Estoque fechado, turno encerrado.'
      else 'Estoque inconsistente. Revisar até corrigir.'
    end,
    'dia_operacional_id', v_dia_id,
    'fechamento_id', v_fechamento_id,
    'status_fechamento', v_status_fechamento,
    'itens_registrados', v_qtd_itens,
    'itens_inconsistentes', v_qtd_inconsistentes,
    'itens', coalesce(jsonb_agg(
      jsonb_build_object(
        'produto', codigo,
        'cheios_calculados', cheios_calculados,
        'vazios_calculados', vazios_calculados,
        'total_calculado', cheios_calculados + vazios_calculados,
        'cheios_fisicos', cheios_fisicos,
        'vazios_fisicos', vazios_fisicos,
        'total_fisico', cheios_fisicos + vazios_fisicos,
        'diferenca_cheios', cheios_fisicos - cheios_calculados,
        'diferenca_vazios', vazios_fisicos - vazios_calculados,
        'diferenca_total', (cheios_fisicos + vazios_fisicos) - (cheios_calculados + vazios_calculados),
        'status', status_item
      )
      order by codigo
    ), '[]'::jsonb)
  )
  into v_resultado
  from tmp_fechamento_mvp;

  return v_resultado;
end;
$function$;

CREATE OR REPLACE FUNCTION public.registrar_correcao_venda_casco_mvp(p_revenda_id uuid, p_data_operacional date, p_canal_nome text, p_produto_codigo text, p_quantidade integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_dia_id uuid;
  v_dia_status text;
  v_produto_id uuid;
  v_canal_id uuid;
  v_lancamento_id uuid;
  v_movimento_liquido_id uuid;
  v_movimento_casco_id uuid;
begin
  if p_quantidade is null or p_quantidade <= 0 then
    raise exception 'Quantidade da correção precisa ser maior que zero.';
  end if;

  if p_revenda_id is null then
    raise exception 'Revenda é obrigatória.';
  end if;

  if not exists (
    select 1
    from revendas
    where id = p_revenda_id
      and ativa = true
  ) then
    raise exception 'Revenda não encontrada ou inativa.';
  end if;

  select id, status::text into v_dia_id, v_dia_status
  from dias_operacionais
  where revenda_id = p_revenda_id
    and data_operacional = p_data_operacional
  limit 1;

  if v_dia_id is null then
    raise exception 'Dia operacional não encontrado.';
  end if;

  if v_dia_status = 'fechado' then
    raise exception 'Este dia já está fechado. Não é possível registrar correção.';
  end if;

  if v_dia_status <> 'inconsistente' then
    raise exception 'Correção só deve ser usada quando o dia estiver inconsistente. Status atual: %', v_dia_status;
  end if;

  select id into v_produto_id
  from produtos
  where codigo = upper(trim(p_produto_codigo))
    and ativo = true
  limit 1;

  if v_produto_id is null then
    raise exception 'Produto não encontrado ou inativo: %', p_produto_codigo;
  end if;

  select id into v_canal_id
  from canais_venda
  where revenda_id = p_revenda_id
    and nome = p_canal_nome
    and ativo = true
  limit 1;

  if v_canal_id is null then
    raise exception 'Canal de venda não encontrado ou inativo: %', p_canal_nome;
  end if;

  update movimentos_estoque me
  set status = 'cancelado',
      observacao = coalesce(me.observacao, '') || ' | CANCELADO_POR_NOVA_CORRECAO_MVP'
  from lancamentos l
  where me.lancamento_id = l.id
    and l.dia_operacional_id = v_dia_id
    and l.observacao = 'MVP_CORRECAO_VENDA_COM_CASCO_NAO_LANCADA'
    and me.status::text = 'ativo';

  update lancamentos
  set status = 'cancelado',
      observacao = 'MVP_CORRECAO_VENDA_COM_CASCO_NAO_LANCADA_CANCELADA'
  where dia_operacional_id = v_dia_id
    and observacao = 'MVP_CORRECAO_VENDA_COM_CASCO_NAO_LANCADA'
    and status::text = 'ativo';

  insert into lancamentos (
    dia_operacional_id,
    revenda_id,
    canal_venda_id,
    tipo_lancamento,
    data_hora,
    status,
    observacao
  )
  values (
    v_dia_id,
    p_revenda_id,
    v_canal_id,
    'venda',
    now(),
    'ativo',
    'MVP_CORRECAO_VENDA_COM_CASCO_NAO_LANCADA'
  )
  returning id into v_lancamento_id;

  insert into movimentos_estoque (
    lancamento_id,
    dia_operacional_id,
    revenda_id,
    produto_id,
    canal_venda_id,
    tipo_movimento,
    quantidade,
    status,
    observacao
  )
  values (
    v_lancamento_id,
    v_dia_id,
    p_revenda_id,
    v_produto_id,
    v_canal_id,
    'venda_liquido',
    p_quantidade,
    'ativo',
    'CORRECAO_VENDA_LIQUIDO_NAO_LANCADA'
  )
  returning id into v_movimento_liquido_id;

  insert into movimentos_estoque (
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
  )
  values (
    v_lancamento_id,
    v_dia_id,
    p_revenda_id,
    v_produto_id,
    v_canal_id,
    'venda_casco',
    p_quantidade,
    v_movimento_liquido_id,
    'ativo',
    'CORRECAO_VENDA_CASCO_NAO_LANCADA'
  )
  returning id into v_movimento_casco_id;

  return jsonb_build_object(
    'ok', true,
    'mensagem', 'Correção registrada com sucesso. Refaça o fechamento para conferir o estoque.',
    'dia_operacional_id', v_dia_id,
    'lancamento_correcao_id', v_lancamento_id,
    'movimento_liquido_id', v_movimento_liquido_id,
    'movimento_casco_id', v_movimento_casco_id,
    'canal', p_canal_nome,
    'produto', upper(trim(p_produto_codigo)),
    'quantidade_corrigida', p_quantidade,
    'tipo_correcao', 'venda_com_casco_nao_lancada'
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.consultar_vendas_dia_mvp(p_revenda_id uuid, p_data_operacional date)
 RETURNS TABLE(lancamento_id uuid, data_operacional date, data_hora timestamp with time zone, canal_venda_id uuid, canal_venda text, produto_id uuid, produto_codigo text, produto_nome text, produto_ordem integer, quantidade_liquido bigint, quantidade_casco bigint, tipo_lancamento text)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select
    l.id as lancamento_id,
    d.data_operacional,
    l.data_hora,
    l.canal_venda_id,
    c.nome as canal_venda,
    p.id as produto_id,
    p.codigo as produto_codigo,
    p.nome as produto_nome,
    p.ordem_exibicao as produto_ordem,

    coalesce(
      sum(m.quantidade)
        filter (where m.tipo_movimento = 'venda_liquido'),
      0
    )::bigint as quantidade_liquido,

    coalesce(
      sum(m.quantidade)
        filter (where m.tipo_movimento = 'venda_casco'),
      0
    )::bigint as quantidade_casco,

    l.tipo_lancamento

  from public.dias_operacionais d

  join public.lancamentos l
    on l.dia_operacional_id = d.id

  join public.movimentos_estoque m
    on m.lancamento_id = l.id

  join public.produtos p
    on p.id = m.produto_id

  left join public.canais_venda c
    on c.id = l.canal_venda_id

  where d.revenda_id = p_revenda_id
    and l.revenda_id = p_revenda_id
    and m.revenda_id = p_revenda_id
    and d.data_operacional = p_data_operacional
    and l.status = 'ativo'
    and m.status = 'ativo'
    and l.tipo_lancamento in ('venda', 'correcao')
    and m.tipo_movimento in ('venda_liquido', 'venda_casco')

  group by
    l.id,
    d.data_operacional,
    l.data_hora,
    l.canal_venda_id,
    c.nome,
    p.id,
    p.codigo,
    p.nome,
    p.ordem_exibicao,
    l.tipo_lancamento

  having
    coalesce(
      sum(m.quantidade)
        filter (where m.tipo_movimento = 'venda_liquido'),
      0
    ) > 0
    or
    coalesce(
      sum(m.quantidade)
        filter (where m.tipo_movimento = 'venda_casco'),
      0
    ) > 0

  order by
    l.data_hora,
    l.id,
    p.ordem_exibicao;
$function$;

-- Permissões das novas assinaturas.
grant execute on function public.consultar_estoque_mvp(uuid, date) to anon, authenticated;
grant execute on function public.consultar_status_dia_mvp(uuid, date) to anon, authenticated;
grant execute on function public.consultar_vendas_dia_mvp(uuid, date) to anon, authenticated;
grant execute on function public.registrar_abertura_mvp(uuid, date, jsonb) to anon, authenticated;
grant execute on function public.registrar_correcao_venda_casco_mvp(uuid, date, text, text, integer) to anon, authenticated;
grant execute on function public.registrar_fechamento_mvp(uuid, date, jsonb) to anon, authenticated;
grant execute on function public.registrar_venda_mvp(uuid, date, text, text, integer, integer) to anon, authenticated;

commit;

-- CONFERÊNCIA: devem aparecer as sete funções com p_revenda_id uuid.
select
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as arguments,
  p.prosecdef as security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'consultar_status_dia_mvp',
    'registrar_abertura_mvp',
    'registrar_venda_mvp',
    'consultar_estoque_mvp',
    'registrar_fechamento_mvp',
    'registrar_correcao_venda_casco_mvp',
    'consultar_vendas_dia_mvp'
  )
  and pg_get_function_identity_arguments(p.oid) like 'p_revenda_id uuid%'
order by p.proname;
