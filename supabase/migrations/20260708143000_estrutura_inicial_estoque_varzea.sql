-- Projeto Fênix Estoque — Várzea Gás
-- Estrutura inicial para Supabase/PostgreSQL
-- Data: 2026-07-08
--
-- Objetivo:
-- Criar a primeira base relacional para controlar abertura, entradas,
-- vendas por canal, venda de casco, fechamento, divergências e correções.
--
-- Regra operacional:
-- Estoque fechado, turno encerrado.
-- Estoque inconsistente, revisar até corrigir.

create extension if not exists pgcrypto;

-- =========================================================
-- Tipos controlados
-- =========================================================

do $$ begin
  create type perfil_usuario as enum ('operador', 'conferente', 'administrador');
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type tipo_produto as enum ('botijao', 'galao_agua', 'outro');
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type status_dia_operacional as enum ('aberto', 'em_fechamento', 'inconsistente', 'fechado');
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type status_conferencia_abertura as enum ('registrada', 'revisada', 'cancelada');
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type tipo_lancamento as enum ('entrada', 'venda', 'ajuste', 'correcao');
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type status_lancamento as enum ('ativo', 'corrigido', 'cancelado');
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type tipo_movimento_estoque as enum (
    'entrada_cheia',
    'venda_liquido',
    'venda_casco',
    'ajuste_entrada',
    'ajuste_saida',
    'correcao'
  );
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type status_movimento_estoque as enum ('ativo', 'corrigido', 'cancelado');
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type status_fechamento as enum (
    'em_andamento',
    'conferido',
    'inconsistente',
    'corrigido_apos_revisao',
    'cancelado'
  );
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type status_item_fechamento as enum ('conferido', 'inconsistente', 'corrigido');
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type tipo_divergencia_fechamento as enum (
    'diferenca_cheio',
    'diferenca_vazio',
    'diferenca_total_cascos',
    'divergencia_combinada'
  );
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type status_divergencia as enum ('pendente', 'em_revisao', 'resolvida', 'sem_conclusao');
exception
  when duplicate_object then null;
end $$;

do $$ begin
  create type tipo_correcao as enum (
    'corrigir_quantidade',
    'corrigir_produto',
    'corrigir_canal',
    'adicionar_venda_casco',
    'adicionar_venda_liquido',
    'cancelar_lancamento'
  );
exception
  when duplicate_object then null;
end $$;

-- =========================================================
-- Função para atualizar updated_at
-- =========================================================

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- =========================================================
-- Tabelas principais
-- =========================================================

create table if not exists revendas (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  cidade text,
  ativa boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  constraint revendas_nome_unique unique (nome)
);

create table if not exists produtos (
  id uuid primary key default gen_random_uuid(),
  codigo text not null,
  nome text not null,
  tipo tipo_produto not null default 'botijao',
  controla_cheio_vazio boolean not null default true,
  ativo boolean not null default true,
  ordem_exibicao integer not null default 0,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  constraint produtos_codigo_unique unique (codigo)
);

create table if not exists canais_venda (
  id uuid primary key default gen_random_uuid(),
  revenda_id uuid not null references revendas(id) on delete cascade,
  nome text not null,
  ativo boolean not null default true,
  ordem_exibicao integer not null default 0,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  constraint canais_venda_revenda_nome_unique unique (revenda_id, nome)
);

create table if not exists usuarios (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  telefone text,
  email text,
  perfil perfil_usuario not null default 'operador',
  ativo boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table if not exists dias_operacionais (
  id uuid primary key default gen_random_uuid(),
  revenda_id uuid not null references revendas(id),
  data_operacional date not null,
  status status_dia_operacional not null default 'aberto',
  aberto_por_usuario_id uuid references usuarios(id),
  aberto_em timestamptz not null default now(),
  fechado_por_usuario_id uuid references usuarios(id),
  fechado_em timestamptz,
  observacao text,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  constraint dias_operacionais_revenda_data_unique unique (revenda_id, data_operacional),
  constraint dias_operacionais_fechamento_consistente check (
    (status <> 'fechado') or (fechado_em is not null)
  )
);

create table if not exists conferencias_abertura (
  id uuid primary key default gen_random_uuid(),
  dia_operacional_id uuid not null references dias_operacionais(id) on delete cascade,
  revenda_id uuid not null references revendas(id),
  usuario_id uuid references usuarios(id),
  data_hora timestamptz not null default now(),
  status status_conferencia_abertura not null default 'registrada',
  observacao text,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table if not exists itens_conferencia_abertura (
  id uuid primary key default gen_random_uuid(),
  conferencia_abertura_id uuid not null references conferencias_abertura(id) on delete cascade,
  produto_id uuid not null references produtos(id),
  cheios_fisicos integer not null default 0 check (cheios_fisicos >= 0),
  vazios_fisicos integer not null default 0 check (vazios_fisicos >= 0),
  total_fisico integer generated always as (cheios_fisicos + vazios_fisicos) stored,
  observacao text,
  criado_em timestamptz not null default now(),
  constraint itens_conferencia_abertura_produto_unique unique (conferencia_abertura_id, produto_id)
);

create table if not exists lancamentos (
  id uuid primary key default gen_random_uuid(),
  dia_operacional_id uuid not null references dias_operacionais(id),
  revenda_id uuid not null references revendas(id),
  usuario_id uuid references usuarios(id),
  canal_venda_id uuid references canais_venda(id),
  tipo_lancamento tipo_lancamento not null,
  data_hora timestamptz not null default now(),
  status status_lancamento not null default 'ativo',
  observacao text,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  constraint lancamento_venda_exige_canal check (
    tipo_lancamento <> 'venda' or canal_venda_id is not null
  )
);

create table if not exists movimentos_estoque (
  id uuid primary key default gen_random_uuid(),
  lancamento_id uuid not null references lancamentos(id) on delete cascade,
  dia_operacional_id uuid not null references dias_operacionais(id),
  revenda_id uuid not null references revendas(id),
  produto_id uuid not null references produtos(id),
  canal_venda_id uuid references canais_venda(id),
  usuario_id uuid references usuarios(id),
  tipo_movimento tipo_movimento_estoque not null,
  quantidade integer not null check (quantidade > 0),
  movimento_vinculado_id uuid references movimentos_estoque(id),
  status status_movimento_estoque not null default 'ativo',
  observacao text,
  criado_em timestamptz not null default now(),
  corrigido_em timestamptz,
  cancelado_em timestamptz,
  constraint movimento_venda_exige_canal check (
    tipo_movimento not in ('venda_liquido', 'venda_casco') or canal_venda_id is not null
  ),
  constraint venda_casco_exige_vinculo check (
    tipo_movimento <> 'venda_casco' or movimento_vinculado_id is not null
  )
);

create table if not exists fechamentos (
  id uuid primary key default gen_random_uuid(),
  dia_operacional_id uuid not null references dias_operacionais(id) on delete cascade,
  revenda_id uuid not null references revendas(id),
  usuario_id uuid references usuarios(id),
  data_hora_inicio timestamptz not null default now(),
  data_hora_fim timestamptz,
  status status_fechamento not null default 'em_andamento',
  observacao text,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table if not exists itens_fechamento (
  id uuid primary key default gen_random_uuid(),
  fechamento_id uuid not null references fechamentos(id) on delete cascade,
  produto_id uuid not null references produtos(id),
  cheios_calculados integer not null default 0,
  vazios_calculados integer not null default 0,
  total_calculado integer generated always as (cheios_calculados + vazios_calculados) stored,
  cheios_fisicos integer not null default 0 check (cheios_fisicos >= 0),
  vazios_fisicos integer not null default 0 check (vazios_fisicos >= 0),
  total_fisico integer generated always as (cheios_fisicos + vazios_fisicos) stored,
  diferenca_cheios integer generated always as (cheios_fisicos - cheios_calculados) stored,
  diferenca_vazios integer generated always as (vazios_fisicos - vazios_calculados) stored,
  diferenca_total integer generated always as ((cheios_fisicos + vazios_fisicos) - (cheios_calculados + vazios_calculados)) stored,
  status status_item_fechamento not null default 'conferido',
  observacao text,
  criado_em timestamptz not null default now(),
  constraint itens_fechamento_produto_unique unique (fechamento_id, produto_id)
);

create table if not exists divergencias_fechamento (
  id uuid primary key default gen_random_uuid(),
  fechamento_id uuid not null references fechamentos(id) on delete cascade,
  item_fechamento_id uuid not null references itens_fechamento(id) on delete cascade,
  produto_id uuid not null references produtos(id),
  tipo_divergencia tipo_divergencia_fechamento not null,
  diferenca_cheios integer not null,
  diferenca_vazios integer not null,
  diferenca_total integer not null,
  hipotese_provavel text,
  prioridade_revisao text,
  status status_divergencia not null default 'pendente',
  criado_em timestamptz not null default now(),
  resolvido_em timestamptz
);

create table if not exists correcoes (
  id uuid primary key default gen_random_uuid(),
  divergencia_id uuid references divergencias_fechamento(id),
  lancamento_original_id uuid references lancamentos(id),
  movimento_original_id uuid references movimentos_estoque(id),
  usuario_id uuid references usuarios(id),
  tipo_correcao tipo_correcao not null,
  descricao text not null,
  lancamento_correcao_id uuid references lancamentos(id),
  movimento_correcao_id uuid references movimentos_estoque(id),
  criado_em timestamptz not null default now()
);

-- =========================================================
-- Triggers de updated_at
-- =========================================================

drop trigger if exists trg_revendas_updated_at on revendas;
create trigger trg_revendas_updated_at
before update on revendas
for each row execute function set_updated_at();

drop trigger if exists trg_produtos_updated_at on produtos;
create trigger trg_produtos_updated_at
before update on produtos
for each row execute function set_updated_at();

drop trigger if exists trg_canais_venda_updated_at on canais_venda;
create trigger trg_canais_venda_updated_at
before update on canais_venda
for each row execute function set_updated_at();

drop trigger if exists trg_usuarios_updated_at on usuarios;
create trigger trg_usuarios_updated_at
before update on usuarios
for each row execute function set_updated_at();

drop trigger if exists trg_dias_operacionais_updated_at on dias_operacionais;
create trigger trg_dias_operacionais_updated_at
before update on dias_operacionais
for each row execute function set_updated_at();

drop trigger if exists trg_conferencias_abertura_updated_at on conferencias_abertura;
create trigger trg_conferencias_abertura_updated_at
before update on conferencias_abertura
for each row execute function set_updated_at();

drop trigger if exists trg_lancamentos_updated_at on lancamentos;
create trigger trg_lancamentos_updated_at
before update on lancamentos
for each row execute function set_updated_at();

drop trigger if exists trg_fechamentos_updated_at on fechamentos;
create trigger trg_fechamentos_updated_at
before update on fechamentos
for each row execute function set_updated_at();

-- =========================================================
-- Índices úteis
-- =========================================================

create index if not exists idx_canais_venda_revenda on canais_venda(revenda_id);
create index if not exists idx_dias_operacionais_revenda_data on dias_operacionais(revenda_id, data_operacional);
create index if not exists idx_lancamentos_dia on lancamentos(dia_operacional_id);
create index if not exists idx_lancamentos_canal on lancamentos(canal_venda_id);
create index if not exists idx_movimentos_dia_produto on movimentos_estoque(dia_operacional_id, produto_id);
create index if not exists idx_movimentos_canal on movimentos_estoque(canal_venda_id);
create index if not exists idx_fechamentos_dia on fechamentos(dia_operacional_id);
create index if not exists idx_divergencias_status on divergencias_fechamento(status);

-- =========================================================
-- View: cálculo do estoque esperado a partir da abertura + movimentos
-- =========================================================

create or replace view vw_estoque_calculado as
with abertura as (
  select
    ca.dia_operacional_id,
    ca.revenda_id,
    ica.produto_id,
    sum(ica.cheios_fisicos) as cheios_abertura,
    sum(ica.vazios_fisicos) as vazios_abertura
  from conferencias_abertura ca
  join itens_conferencia_abertura ica on ica.conferencia_abertura_id = ca.id
  where ca.status <> 'cancelada'
  group by ca.dia_operacional_id, ca.revenda_id, ica.produto_id
), movimentos as (
  select
    dia_operacional_id,
    revenda_id,
    produto_id,
    sum(case
      when tipo_movimento = 'entrada_cheia' then quantidade
      when tipo_movimento = 'venda_liquido' then -quantidade
      when tipo_movimento = 'ajuste_entrada' then quantidade
      when tipo_movimento = 'ajuste_saida' then -quantidade
      else 0
    end) as delta_cheios,
    sum(case
      when tipo_movimento = 'entrada_cheia' then -quantidade
      when tipo_movimento = 'venda_liquido' then quantidade
      when tipo_movimento = 'venda_casco' then -quantidade
      else 0
    end) as delta_vazios
  from movimentos_estoque
  where status = 'ativo'
  group by dia_operacional_id, revenda_id, produto_id
)
select
  a.dia_operacional_id,
  a.revenda_id,
  a.produto_id,
  a.cheios_abertura,
  a.vazios_abertura,
  coalesce(m.delta_cheios, 0) as delta_cheios,
  coalesce(m.delta_vazios, 0) as delta_vazios,
  a.cheios_abertura + coalesce(m.delta_cheios, 0) as cheios_calculados,
  a.vazios_abertura + coalesce(m.delta_vazios, 0) as vazios_calculados,
  a.cheios_abertura + a.vazios_abertura + coalesce(m.delta_cheios, 0) + coalesce(m.delta_vazios, 0) as total_calculado
from abertura a
left join movimentos m
  on m.dia_operacional_id = a.dia_operacional_id
 and m.revenda_id = a.revenda_id
 and m.produto_id = a.produto_id;

-- =========================================================
-- Dados iniciais da Várzea Gás para teste
-- =========================================================

insert into revendas (nome, cidade, ativa)
values ('Várzea Gás', 'Várzea Paulista/SP', true)
on conflict (nome) do update set
  cidade = excluded.cidade,
  ativa = excluded.ativa;

insert into produtos (codigo, nome, tipo, controla_cheio_vazio, ativo, ordem_exibicao)
values
  ('P13', 'Botijão P13', 'botijao', true, true, 1),
  ('P05', 'Botijão P05', 'botijao', true, true, 2),
  ('P20', 'Botijão P20', 'botijao', true, true, 3),
  ('P45', 'Botijão P45', 'botijao', true, true, 4),
  ('AGUA', 'Água / Galão', 'galao_agua', true, true, 5)
on conflict (codigo) do update set
  nome = excluded.nome,
  tipo = excluded.tipo,
  controla_cheio_vazio = excluded.controla_cheio_vazio,
  ativo = excluded.ativo,
  ordem_exibicao = excluded.ordem_exibicao;

insert into canais_venda (revenda_id, nome, ativo, ordem_exibicao)
select r.id, c.nome, true, c.ordem_exibicao
from revendas r
cross join (
  values
    ('André', 1),
    ('João', 2),
    ('Rogério', 3),
    ('Portaria', 4),
    ('Outros', 5)
) as c(nome, ordem_exibicao)
where r.nome = 'Várzea Gás'
on conflict (revenda_id, nome) do update set
  ativo = excluded.ativo,
  ordem_exibicao = excluded.ordem_exibicao;

-- Observação importante:
-- Portaria é canal de venda, igual André, João e Rogério.
-- Não tratar Portaria como portão físico, retirada, conferência ou etapa intermediária.
