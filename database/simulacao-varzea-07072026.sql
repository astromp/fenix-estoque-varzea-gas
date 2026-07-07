-- Projeto Fênix Estoque — Simulação Várzea Gás 07/07/2026
-- Banco: Supabase / PostgreSQL
-- Objetivo: testar abertura, vendas, fechamento e divergência de P45.

-- ATENÇÃO:
-- Este script apaga e recria a simulação do dia 07/07/2026 para a revenda Várzea Gás.
-- Use apenas em ambiente de teste/piloto.

begin;

-- =========================================================
-- Limpeza da simulação, se já existir
-- =========================================================

do $$
declare
  v_dia_id uuid;
begin
  select d.id
  into v_dia_id
  from public.dias_operacionais d
  join public.revendas r on r.id = d.revenda_id
  where r.nome = 'Várzea Gás'
    and d.data_operacional = date '2026-07-07';

  if v_dia_id is not null then
    delete from public.correcoes
    where lancamento_original_id in (select id from public.lancamentos where dia_operacional_id = v_dia_id)
       or lancamento_correcao_id in (select id from public.lancamentos where dia_operacional_id = v_dia_id)
       or movimento_original_id in (select id from public.movimentos_estoque where dia_operacional_id = v_dia_id)
       or movimento_correcao_id in (select id from public.movimentos_estoque where dia_operacional_id = v_dia_id);

    delete from public.divergencias_fechamento
    where fechamento_id in (select id from public.fechamentos where dia_operacional_id = v_dia_id);

    delete from public.itens_fechamento
    where fechamento_id in (select id from public.fechamentos where dia_operacional_id = v_dia_id);

    delete from public.fechamentos
    where dia_operacional_id = v_dia_id;

    delete from public.movimentos_estoque
    where dia_operacional_id = v_dia_id;

    delete from public.lancamentos
    where dia_operacional_id = v_dia_id;

    delete from public.itens_conferencia_abertura
    where conferencia_abertura_id in (
      select id from public.conferencias_abertura where dia_operacional_id = v_dia_id
    );

    delete from public.conferencias_abertura
    where dia_operacional_id = v_dia_id;

    delete from public.dias_operacionais
    where id = v_dia_id;
  end if;
end $$;

-- =========================================================
-- Criação do dia operacional e abertura da manhã
-- =========================================================

with base as (
  select
    r.id as revenda_id,
    u.id as usuario_id
  from public.revendas r
  cross join lateral (
    select id from public.usuarios
    where nome = 'Operador Várzea Gás'
    order by created_at asc
    limit 1
  ) u
  where r.nome = 'Várzea Gás'
), dia as (
  insert into public.dias_operacionais (
    revenda_id,
    data_operacional,
    status,
    aberto_por_usuario_id,
    aberto_em,
    observacao
  )
  select
    revenda_id,
    date '2026-07-07',
    'aberto',
    usuario_id,
    timestamp with time zone '2026-07-07 07:00:00-03',
    'Simulação oficial da operação da Várzea Gás'
  from base
  returning id, revenda_id, aberto_por_usuario_id as usuario_id
), abertura as (
  insert into public.conferencias_abertura (
    dia_operacional_id,
    revenda_id,
    usuario_id,
    data_hora,
    status,
    observacao
  )
  select
    id,
    revenda_id,
    usuario_id,
    timestamp with time zone '2026-07-07 07:05:00-03',
    'registrada',
    'Abertura da manhã da simulação'
  from dia
  returning id as conferencia_abertura_id
)
insert into public.itens_conferencia_abertura (
  conferencia_abertura_id,
  produto_id,
  cheios_fisicos,
  vazios_fisicos
)
select
  a.conferencia_abertura_id,
  p.id,
  x.cheios,
  x.vazios
from abertura a
join (
  values
    ('P13', 100, 30),
    ('P05', 10, 5),
    ('P20', 10, 2),
    ('P45', 10, 10),
    ('AGUA', 50, 10)
) as x(codigo, cheios, vazios) on true
join public.produtos p on p.codigo = x.codigo;

-- =========================================================
-- Vendas do dia
-- =========================================================

do $$
declare
  v_revenda_id uuid;
  v_usuario_id uuid;
  v_dia_id uuid;
  v_lancamento_id uuid;
  v_mov_liquido_id uuid;
begin
  select id into v_revenda_id from public.revendas where nome = 'Várzea Gás';

  select id into v_usuario_id
  from public.usuarios
  where nome = 'Operador Várzea Gás'
  order by created_at asc
  limit 1;

  select id into v_dia_id
  from public.dias_operacionais
  where revenda_id = v_revenda_id
    and data_operacional = date '2026-07-07';

  -- Portaria: 10 P13, 1 P05, 1 P20, 2 P45
  insert into public.lancamentos (dia_operacional_id, revenda_id, usuario_id, canal_venda_id, tipo_lancamento, data_hora, observacao)
  select v_dia_id, v_revenda_id, v_usuario_id, c.id, 'venda', timestamp with time zone '2026-07-07 08:30:00-03', 'Portaria: vendas da simulação'
  from public.canais_venda c
  where c.revenda_id = v_revenda_id and c.nome = 'Portaria'
  returning id into v_lancamento_id;

  insert into public.movimentos_estoque (lancamento_id, dia_operacional_id, revenda_id, produto_id, canal_venda_id, usuario_id, tipo_movimento, quantidade)
  select v_lancamento_id, v_dia_id, v_revenda_id, p.id, c.id, v_usuario_id, 'venda_liquido', x.quantidade
  from (
    values
      ('P13', 10),
      ('P05', 1),
      ('P20', 1),
      ('P45', 2)
  ) as x(codigo, quantidade)
  join public.produtos p on p.codigo = x.codigo
  join public.canais_venda c on c.revenda_id = v_revenda_id and c.nome = 'Portaria';

  -- Rogério: 20 P13, 1 P20, 1 P45
  insert into public.lancamentos (dia_operacional_id, revenda_id, usuario_id, canal_venda_id, tipo_lancamento, data_hora, observacao)
  select v_dia_id, v_revenda_id, v_usuario_id, c.id, 'venda', timestamp with time zone '2026-07-07 09:10:00-03', 'Rogério: vendas da simulação'
  from public.canais_venda c
  where c.revenda_id = v_revenda_id and c.nome = 'Rogério'
  returning id into v_lancamento_id;

  insert into public.movimentos_estoque (lancamento_id, dia_operacional_id, revenda_id, produto_id, canal_venda_id, usuario_id, tipo_movimento, quantidade)
  select v_lancamento_id, v_dia_id, v_revenda_id, p.id, c.id, v_usuario_id, 'venda_liquido', x.quantidade
  from (
    values
      ('P13', 20),
      ('P20', 1),
      ('P45', 1)
  ) as x(codigo, quantidade)
  join public.produtos p on p.codigo = x.codigo
  join public.canais_venda c on c.revenda_id = v_revenda_id and c.nome = 'Rogério';

  -- André: 10 P13
  insert into public.lancamentos (dia_operacional_id, revenda_id, usuario_id, canal_venda_id, tipo_lancamento, data_hora, observacao)
  select v_dia_id, v_revenda_id, v_usuario_id, c.id, 'venda', timestamp with time zone '2026-07-07 09:40:00-03', 'André: venda da simulação'
  from public.canais_venda c
  where c.revenda_id = v_revenda_id and c.nome = 'André'
  returning id into v_lancamento_id;

  insert into public.movimentos_estoque (lancamento_id, dia_operacional_id, revenda_id, produto_id, canal_venda_id, usuario_id, tipo_movimento, quantidade)
  select v_lancamento_id, v_dia_id, v_revenda_id, p.id, c.id, v_usuario_id, 'venda_liquido', 10
  from public.produtos p
  join public.canais_venda c on c.revenda_id = v_revenda_id and c.nome = 'André'
  where p.codigo = 'P13';

  -- João: 10 P13, sendo 1 com casco
  insert into public.lancamentos (dia_operacional_id, revenda_id, usuario_id, canal_venda_id, tipo_lancamento, data_hora, observacao)
  select v_dia_id, v_revenda_id, v_usuario_id, c.id, 'venda', timestamp with time zone '2026-07-07 10:15:00-03', 'João: 10 P13, sendo 1 com casco'
  from public.canais_venda c
  where c.revenda_id = v_revenda_id and c.nome = 'João'
  returning id into v_lancamento_id;

  insert into public.movimentos_estoque (lancamento_id, dia_operacional_id, revenda_id, produto_id, canal_venda_id, usuario_id, tipo_movimento, quantidade)
  select v_lancamento_id, v_dia_id, v_revenda_id, p.id, c.id, v_usuario_id, 'venda_liquido', 10
  from public.produtos p
  join public.canais_venda c on c.revenda_id = v_revenda_id and c.nome = 'João'
  where p.codigo = 'P13'
  returning id into v_mov_liquido_id;

  insert into public.movimentos_estoque (lancamento_id, dia_operacional_id, revenda_id, produto_id, canal_venda_id, usuario_id, tipo_movimento, quantidade, movimento_vinculado_id)
  select v_lancamento_id, v_dia_id, v_revenda_id, p.id, c.id, v_usuario_id, 'venda_casco', 1, v_mov_liquido_id
  from public.produtos p
  join public.canais_venda c on c.revenda_id = v_revenda_id and c.nome = 'João'
  where p.codigo = 'P13';
end $$;

-- =========================================================
-- Fechamento da noite
-- Calculado:
-- P13 50/79, P05 9/6, P20 8/4, P45 7/13, Água 50/10.
-- Físico informado:
-- P13 50/79, P05 9/6, P20 8/4, P45 6/13, Água 50/10.
-- =========================================================

with base as (
  select
    r.id as revenda_id,
    d.id as dia_id,
    u.id as usuario_id
  from public.revendas r
  join public.dias_operacionais d on d.revenda_id = r.id and d.data_operacional = date '2026-07-07'
  cross join lateral (
    select id from public.usuarios
    where nome = 'Operador Várzea Gás'
    order by created_at asc
    limit 1
  ) u
  where r.nome = 'Várzea Gás'
), fechamento as (
  insert into public.fechamentos (
    dia_operacional_id,
    revenda_id,
    usuario_id,
    data_hora_inicio,
    data_hora_fim,
    status,
    observacao
  )
  select
    dia_id,
    revenda_id,
    usuario_id,
    timestamp with time zone '2026-07-07 20:00:00-03',
    timestamp with time zone '2026-07-07 20:20:00-03',
    'inconsistente',
    'Fechamento da simulação com divergência em P45'
  from base
  returning id as fechamento_id
)
insert into public.itens_fechamento (
  fechamento_id,
  produto_id,
  cheios_calculados,
  vazios_calculados,
  cheios_fisicos,
  vazios_fisicos,
  status
)
select
  f.fechamento_id,
  p.id,
  x.cheios_calculados,
  x.vazios_calculados,
  x.cheios_fisicos,
  x.vazios_fisicos,
  case
    when x.cheios_calculados = x.cheios_fisicos
     and x.vazios_calculados = x.vazios_fisicos
    then 'conferido'
    else 'inconsistente'
  end as status
from fechamento f
join (
  values
    ('P13', 50, 79, 50, 79),
    ('P05', 9, 6, 9, 6),
    ('P20', 8, 4, 8, 4),
    ('P45', 7, 13, 6, 13),
    ('AGUA', 50, 10, 50, 10)
) as x(codigo, cheios_calculados, vazios_calculados, cheios_fisicos, vazios_fisicos) on true
join public.produtos p on p.codigo = x.codigo;

-- Divergência do P45

insert into public.divergencias_fechamento (
  fechamento_id,
  item_fechamento_id,
  produto_id,
  tipo_divergencia,
  diferenca_cheios,
  diferenca_vazios,
  diferenca_total,
  hipotese_provavel,
  prioridade_revisao,
  status
)
select
  f.id,
  i.id,
  p.id,
  'divergencia_combinada',
  i.diferenca_cheios,
  i.diferenca_vazios,
  i.diferenca_total,
  'Provável venda de casco de P45 não lançada.',
  '1. Recontar P45 cheio. 2. Revisar vendas de P45 da Portaria e Rogério. 3. Verificar venda de casco não lançada.',
  'pendente'
from public.fechamentos f
join public.itens_fechamento i on i.fechamento_id = f.id
join public.produtos p on p.id = i.produto_id
join public.dias_operacionais d on d.id = f.dia_operacional_id
join public.revendas r on r.id = f.revenda_id
where r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07'
  and p.codigo = 'P45'
  and i.status = 'inconsistente';

update public.dias_operacionais d
set
  status = 'inconsistente',
  fechado_por_usuario_id = (
    select id from public.usuarios
    where nome = 'Operador Várzea Gás'
    order by created_at asc
    limit 1
  ),
  fechado_em = timestamp with time zone '2026-07-07 20:20:00-03'
from public.revendas r
where d.revenda_id = r.id
  and r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07';

commit;

-- =========================================================
-- Resultado esperado do fechamento
-- =========================================================

select
  p.codigo as produto,
  i.cheios_calculados,
  i.vazios_calculados,
  i.total_calculado,
  i.cheios_fisicos,
  i.vazios_fisicos,
  i.total_fisico,
  i.diferenca_cheios,
  i.diferenca_vazios,
  i.diferenca_total,
  i.status
from public.itens_fechamento i
join public.produtos p on p.id = i.produto_id
join public.fechamentos f on f.id = i.fechamento_id
join public.dias_operacionais d on d.id = f.dia_operacional_id
join public.revendas r on r.id = f.revenda_id
where r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07'
order by p.ordem_exibicao;

-- =========================================================
-- Relatório diário por canal de venda
-- =========================================================

select
  c.nome as canal_venda,
  p.codigo as produto,
  m.tipo_movimento,
  sum(m.quantidade) as quantidade
from public.movimentos_estoque m
join public.canais_venda c on c.id = m.canal_venda_id
join public.produtos p on p.id = m.produto_id
join public.dias_operacionais d on d.id = m.dia_operacional_id
join public.revendas r on r.id = m.revenda_id
where r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07'
  and m.status = 'ativo'
group by c.nome, p.codigo, p.ordem_exibicao, m.tipo_movimento
order by c.nome, p.ordem_exibicao, m.tipo_movimento;
