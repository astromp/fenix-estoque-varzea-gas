-- Projeto Fênix Estoque — V5.3 CORRIGIDO
-- Cadastro idempotente das novas revendas e seus canais.
-- Usa somente as colunas reais da tabela revendas:
-- id, nome, cidade, ativa, created_at, updated_at.
-- Preserva integralmente a Várzea Gás e seu histórico.

begin;

-- 1) REVENDAS
insert into public.revendas (nome, cidade, ativa)
select 'Vinhedo Gás', 'Vinhedo/SP', true
where not exists (
  select 1 from public.revendas r
  where lower(trim(r.nome)) = lower('Vinhedo Gás')
);

insert into public.revendas (nome, cidade, ativa)
select 'Itatiba Gás', 'Itatiba/SP', true
where not exists (
  select 1 from public.revendas r
  where lower(trim(r.nome)) = lower('Itatiba Gás')
);

insert into public.revendas (nome, cidade, ativa)
select 'Vicensio Caxambu', 'Jundiaí/SP', true
where not exists (
  select 1 from public.revendas r
  where lower(trim(r.nome)) = lower('Vicensio Caxambu')
);

insert into public.revendas (nome, cidade, ativa)
select 'Vicensio 14', 'Jundiaí/SP', true
where not exists (
  select 1 from public.revendas r
  where lower(trim(r.nome)) = lower('Vicensio 14')
);

-- 2) CANAIS DA VINHEDO GÁS
with revenda as (
  select id from public.revendas
  where lower(trim(nome)) = lower('Vinhedo Gás')
  order by created_at nulls last, id
  limit 1
), canais(nome, ativo) as (
  values
    ('Jackson', true),
    ('Gilson', true),
    ('Portaria', true),
    ('Outros', true)
)
insert into public.canais_venda (revenda_id, nome, ativo)
select r.id, c.nome, c.ativo
from revenda r
cross join canais c
where not exists (
  select 1 from public.canais_venda cv
  where cv.revenda_id = r.id
    and lower(trim(cv.nome)) = lower(trim(c.nome))
);

-- 3) CANAIS DA ITATIBA GÁS
with revenda as (
  select id from public.revendas
  where lower(trim(nome)) = lower('Itatiba Gás')
  order by created_at nulls last, id
  limit 1
), canais(nome, ativo) as (
  values
    ('Portaria', true),
    ('Giovanni', true)
)
insert into public.canais_venda (revenda_id, nome, ativo)
select r.id, c.nome, c.ativo
from revenda r
cross join canais c
where not exists (
  select 1 from public.canais_venda cv
  where cv.revenda_id = r.id
    and lower(trim(cv.nome)) = lower(trim(c.nome))
);

-- 4) CANAIS DA VICENSIO CAXAMBU
with revenda as (
  select id from public.revendas
  where lower(trim(nome)) = lower('Vicensio Caxambu')
  order by created_at nulls last, id
  limit 1
), canais(nome, ativo) as (
  values
    ('Portaria', true),
    ('Roberto', true),
    ('Adriano', true)
)
insert into public.canais_venda (revenda_id, nome, ativo)
select r.id, c.nome, c.ativo
from revenda r
cross join canais c
where not exists (
  select 1 from public.canais_venda cv
  where cv.revenda_id = r.id
    and lower(trim(cv.nome)) = lower(trim(c.nome))
);

-- 5) CANAIS DA VICENSIO 14
with revenda as (
  select id from public.revendas
  where lower(trim(nome)) = lower('Vicensio 14')
  order by created_at nulls last, id
  limit 1
), canais(nome, ativo) as (
  values
    ('Paulo', true),
    ('Antonio Marcos', true),
    ('Durvalino', true),
    ('Ederson', true),
    ('Adevaldo', true),
    ('Richard', true),
    ('Celio', true),
    ('Carlos', true),
    ('Helio', true),
    ('Várzea', true),
    ('Itatiba', true),
    ('Vinhedo', true),
    ('Buriti', true),
    ('Caxambu', true),
    ('Portaria 14', true),
    ('Outros', true)
)
insert into public.canais_venda (revenda_id, nome, ativo)
select r.id, c.nome, c.ativo
from revenda r
cross join canais c
where not exists (
  select 1 from public.canais_venda cv
  where cv.revenda_id = r.id
    and lower(trim(cv.nome)) = lower(trim(c.nome))
);

commit;

-- 6) CONFERÊNCIA FINAL
select
  r.id as revenda_id,
  r.nome as revenda,
  r.cidade,
  r.ativa,
  count(cv.id) as total_canais,
  count(cv.id) filter (where cv.ativo = true) as canais_ativos,
  count(cv.id) filter (where cv.ativo = false) as canais_inativos
from public.revendas r
left join public.canais_venda cv on cv.revenda_id = r.id
where lower(trim(r.nome)) in (
  lower('Várzea Gás'),
  lower('Vinhedo Gás'),
  lower('Itatiba Gás'),
  lower('Vicensio Caxambu'),
  lower('Vicensio 14')
)
group by r.id, r.nome, r.cidade, r.ativa
order by r.nome;

select
  r.nome as revenda,
  cv.id as canal_venda_id,
  cv.nome as canal,
  cv.ativo
from public.revendas r
join public.canais_venda cv on cv.revenda_id = r.id
where lower(trim(r.nome)) in (
  lower('Várzea Gás'),
  lower('Vinhedo Gás'),
  lower('Itatiba Gás'),
  lower('Vicensio Caxambu'),
  lower('Vicensio 14')
)
order by r.nome, cv.nome;
