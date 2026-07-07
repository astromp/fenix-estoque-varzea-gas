-- Projeto Fênix Estoque — Teste 1: abertura do dia
-- Banco: Supabase / PostgreSQL
-- Objetivo: criar o dia operacional 07/07/2026 e registrar a conferência inicial.

-- Este script pode ser executado mais de uma vez.
-- Se o dia 07/07/2026 já existir para Várzea Gás, ele não recria o dia.

-- 1. Criar dia operacional de teste
insert into public.dias_operacionais (
  revenda_id,
  data_operacional,
  status,
  aberto_por_usuario_id,
  aberto_em,
  observacao
)
select
  r.id,
  date '2026-07-07',
  'aberto',
  u.id,
  timestamp with time zone '2026-07-07 07:00:00-03',
  'Teste de abertura do dia da Várzea Gás'
from public.revendas r
cross join lateral (
  select id
  from public.usuarios
  where nome = 'Operador Várzea Gás'
  order by created_at asc
  limit 1
) u
where r.nome = 'Várzea Gás'
on conflict (revenda_id, data_operacional) do nothing;

-- 2. Criar conferência de abertura
insert into public.conferencias_abertura (
  dia_operacional_id,
  revenda_id,
  usuario_id,
  data_hora,
  status,
  observacao
)
select
  d.id,
  r.id,
  u.id,
  timestamp with time zone '2026-07-07 07:05:00-03',
  'registrada',
  'Conferência inicial de teste'
from public.dias_operacionais d
join public.revendas r on r.id = d.revenda_id
cross join lateral (
  select id
  from public.usuarios
  where nome = 'Operador Várzea Gás'
  order by created_at asc
  limit 1
) u
where r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07'
on conflict (dia_operacional_id) do nothing;

-- 3. Registrar itens da abertura
insert into public.itens_conferencia_abertura (
  conferencia_abertura_id,
  produto_id,
  cheios_fisicos,
  vazios_fisicos,
  observacao
)
select
  ca.id,
  p.id,
  x.cheios,
  x.vazios,
  'Estoque inicial da simulação'
from public.conferencias_abertura ca
join public.dias_operacionais d on d.id = ca.dia_operacional_id
join public.revendas r on r.id = d.revenda_id
join (
  values
    ('P13', 100, 30),
    ('P05', 10, 5),
    ('P20', 10, 2),
    ('P45', 10, 10),
    ('AGUA', 50, 10)
) as x(codigo, cheios, vazios) on true
join public.produtos p on p.codigo = x.codigo
where r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07'
on conflict (conferencia_abertura_id, produto_id) do update set
  cheios_fisicos = excluded.cheios_fisicos,
  vazios_fisicos = excluded.vazios_fisicos,
  observacao = excluded.observacao;

-- 4. Conferir resultado da abertura
select
  p.codigo as produto,
  i.cheios_fisicos as cheios,
  i.vazios_fisicos as vazios,
  i.total_fisico as total
from public.itens_conferencia_abertura i
join public.produtos p on p.id = i.produto_id
join public.conferencias_abertura ca on ca.id = i.conferencia_abertura_id
join public.dias_operacionais d on d.id = ca.dia_operacional_id
join public.revendas r on r.id = d.revenda_id
where r.nome = 'Várzea Gás'
  and d.data_operacional = date '2026-07-07'
order by p.ordem_exibicao;
