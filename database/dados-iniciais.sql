-- Projeto Fênix Estoque — Dados iniciais
-- Banco: Supabase / PostgreSQL
-- Objetivo: cadastrar a revenda inicial, produtos, canais de venda e usuário operacional.

-- =========================================================
-- Revenda inicial
-- =========================================================

insert into public.revendas (nome, cidade, ativa)
values ('Várzea Gás', 'Várzea Paulista/SP', true)
on conflict (nome) do update set
  cidade = excluded.cidade,
  ativa = excluded.ativa;

-- =========================================================
-- Produtos iniciais
-- =========================================================

insert into public.produtos (codigo, nome, tipo, controla_cheio_vazio, ativo, ordem_exibicao)
values
  ('P13', 'P13 — Gás de cozinha 13 kg', 'botijao', true, true, 1),
  ('P05', 'P05 — Botijão 5 kg', 'botijao', true, true, 2),
  ('P20', 'P20 — Botijão 20 kg', 'botijao', true, true, 3),
  ('P45', 'P45 — Botijão 45 kg', 'botijao', true, true, 4),
  ('AGUA', 'Água/galão', 'galao_agua', true, true, 5),
  ('OUTROS', 'Outros', 'outro', true, false, 99)
on conflict (codigo) do update set
  nome = excluded.nome,
  tipo = excluded.tipo,
  controla_cheio_vazio = excluded.controla_cheio_vazio,
  ativo = excluded.ativo,
  ordem_exibicao = excluded.ordem_exibicao;

-- =========================================================
-- Canais de venda da Várzea Gás
-- =========================================================

insert into public.canais_venda (revenda_id, nome, ativo, ordem_exibicao)
select r.id, c.nome, c.ativo, c.ordem_exibicao
from public.revendas r
cross join (
  values
    ('André', true, 1),
    ('João', true, 2),
    ('Rogério', true, 3),
    ('Portaria', true, 4),
    ('Outros', false, 99)
) as c(nome, ativo, ordem_exibicao)
where r.nome = 'Várzea Gás'
on conflict (revenda_id, nome) do update set
  ativo = excluded.ativo,
  ordem_exibicao = excluded.ordem_exibicao;

-- =========================================================
-- Usuário operacional inicial
-- Observação: este usuário é interno do Fênix, não é a senha do Supabase.
-- =========================================================

insert into public.usuarios (nome, telefone, email, perfil, ativo)
values ('Operador Várzea Gás', null, null, 'administrador', true);

-- =========================================================
-- Consultas de conferência
-- =========================================================

select 'revendas' as tabela, count(*) as total from public.revendas
union all
select 'produtos' as tabela, count(*) as total from public.produtos
union all
select 'canais_venda' as tabela, count(*) as total from public.canais_venda
union all
select 'usuarios' as tabela, count(*) as total from public.usuarios;
