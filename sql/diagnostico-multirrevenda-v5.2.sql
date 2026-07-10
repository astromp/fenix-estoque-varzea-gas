-- Projeto Fênix Estoque — V5.2
-- Diagnóstico seguro para arquitetura multi-revenda.
-- Este script NÃO altera dados nem cria funções.

-- 1) Tabelas públicas relacionadas a revendas, canais e operação.
select table_name
from information_schema.tables
where table_schema = 'public'
  and (
    table_name ilike '%revenda%'
    or table_name ilike '%canal%'
    or table_name ilike '%lancamento%'
    or table_name ilike '%movimento%'
    or table_name ilike '%dia_operacional%'
  )
order by table_name;

-- 2) Colunas das tabelas relevantes.
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
    'movimentos_estoque'
  )
order by table_name, ordinal_position;

-- 3) Chaves estrangeiras envolvendo revenda_id.
select
  tc.table_name,
  kcu.column_name,
  ccu.table_name as tabela_referenciada,
  ccu.column_name as coluna_referenciada,
  tc.constraint_name
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu
  on tc.constraint_name = kcu.constraint_name
 and tc.table_schema = kcu.table_schema
join information_schema.constraint_column_usage ccu
  on ccu.constraint_name = tc.constraint_name
 and ccu.table_schema = tc.table_schema
where tc.constraint_type = 'FOREIGN KEY'
  and tc.table_schema = 'public'
  and (
    kcu.column_name = 'revenda_id'
    or ccu.column_name = 'id'
  )
order by tc.table_name, kcu.column_name;

-- 4) Revendas cadastradas.
-- Caso a tabela public.revendas exista, esta consulta mostrará os registros.
select *
from public.revendas
order by 1;

-- 5) Canais cadastrados por revenda.
select
  cv.revenda_id,
  cv.id as canal_venda_id,
  cv.nome,
  cv.ativo
from public.canais_venda cv
order by cv.revenda_id, cv.nome;

-- 6) Quantidade de canais por revenda.
select
  cv.revenda_id,
  count(*) as total_canais,
  count(*) filter (where coalesce(cv.ativo, true)) as canais_ativos
from public.canais_venda cv
group by cv.revenda_id
order by cv.revenda_id;

-- 7) Funções existentes relacionadas a vendas, revendas ou canais.
select
  n.nspname as esquema,
  p.proname as funcao,
  pg_get_function_identity_arguments(p.oid) as argumentos,
  pg_get_function_result(p.oid) as retorno,
  p.prosecdef as security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and (
    p.proname ilike '%venda%'
    or p.proname ilike '%revenda%'
    or p.proname ilike '%canal%'
  )
order by p.proname, argumentos;

-- 8) Definição da função atual de vendas do dia.
select pg_get_functiondef(p.oid)
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname = 'consultar_vendas_dia_mvp';

-- 9) Conferência de segregação: lançamentos e movimentos por revenda.
select
  l.revenda_id,
  count(distinct l.id) as lancamentos,
  count(m.id) as movimentos
from public.lancamentos l
left join public.movimentos_estoque m
  on m.lancamento_id = l.id
 and m.revenda_id = l.revenda_id
group by l.revenda_id
order by l.revenda_id;
