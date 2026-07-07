-- Projeto Fênix Estoque — Teste 11: auditoria final do dia
-- Banco: Supabase / PostgreSQL
-- Objetivo: confirmar dia fechado, fechamento corrigido, divergência resolvida e vendas finais por canal.

-- 1. Auditoria do status do dia, fechamento e divergência
select
  r.nome as revenda,
  d.data_operacional,
  d.status as status_dia,
  f.status as status_fechamento,
  coalesce(df.status, 'sem_divergencia_pendente') as status_divergencia,
  p.codigo as produto_divergencia,
  df.diferenca_cheios,
  df.diferenca_vazios,
  df.diferenca_total,
  df.hipotese_provavel
from public.dias_operacionais d
join public.revendas r on r.id = d.revenda_id
left join public.fechamentos f on f.dia_operacional_id = d.id
left join public.divergencias_fechamento df on df.fechamento_id = f.id
left join public.produtos p on p.id = df.produto_id
where r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07';

-- 2. Relatório final de vendas por canal e produto, já com a correção do P45
select
  c.nome as canal,
  p.codigo as produto,
  case
    when m.tipo_movimento = 'venda_liquido' then 'LIQUIDO'
    when m.tipo_movimento = 'venda_casco' then 'CASCO'
    else m.tipo_movimento
  end as tipo,
  sum(m.quantidade) as quantidade
from public.movimentos_estoque m
join public.canais_venda c on c.id = m.canal_venda_id
join public.produtos p on p.id = m.produto_id
join public.dias_operacionais d on d.id = m.dia_operacional_id
join public.revendas r on r.id = m.revenda_id
where r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07'
  and m.status = 'ativo'
  and m.tipo_movimento in ('venda_liquido', 'venda_casco')
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

-- 3. Estoque final auditado após correção
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
