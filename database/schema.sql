-- Projeto Fênix Estoque — Schema inicial
-- Banco: Supabase / PostgreSQL
-- Objetivo: criar a estrutura principal para estoque, vendas, fechamento, divergências e correções.

create extension if not exists pgcrypto;

-- =========================================================
-- Função padrão para atualizar updated_at
-- =========================================================

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- =========================================================
-- Tabela: revendas
-- =========================================================

create table if not exists public.revendas (
  id uuid primary key default gen_random_uuid(),
  nome text not null unique,
  cidade text,
  ativa boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_revendas_updated_at
before update on public.revendas
for each row execute function public.set_updated_at();

-- =========================================================
-- Tabela: produtos
-- =========================================================

create table if not exists public.produtos (
  id uuid primary key default gen_random_uuid(),
  codigo text not null unique,
  nome text not null,
  tipo text not null default 'botijao' check (tipo in ('botijao', 'galao_agua', 'outro')),
  controla_cheio_vazio boolean not null default true,
  ativo boolean not null default true,
  ordem_exibicao integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_produtos_updated_at
before update on public.produtos
for each row execute function public.set_updated_at();

-- =========================================================
-- Tabela: canais_venda
-- =========================================================

create table if not exists public.canais_venda (
  id uuid primary key default gen_random_uuid(),
  revenda_id uuid not null references public.revendas(id) on delete cascade,
  nome text not null,
  ativo boolean not null default true,
  ordem_exibicao integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (revenda_id, nome)
);

create trigger trg_canais_venda_updated_at
before update on public.canais_venda
for each row execute function public.set_updated_at();

-- =========================================================
-- Tabela: usuarios
-- Observação: usuários operacionais do Fênix.
-- Não confundir com auth.users do Supabase.
-- =========================================================

create table if not exists public.usuarios (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid,
  nome text not null,
  telefone text,
  email text,
  perfil text not null default 'operador' check (perfil in ('operador', 'conferente', 'administrador')),
  ativo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_usuarios_updated_at
before update on public.usuarios
for each row execute function public.set_updated_at();

-- =========================================================
-- Tabela: dias_operacionais
-- Representa o dia de trabalho da revenda.
-- =========================================================

create table if not exists public.dias_operacionais (
  id uuid primary key default gen_random_uuid(),
  revenda_id uuid not null references public.revendas(id),
  data_operacional date not null,
  status text not null default 'aberto' check (status in ('aberto', 'em_fechamento', 'inconsistente', 'fechado')),
  aberto_por_usuario_id uuid references public.usuarios(id),
  aberto_em timestamptz,
  fechado_por_usuario_id uuid references public.usuarios(id),
  fechado_em timestamptz,
  observacao text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (revenda_id, data_operacional)
);

create trigger trg_dias_operacionais_updated_at
before update on public.dias_operacionais
for each row execute function public.set_updated_at();

-- =========================================================
-- Tabela: conferencias_abertura
-- Conferência física da manhã.
-- =========================================================

create table if not exists public.conferencias_abertura (
  id uuid primary key default gen_random_uuid(),
  dia_operacional_id uuid not null unique references public.dias_operacionais(id) on delete cascade,
  revenda_id uuid not null references public.revendas(id),
  usuario_id uuid references public.usuarios(id),
  data_hora timestamptz not null default now(),
  status text not null default 'registrada' check (status in ('registrada', 'revisada', 'cancelada')),
  observacao text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_conferencias_abertura_updated_at
before update on public.conferencias_abertura
for each row execute function public.set_updated_at();

-- =========================================================
-- Tabela: itens_conferencia_abertura
-- Contagem inicial por produto.
-- =========================================================

create table if not exists public.itens_conferencia_abertura (
  id uuid primary key default gen_random_uuid(),
  conferencia_abertura_id uuid not null references public.conferencias_abertura(id) on delete cascade,
  produto_id uuid not null references public.produtos(id),
  cheios_fisicos integer not null default 0 check (cheios_fisicos >= 0),
  vazios_fisicos integer not null default 0 check (vazios_fisicos >= 0),
  total_fisico integer generated always as (cheios_fisicos + vazios_fisicos) stored,
  observacao text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (conferencia_abertura_id, produto_id)
);

create trigger trg_itens_conferencia_abertura_updated_at
before update on public.itens_conferencia_abertura
for each row execute function public.set_updated_at();

-- =========================================================
-- Tabela: lancamentos
-- Cabeçalho de uma operação. Pode gerar um ou mais movimentos.
-- =========================================================

create table if not exists public.lancamentos (
  id uuid primary key default gen_random_uuid(),
  dia_operacional_id uuid not null references public.dias_operacionais(id),
  revenda_id uuid not null references public.revendas(id),
  usuario_id uuid references public.usuarios(id),
  canal_venda_id uuid references public.canais_venda(id),
  tipo_lancamento text not null check (tipo_lancamento in ('entrada', 'venda', 'ajuste', 'correcao')),
  data_hora timestamptz not null default now(),
  status text not null default 'ativo' check (status in ('ativo', 'corrigido', 'cancelado')),
  observacao text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_venda_exige_canal check (
    tipo_lancamento <> 'venda' or canal_venda_id is not null
  )
);

create trigger trg_lancamentos_updated_at
before update on public.lancamentos
for each row execute function public.set_updated_at();

-- =========================================================
-- Tabela: movimentos_estoque
-- Tabela central para estoque e relatórios.
-- =========================================================

create table if not exists public.movimentos_estoque (
  id uuid primary key default gen_random_uuid(),
  lancamento_id uuid not null references public.lancamentos(id) on delete cascade,
  dia_operacional_id uuid not null references public.dias_operacionais(id),
  revenda_id uuid not null references public.revendas(id),
  produto_id uuid not null references public.produtos(id),
  canal_venda_id uuid references public.canais_venda(id),
  usuario_id uuid references public.usuarios(id),
  tipo_movimento text not null check (tipo_movimento in (
    'entrada_cheia',
    'venda_liquido',
    'venda_casco',
    'ajuste_entrada',
    'ajuste_saida',
    'correcao'
  )),
  quantidade integer not null check (quantidade > 0),
  movimento_vinculado_id uuid references public.movimentos_estoque(id),
  status text not null default 'ativo' check (status in ('ativo', 'corrigido', 'cancelado')),
  observacao text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  corrigido_em timestamptz,
  cancelado_em timestamptz,
  constraint chk_movimento_venda_exige_canal check (
    tipo_movimento not in ('venda_liquido', 'venda_casco') or canal_venda_id is not null
  )
);

create trigger trg_movimentos_estoque_updated_at
before update on public.movimentos_estoque
for each row execute function public.set_updated_at();

-- =========================================================
-- Tabela: fechamentos
-- Fechamento físico da noite.
-- =========================================================

create table if not exists public.fechamentos (
  id uuid primary key default gen_random_uuid(),
  dia_operacional_id uuid not null unique references public.dias_operacionais(id) on delete cascade,
  revenda_id uuid not null references public.revendas(id),
  usuario_id uuid references public.usuarios(id),
  data_hora_inicio timestamptz not null default now(),
  data_hora_fim timestamptz,
  status text not null default 'em_andamento' check (status in (
    'em_andamento',
    'conferido',
    'inconsistente',
    'corrigido_apos_revisao',
    'cancelado'
  )),
  observacao text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_fechamentos_updated_at
before update on public.fechamentos
for each row execute function public.set_updated_at();

-- =========================================================
-- Tabela: itens_fechamento
-- Contagem final e comparação calculado x físico.
-- =========================================================

create table if not exists public.itens_fechamento (
  id uuid primary key default gen_random_uuid(),
  fechamento_id uuid not null references public.fechamentos(id) on delete cascade,
  produto_id uuid not null references public.produtos(id),
  cheios_calculados integer not null default 0,
  vazios_calculados integer not null default 0,
  total_calculado integer generated always as (cheios_calculados + vazios_calculados) stored,
  cheios_fisicos integer not null default 0 check (cheios_fisicos >= 0),
  vazios_fisicos integer not null default 0 check (vazios_fisicos >= 0),
  total_fisico integer generated always as (cheios_fisicos + vazios_fisicos) stored,
  diferenca_cheios integer generated always as (cheios_fisicos - cheios_calculados) stored,
  diferenca_vazios integer generated always as (vazios_fisicos - vazios_calculados) stored,
  diferenca_total integer generated always as ((cheios_fisicos + vazios_fisicos) - (cheios_calculados + vazios_calculados)) stored,
  status text not null default 'conferido' check (status in ('conferido', 'inconsistente', 'corrigido')),
  observacao text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (fechamento_id, produto_id)
);

create trigger trg_itens_fechamento_updated_at
before update on public.itens_fechamento
for each row execute function public.set_updated_at();

-- =========================================================
-- Tabela: divergencias_fechamento
-- Diagnóstico das divergências.
-- =========================================================

create table if not exists public.divergencias_fechamento (
  id uuid primary key default gen_random_uuid(),
  fechamento_id uuid not null references public.fechamentos(id) on delete cascade,
  item_fechamento_id uuid not null references public.itens_fechamento(id) on delete cascade,
  produto_id uuid not null references public.produtos(id),
  tipo_divergencia text not null check (tipo_divergencia in (
    'diferenca_cheio',
    'diferenca_vazio',
    'diferenca_total_cascos',
    'divergencia_combinada'
  )),
  diferenca_cheios integer not null default 0,
  diferenca_vazios integer not null default 0,
  diferenca_total integer not null default 0,
  hipotese_provavel text,
  prioridade_revisao text,
  status text not null default 'pendente' check (status in ('pendente', 'em_revisao', 'resolvida', 'sem_conclusao')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  resolvido_em timestamptz
);

create trigger trg_divergencias_fechamento_updated_at
before update on public.divergencias_fechamento
for each row execute function public.set_updated_at();

-- =========================================================
-- Tabela: correcoes
-- Correções preservando o histórico.
-- =========================================================

create table if not exists public.correcoes (
  id uuid primary key default gen_random_uuid(),
  divergencia_id uuid references public.divergencias_fechamento(id),
  lancamento_original_id uuid references public.lancamentos(id),
  movimento_original_id uuid references public.movimentos_estoque(id),
  usuario_id uuid references public.usuarios(id),
  tipo_correcao text not null check (tipo_correcao in (
    'corrigir_quantidade',
    'corrigir_produto',
    'corrigir_canal',
    'adicionar_venda_casco',
    'adicionar_venda_liquido',
    'cancelar_lancamento'
  )),
  descricao text,
  lancamento_correcao_id uuid references public.lancamentos(id),
  movimento_correcao_id uuid references public.movimentos_estoque(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_correcoes_updated_at
before update on public.correcoes
for each row execute function public.set_updated_at();

-- =========================================================
-- Índices úteis para relatórios e consultas
-- =========================================================

create index if not exists idx_dias_operacionais_revenda_data
on public.dias_operacionais (revenda_id, data_operacional);

create index if not exists idx_lancamentos_dia
on public.lancamentos (dia_operacional_id, data_hora);

create index if not exists idx_lancamentos_canal
on public.lancamentos (canal_venda_id);

create index if not exists idx_movimentos_periodo
on public.movimentos_estoque (revenda_id, created_at);

create index if not exists idx_movimentos_relatorio
on public.movimentos_estoque (revenda_id, canal_venda_id, produto_id, tipo_movimento, created_at);

create index if not exists idx_movimentos_dia_produto
on public.movimentos_estoque (dia_operacional_id, produto_id);

create index if not exists idx_itens_fechamento_status
on public.itens_fechamento (status);

create index if not exists idx_divergencias_status
on public.divergencias_fechamento (status);

-- =========================================================
-- Segurança inicial: RLS ativado
-- As políticas de acesso serão criadas em etapa posterior.
-- Pelo SQL Editor, o proprietário do projeto continua conseguindo operar.
-- =========================================================

alter table public.revendas enable row level security;
alter table public.produtos enable row level security;
alter table public.canais_venda enable row level security;
alter table public.usuarios enable row level security;
alter table public.dias_operacionais enable row level security;
alter table public.conferencias_abertura enable row level security;
alter table public.itens_conferencia_abertura enable row level security;
alter table public.lancamentos enable row level security;
alter table public.movimentos_estoque enable row level security;
alter table public.fechamentos enable row level security;
alter table public.itens_fechamento enable row level security;
alter table public.divergencias_fechamento enable row level security;
alter table public.correcoes enable row level security;

-- =========================================================
-- Comentários de documentação no banco
-- =========================================================

comment on table public.movimentos_estoque is 'Tabela central para movimentações de estoque e relatórios de vendas por canal.';
comment on column public.movimentos_estoque.tipo_movimento is 'entrada_cheia, venda_liquido, venda_casco, ajuste_entrada, ajuste_saida ou correcao.';
comment on table public.itens_fechamento is 'Guarda calculado x físico por produto no fechamento da noite.';
comment on table public.divergencias_fechamento is 'Guarda divergências e hipóteses prováveis para revisão.';

-- Fim do schema inicial.
