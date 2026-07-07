-- Projeto Fênix Estoque — Teste 9: diagnóstico da divergência
-- Banco: Supabase / PostgreSQL
-- Objetivo: gerar uma leitura inteligente para a divergência do fechamento físico.

select
  p.codigo as produto,
  i.diferenca_cheios,
  i.diferenca_vazios,
  i.diferenca_total,
  case
    when i.diferenca_cheios < 0
     and i.diferenca_vazios = 0
     and i.diferenca_total < 0
    then 'Provável venda de casco não lançada.'
    when i.diferenca_cheios < 0
     and i.diferenca_vazios > 0
     and i.diferenca_total = 0
    then 'Provável venda do líquido lançada corretamente, mas conferir contagem de cheios e vazios.'
    when i.diferenca_cheios > 0
    then 'Há mais cheios físicos do que o calculado. Revisar entradas ou venda lançada a mais.'
    when i.diferenca_vazios <> 0
    then 'Diferença em vazios. Revisar trocas, entradas e vendas com casco.'
    else 'Revisar contagem física e lançamentos do produto.'
  end as hipotese_provavel,
  case
    when i.diferenca_cheios < 0
     and i.diferenca_vazios = 0
     and i.diferenca_total < 0
    then '1. Recontar P45 cheio. 2. Conferir se houve venda de P45 com casco. 3. Revisar Portaria e Rogério, que venderam P45.'
    else '1. Recontar o produto. 2. Revisar lançamentos do dia. 3. Corrigir e recalcular.'
  end as prioridade_revisao
from public.itens_fechamento i
join public.produtos p on p.id = i.produto_id
join public.fechamentos f on f.id = i.fechamento_id
join public.dias_operacionais d on d.id = f.dia_operacional_id
join public.revendas r on r.id = f.revenda_id
where r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07'
  and i.status = 'inconsistente'
order by p.ordem_exibicao;
