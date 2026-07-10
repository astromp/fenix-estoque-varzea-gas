-- Projeto Fênix Estoque — V5.4
-- Diagnóstico das funções operacionais antes da liberação multi-revenda.
-- Este arquivo não altera dados nem funções. Apenas consulta a estrutura atual.

-- 1) Assinaturas das funções operacionais
select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as arguments,
  pg_get_function_result(p.oid) as return_type,
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
order by p.proname, pg_get_function_identity_arguments(p.oid);

-- 2) Definição completa das funções operacionais
select
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as arguments,
  pg_get_functiondef(p.oid) as function_definition
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
order by p.proname, pg_get_function_identity_arguments(p.oid);

-- 3) Colunas essenciais para segregação por revenda
select
  table_name,
  ordinal_position,
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where table_schema = 'public'
  and table_name in (
    'revendas',
    'canais_venda',
    'dias_operacionais',
    'lancamentos',
    'movimentos_estoque',
    'produtos'
  )
order by table_name, ordinal_position;

-- 4) Chaves estrangeiras relacionadas a revenda, canal e dia operacional
select
  tc.table_name,
  kcu.column_name,
  ccu.table_name as referenced_table,
  ccu.column_name as referenced_column,
  tc.constraint_name
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu
  on kcu.constraint_name = tc.constraint_name
 and kcu.constraint_schema = tc.constraint_schema
join information_schema.constraint_column_usage ccu
  on ccu.constraint_name = tc.constraint_name
 and ccu.constraint_schema = tc.constraint_schema
where tc.constraint_schema = 'public'
  and tc.constraint_type = 'FOREIGN KEY'
  and tc.table_name in (
    'canais_venda',
    'dias_operacionais',
    'lancamentos',
    'movimentos_estoque'
  )
order by tc.table_name, kcu.column_name;

-- 5) Verificação de canais ativos por revenda
select
  r.id as revenda_id,
  r.nome as revenda,
  cv.id as canal_venda_id,
  cv.nome as canal,
  cv.ativo
from public.revendas r
left join public.canais_venda cv on cv.revenda_id = r.id
order by r.nome, cv.nome;

-- 6) Verificação de dias, lançamentos e movimentos já gravados por revenda
select
  r.id as revenda_id,
  r.nome as revenda,
  count(distinct d.id) as dias_operacionais,
  count(distinct l.id) as lancamentos,
  count(distinct m.id) as movimentos
from public.revendas r
left join public.dias_operacionais d on d.revenda_id = r.id
left join public.lancamentos l on l.revenda_id = r.id
left join public.movimentos_estoque m on m.revenda_id = r.id
group by r.id, r.nome
order by r.nome;
