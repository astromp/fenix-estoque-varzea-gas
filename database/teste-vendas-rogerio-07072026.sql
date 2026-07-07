-- Projeto Fênix Estoque — Teste 3: vendas do Rogério
-- Banco: Supabase / PostgreSQL
-- Objetivo: lançar apenas as vendas do Rogério no dia 07/07/2026.

-- Rogério vendeu:
-- 20 P13
-- 1 P20
-- 1 P45

-- ATENÇÃO:
-- Este script evita duplicar o lançamento se já existir um lançamento com a mesma observação para o Rogério neste dia.

-- 1. Criar lançamento do Rogério, se ainda não existir
with dados as (
  select
    d.id as dia_operacional_id,
    r.id as revenda_id,
    u.id as usuario_id,
    c.id as canal_venda_id
  from public.revendas r
  join public.dias_operacionais d
    on d.revenda_id = r.id
   and d.data_operacional = date '2026-07-07'
  join public.canais_venda c
    on c.revenda_id = r.id
   and c.nome = 'Rogério'
  cross join lateral (
    select id
    from public.usuarios
    where nome = 'Operador Várzea Gás'
    order by created_at asc
    limit 1
  ) u
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
    'venda',
    timestamp with time zone '2026-07-07 09:10:00-03',
    'Rogério: vendas da simulação'
  from dados
  where not exists (
    select 1
    from public.lancamentos l
    where l.dia_operacional_id = dados.dia_operacional_id
      and l.canal_venda_id = dados.canal_venda_id
      and l.observacao = 'Rogério: vendas da simulação'
      and l.status = 'ativo'
  )
  returning id, dia_operacional_id, revenda_id, usuario_id, canal_venda_id
)
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
  v.quantidade,
  'Venda do líquido pelo Rogério'
from novo_lancamento nl
join (
  values
    ('P13', 20),
    ('P20', 1),
    ('P45', 1)
) as v(codigo_produto, quantidade) on true
join public.produtos p on p.codigo = v.codigo_produto;

-- 2. Conferir vendas do Rogério
select
  c.nome as canal,
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
  and c.nome = 'Rogério'
  and m.status = 'ativo'
group by c.nome, p.codigo, p.ordem_exibicao, m.tipo_movimento
order by p.ordem_exibicao;
