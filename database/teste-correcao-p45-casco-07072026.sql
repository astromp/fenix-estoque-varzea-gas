-- Projeto Fênix Estoque — Teste 10: corrigir divergência do P45
-- Banco: Supabase / PostgreSQL
-- Objetivo: simular a correção de uma venda de P45 com casco que não havia sido lançada.

-- Hipótese usada na simulação:
-- A venda de P45 com casco foi feita pela Portaria.
-- Correção necessária: adicionar 1 venda_liquido de P45 e 1 venda_casco de P45 vinculada.

-- 1. Criar lançamento de correção e movimentos de estoque
with dados as (
  select
    d.id as dia_operacional_id,
    r.id as revenda_id,
    u.id as usuario_id,
    c.id as canal_venda_id,
    p.id as produto_id,
    df.id as divergencia_id
  from public.revendas r
  join public.dias_operacionais d
    on d.revenda_id = r.id
   and d.data_operacional = date '2026-07-07'
  join public.canais_venda c
    on c.revenda_id = r.id
   and c.nome = 'Portaria'
  join public.produtos p
    on p.codigo = 'P45'
  cross join lateral (
    select id
    from public.usuarios
    where nome = 'Operador Várzea Gás'
    order by created_at asc
    limit 1
  ) u
  left join public.fechamentos f
    on f.dia_operacional_id = d.id
   and f.revenda_id = r.id
  left join public.divergencias_fechamento df
    on df.fechamento_id = f.id
   and df.produto_id = p.id
   and df.status = 'pendente'
  where r.nome = 'Várzea Gás'
), novo_lancamento as (
  insert into public.lancamentos (
    dia_operacional_id,
    revenda_id,
    usuario_id,
    canal_venda_id,
    tipo_lancamento,
    data_hora,
    observacao
  )
  select
    dia_operacional_id,
    revenda_id,
    usuario_id,
    canal_venda_id,
    'correcao',
    timestamp with time zone '2026-07-07 20:35:00-03',
    'Correção: Portaria vendeu 1 P45 com casco e não havia lançado'
  from dados
  where not exists (
    select 1
    from public.lancamentos l
    where l.dia_operacional_id = dados.dia_operacional_id
      and l.observacao = 'Correção: Portaria vendeu 1 P45 com casco e não havia lançado'
      and l.status = 'ativo'
  )
  returning id, dia_operacional_id, revenda_id, usuario_id, canal_venda_id
), movimento_liquido as (
  insert into public.movimentos_estoque (
    lancamento_id,
    dia_operacional_id,
    revenda_id,
    produto_id,
    canal_venda_id,
    usuario_id,
    tipo_movimento,
    quantidade,
    observacao
  )
  select
    nl.id,
    nl.dia_operacional_id,
    nl.revenda_id,
    p.id,
    nl.canal_venda_id,
    nl.usuario_id,
    'venda_liquido',
    1,
    'Correção: venda do líquido P45 pela Portaria'
  from novo_lancamento nl
  join public.produtos p on p.codigo = 'P45'
  returning id, lancamento_id, dia_operacional_id, revenda_id, produto_id, canal_venda_id, usuario_id
), movimento_casco as (
  insert into public.movimentos_estoque (
    lancamento_id,
    dia_operacional_id,
    revenda_id,
    produto_id,
    canal_venda_id,
    usuario_id,
    tipo_movimento,
    quantidade,
    movimento_vinculado_id,
    observacao
  )
  select
    ml.lancamento_id,
    ml.dia_operacional_id,
    ml.revenda_id,
    ml.produto_id,
    ml.canal_venda_id,
    ml.usuario_id,
    'venda_casco',
    1,
    ml.id,
    'Correção: venda de casco P45 vinculada à venda do líquido'
  from movimento_liquido ml
  returning id, lancamento_id
)
insert into public.correcoes (
  divergencia_id,
  usuario_id,
  tipo_correcao,
  descricao,
  lancamento_correcao_id,
  movimento_correcao_id
)
select
  d.divergencia_id,
  nl.usuario_id,
  'adicionar_venda_casco',
  'Corrigida divergência do P45: adicionada venda de P45 com casco pela Portaria.',
  nl.id,
  mc.id
from novo_lancamento nl
join movimento_casco mc on mc.lancamento_id = nl.id
cross join dados d;

-- 2. Recalcular os itens do fechamento físico
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
    a.ordem_exibicao,
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
      ('AGUA', 50, 10),
      ('ÁGUA', 50, 10)
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
    when c.codigo = 'P45'
     and c.cheios_calculados = fi.cheios_fisicos
     and c.vazios_calculados = fi.vazios_fisicos
    then 'corrigido'
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

-- 3. Resolver a divergência e fechar o dia
update public.divergencias_fechamento df
set
  status = 'resolvida',
  resolvido_em = now()
from public.fechamentos f
join public.dias_operacionais d on d.id = f.dia_operacional_id
join public.revendas r on r.id = f.revenda_id
join public.produtos p on p.codigo = 'P45'
where df.fechamento_id = f.id
  and df.produto_id = p.id
  and r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07'
  and df.status in ('pendente', 'em_revisao');

update public.fechamentos f
set
  status = 'corrigido_apos_revisao',
  data_hora_fim = timestamp with time zone '2026-07-07 20:45:00-03',
  observacao = 'Fechamento corrigido após revisão: adicionada venda de P45 com casco.'
from public.dias_operacionais d
join public.revendas r on r.id = d.revenda_id
where f.dia_operacional_id = d.id
  and f.revenda_id = r.id
  and r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07';

update public.dias_operacionais d
set
  status = 'fechado',
  fechado_em = timestamp with time zone '2026-07-07 20:45:00-03'
from public.revendas r
where d.revenda_id = r.id
  and r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07';

-- 4. Mostrar resultado final após correção
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
