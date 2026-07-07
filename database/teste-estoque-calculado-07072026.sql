-- Projeto Fênix Estoque — Teste 7: estoque calculado após vendas
-- Banco: Supabase / PostgreSQL
-- Objetivo: calcular o estoque esperado após todas as vendas lançadas no dia 07/07/2026.

-- Fórmulas:
-- cheio_final = cheio_abertura + entradas_cheias - vendas_liquido
-- vazio_final = vazio_abertura - entradas_cheias + vendas_liquido - vendas_casco
-- total_final = cheio_final + vazio_final

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
)
select
  a.codigo as produto,
  a.cheios_abertura,
  a.vazios_abertura,
  coalesce(m.entradas_cheias, 0) as entradas_cheias,
  coalesce(m.vendas_liquido, 0) as vendas_liquido,
  coalesce(m.vendas_casco, 0) as vendas_casco,
  (a.cheios_abertura + coalesce(m.entradas_cheias, 0) - coalesce(m.vendas_liquido, 0)) as cheios_calculados,
  (a.vazios_abertura - coalesce(m.entradas_cheias, 0) + coalesce(m.vendas_liquido, 0) - coalesce(m.vendas_casco, 0)) as vazios_calculados,
  (
    (a.cheios_abertura + coalesce(m.entradas_cheias, 0) - coalesce(m.vendas_liquido, 0))
    +
    (a.vazios_abertura - coalesce(m.entradas_cheias, 0) + coalesce(m.vendas_liquido, 0) - coalesce(m.vendas_casco, 0))
  ) as total_calculado
from abertura a
left join movimentos m on m.produto_id = a.produto_id
order by a.ordem_exibicao;
