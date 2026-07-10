-- Projeto Fênix Estoque — V5.2
-- Gestão segura de canais por revenda.
-- Regra: preservar histórico; excluir somente canal nunca utilizado.

create or replace function public.listar_revendas_ativas()
returns table (
  revenda_id uuid,
  nome text,
  cidade text
)
language sql
security definer
set search_path = public, pg_temp
as $$
  select r.id, r.nome, r.cidade
  from public.revendas r
  where r.ativa = true
  order by r.nome;
$$;

create or replace function public.listar_canais_revenda(
  p_revenda_id uuid,
  p_incluir_inativos boolean default false
)
returns table (
  canal_venda_id uuid,
  revenda_id uuid,
  nome text,
  ativo boolean
)
language sql
security definer
set search_path = public, pg_temp
as $$
  select cv.id, cv.revenda_id, cv.nome, cv.ativo
  from public.canais_venda cv
  where cv.revenda_id = p_revenda_id
    and (p_incluir_inativos or cv.ativo = true)
  order by cv.ativo desc, cv.nome;
$$;

create or replace function public.cadastrar_canal_revenda(
  p_revenda_id uuid,
  p_nome text
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_nome text := btrim(p_nome);
  v_id uuid;
begin
  if v_nome is null or v_nome = '' then
    raise exception 'O nome do canal é obrigatório.';
  end if;

  if not exists (
    select 1 from public.revendas r
    where r.id = p_revenda_id and r.ativa = true
  ) then
    raise exception 'Revenda inexistente ou inativa.';
  end if;

  if exists (
    select 1
    from public.canais_venda cv
    where cv.revenda_id = p_revenda_id
      and lower(btrim(cv.nome)) = lower(v_nome)
  ) then
    raise exception 'Já existe um canal com esse nome nesta revenda.';
  end if;

  insert into public.canais_venda (revenda_id, nome, ativo)
  values (p_revenda_id, v_nome, true)
  returning id into v_id;

  return v_id;
end;
$$;

create or replace function public.renomear_canal_revenda(
  p_canal_id uuid,
  p_novo_nome text
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_nome text := btrim(p_novo_nome);
  v_revenda_id uuid;
begin
  if v_nome is null or v_nome = '' then
    raise exception 'O novo nome do canal é obrigatório.';
  end if;

  select cv.revenda_id into v_revenda_id
  from public.canais_venda cv
  where cv.id = p_canal_id;

  if v_revenda_id is null then
    raise exception 'Canal não encontrado.';
  end if;

  if exists (
    select 1
    from public.canais_venda cv
    where cv.revenda_id = v_revenda_id
      and cv.id <> p_canal_id
      and lower(btrim(cv.nome)) = lower(v_nome)
  ) then
    raise exception 'Já existe outro canal com esse nome nesta revenda.';
  end if;

  update public.canais_venda
  set nome = v_nome
  where id = p_canal_id;
end;
$$;

create or replace function public.definir_status_canal_revenda(
  p_canal_id uuid,
  p_ativo boolean
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  update public.canais_venda
  set ativo = p_ativo
  where id = p_canal_id;

  if not found then
    raise exception 'Canal não encontrado.';
  end if;
end;
$$;

create or replace function public.excluir_canal_sem_historico(
  p_canal_id uuid
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if exists (
    select 1 from public.lancamentos l
    where l.canal_venda_id = p_canal_id
  ) or exists (
    select 1 from public.movimentos_estoque m
    where m.canal_venda_id = p_canal_id
  ) then
    raise exception 'Este canal possui histórico e não pode ser excluído. Desative-o.';
  end if;

  delete from public.canais_venda
  where id = p_canal_id;

  if not found then
    raise exception 'Canal não encontrado.';
  end if;
end;
$$;

-- Leitura liberada para a aplicação.
grant execute on function public.listar_revendas_ativas() to anon, authenticated;
grant execute on function public.listar_canais_revenda(uuid, boolean) to anon, authenticated;

-- Escrita administrativa: não liberar para anon.
revoke all on function public.cadastrar_canal_revenda(uuid, text) from public, anon;
revoke all on function public.renomear_canal_revenda(uuid, text) from public, anon;
revoke all on function public.definir_status_canal_revenda(uuid, boolean) from public, anon;
revoke all on function public.excluir_canal_sem_historico(uuid) from public, anon;

grant execute on function public.cadastrar_canal_revenda(uuid, text) to authenticated;
grant execute on function public.renomear_canal_revenda(uuid, text) to authenticated;
grant execute on function public.definir_status_canal_revenda(uuid, boolean) to authenticated;
grant execute on function public.excluir_canal_sem_historico(uuid) to authenticated;

-- Testes de leitura
select * from public.listar_revendas_ativas();
select * from public.listar_canais_revenda('407b3516-e4ce-47bc-a048-3e9c8294245d'::uuid, true);
