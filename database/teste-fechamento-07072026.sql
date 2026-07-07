-- Projeto Fênix Estoque — Teste 8: fechamento físico da noite
-- Banco: Supabase / PostgreSQL
-- Objetivo: registrar fechamento físico, comparar calculado x físico e apontar divergência.

-- Fechamento físico informado:
-- P13: 50 cheios / 79 vazios
-- P05: 9 cheios / 6 vazios
-- P20: 8 cheios / 4 vazios
-- P45: 6 cheios / 13 vazios
-- AGUA: 50 cheios / 10 vazios

-- Resultado esperado:
-- P45 inconsistente: -1 cheio, 0 vazio, -1 total.

-- 1. Criar ou atualizar o fechamento do dia
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
  d.id,
  r.id,
  u.id,
  timestamp with time zone '2026-07-07 20:00:00-03',
  timestamp with time zone '2026-07-07 20:20:00-03',
  'inconsistente',
  'Fechamento físico da simulação com divergência em P45'
from public.revendas r
join public.dias_operacionais d
  on d.revenda_id = r.id
 and d.data_operacional = date '2026-07-07'
cross join lateral (
  select id
  from public.usuarios
  where nome = 'Operador Várzea Gás'
  order by created_at asc
  limit 1
) u
where r.nome = 'Várzea Gás'
on conflict (dia_operacional_id) do update set
  data_hora_inicio = excluded.data_hora_inicio,
  data_hora_fim = excluded.data_hora_fim,
  status = excluded.status,
  observacao = excluded.observacao;

-- 2. Apagar divergências antigas deste fechamento para recalcular
with fechamento_dia as (
  select f.id as fechamento_id
  from public.fechamentos f
  join public.dias_operacionais d on d.id = f.dia_operacional_id
  join public.revendas r on r.id = f.revenda_id
  where r.nome = 'Várzea Gás'
    and d.data_operacional = date '2026-07-07'
)
delete from public.divergencias_fechamento df
where df.fechamento_id in (select fechamento_id from fechamento_dia);

-- 3. Calcular estoque esperado e gravar itens do fechamento
with abertura as (
  select
    p.id as produto_id,
    p.codigo,
    p.ordem_exibicao,
    i.cheios_fisicos as cheios_abertura,
    i.vazios_fisicos as vazios_abertura
  from public.itens_conferencia_abertura i
  join public.produtos p on p.id = i.produto_id
  join public.conferencias_abertura ca on ca.id = i.conferencia_abertura_id
  join public.dias_operacionais d on d.id = ca.dia_operacional_id
  join public.revendas r on r.id = d.revenda_id
  where r.nome = 'Várzea Gás'
    and d.data_operacional = date '2026-07-07'
), movimentos as (
  select
    m.produto_id,
    sum(case when m.tipo_movimento = 'entrada_cheia' then m.quantidade else 0 end) as entradas_cheias,
    sum(case when m.tipo_movimento = 'venda_liquido' then m.quantidade else 0 end) as vendas_liquido,
    sum(case when m.tipo_movimento = 'venda_casco' then m.quantidade else 0 end) as vendas_casco
  from public.movimentos_estoque m
  join public.dias_operacionais d on d.id = m.dia_operacional_id
  join public.revendas r on r.id = m.revenda_id
  where r.nome = 'Várzea Gás'
    and d.data_operacional = date '2026-07-07'
    and m.status = 'ativo'
  group by m.produto_id
), calculado as (
  select
    a.produto_id,
    a.codigo,
    (a.cheios_abertura + coalesce(m.entradas_cheias, 0) - coalesce(m.vendas_liquido, 0)) as cheios_calculados,
    (a.vazios_abertura - coalesce(m.entradas_cheias, 0) + coalesce(m.vendas_liquido, 0) - coalesce(m.vendas_casco, 0)) as vazios_calculados
  from abertura a
  left join movimentos m on m.produto_id = a.produto_id
), fisico as (
  select *
  from (
    values
      ('P13', 50, 79),
      ('P05', 9, 6),
      ('P20', 8, 4),
      ('P45', 6, 13),
      ('AGUA', 50, 10)
  ) as x(codigo, cheios_fisicos, vazios_fisicos)
), fechamento_dia as (
  select f.id as fechamento_id
  from public.fechamentos f
  join public.dias_operacionais d on d.id = f.dia_operacional_id
  join public.revendas r on r.id = f.revenda_id
  where r.nome = 'Várzea Gás'
    and d.data_operacional = date '2026-07-07'
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
  c.produto_id,
  c.cheios_calculados,
  c.vazios_calculados,
  fi.cheios_fisicos,
  fi.vazios_fisicos,
  case
    when c.cheios_calculados = fi.cheios_fisicos
     and c.vazios_calculados = fi.vazios_fisicos
    then 'conferido'
    else 'inconsistente'
  end as status
from calculado c
join fisico fi on fi.codigo = c.codigo
cross join fechamento_dia f
on conflict (fechamento_id, produto_id) do update set
  cheios_calculados = excluded.cheios_calculados,
  vazios_calculados = excluded.vazios_calculados,
  cheios_fisicos = excluded.cheios_fisicos,
  vazios_fisicos = excluded.vazios_fisicos,
  status = excluded.status;

-- 4. Registrar divergências encontradas
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
  i.produto_id,
  case
    when i.diferenca_cheios <> 0 and i.diferenca_vazios <> 0 then 'divergencia_combinada'
    when i.diferenca_cheios <> 0 and i.diferenca_total <> 0 then 'divergencia_combinada'
    when i.diferenca_cheios <> 0 then 'diferenca_cheio'
    when i.diferenca_vazios <> 0 then 'diferenca_vazio'
    else 'diferenca_total_cascos'
  end as tipo_divergencia,
  i.diferenca_cheios,
  i.diferenca_vazios,
  i.diferenca_total,
  case
    when i.diferenca_cheios < 0 and i.diferenca_vazios = 0 and i.diferenca_total < 0
    then 'Provável venda de casco não lançada.'
    else 'Revisar contagem física e lançamentos do produto.'
  end as hipotese_provavel,
  case
    when i.diferenca_cheios < 0 and i.diferenca_vazios = 0 and i.diferenca_total < 0
    then '1. Recontar cheios. 2. Revisar vendas de casco. 3. Revisar canais que venderam o produto.'
    else '1. Recontar produto. 2. Revisar lançamentos. 3. Corrigir e recalcular.'
  end as prioridade_revisao,
  'pendente'
from public.itens_fechamento i
join public.fechamentos f on f.id = i.fechamento_id
join public.dias_operacionais d on d.id = f.dia_operacional_id
join public.revendas r on r.id = f.revenda_id
where r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07'
  and i.status = 'inconsistente';

-- 5. Atualizar status do dia operacional
update public.dias_operacionais d
set
  status = 'inconsistente',
  fechado_por_usuario_id = (
    select id
    from public.usuarios
    where nome = 'Operador Várzea Gás'
    order by created_at asc
    limit 1
  ),
  fechado_em = timestamp with time zone '2026-07-07 20:20:00-03'
from public.revendas r
where d.revenda_id = r.id
  and r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07';

-- 6. Conferir fechamento
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
