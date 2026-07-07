-- Projeto Fênix Estoque — Teste 6: resumo geral das vendas do dia
-- Banco: Supabase / PostgreSQL
-- Objetivo: conferir todas as vendas lançadas por canal e produto no dia 07/07/2026.

-- Resultado esperado:
-- Portaria: P13 10, P05 1, P20 1, P45 2
-- Rogério: P13 20, P20 1, P45 1
-- André: P13 10
-- João: P13 venda_liquido 10 e P13 venda_casco 1

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
  and m.status = 'ativo'
group by c.nome, p.codigo, p.ordem_exibicao, m.tipo_movimento
order by
  case c.nome
    when 'Portaria' then 1
    when 'Rogério' then 2
    when 'André' then 3
    when 'João' then 4
    else 99
  end,
  p.ordem_exibicao,
  m.tipo_movimento;
