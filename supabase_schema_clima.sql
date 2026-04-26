-- Sistema de Clima Organizacional | Supabase schema
-- Executar no SQL Editor do Supabase.
-- Depois criar pelo menos um utilizador em Authentication > Users.

create extension if not exists pgcrypto;

create table if not exists public.clima_clients (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid(),
  name text not null,
  sector text,
  expected_responses integer default 0,
  departments text[] default '{}',
  areas text[] default '{}',
  locations text[] default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.clima_surveys (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clima_clients(id) on delete cascade,
  owner_id uuid not null default auth.uid(),
  title text not null default 'Estudo de Clima Organizacional',
  public_token text not null unique default encode(gen_random_bytes(12), 'hex'),
  is_open boolean not null default true,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.clima_responses (
  id uuid primary key default gen_random_uuid(),
  survey_id uuid not null references public.clima_surveys(id) on delete cascade,
  survey_token text not null,
  submitted_at timestamptz not null default now(),
  consent boolean not null default true,
  gender text,
  age text,
  area text,
  department text,
  location text,
  tenure text,
  work_mode text,
  enps integer check (enps is null or (enps >= 0 and enps <= 10)),
  answers jsonb not null default '{}',
  open1 text,
  open2 text,
  open3 text
);

create index if not exists idx_clima_surveys_client_id on public.clima_surveys(client_id);
create index if not exists idx_clima_surveys_public_token on public.clima_surveys(public_token);
create index if not exists idx_clima_responses_survey_id on public.clima_responses(survey_id);
create index if not exists idx_clima_responses_submitted_at on public.clima_responses(submitted_at);

alter table public.clima_clients enable row level security;
alter table public.clima_surveys enable row level security;
alter table public.clima_responses enable row level security;

drop policy if exists "consultants manage own clients" on public.clima_clients;
create policy "consultants manage own clients"
on public.clima_clients
for all
to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

drop policy if exists "consultants manage own surveys" on public.clima_surveys;
create policy "consultants manage own surveys"
on public.clima_surveys
for all
to authenticated
using ((select auth.uid()) = owner_id)
with check (
  (select auth.uid()) = owner_id
  and exists (
    select 1
    from public.clima_clients c
    where c.id = client_id
      and c.owner_id = (select auth.uid())
  )
);

drop policy if exists "public can read open survey by token" on public.clima_surveys;
create policy "public can read open survey by token"
on public.clima_surveys
for select
to anon
using (is_open = true);

drop policy if exists "consultants read own responses" on public.clima_responses;
create policy "consultants read own responses"
on public.clima_responses
for select
to authenticated
using (
  exists (
    select 1
    from public.clima_surveys s
    where s.id = survey_id
      and s.owner_id = (select auth.uid())
  )
);

drop policy if exists "public insert response to open survey" on public.clima_responses;
create policy "public insert response to open survey"
on public.clima_responses
for insert
to anon
with check (
  consent = true
  and exists (
    select 1
    from public.clima_surveys s
    where s.id = survey_id
      and s.public_token = survey_token
      and s.is_open = true
      and (s.starts_at is null or now() >= s.starts_at)
      and (s.ends_at is null or now() <= s.ends_at)
  )
);

drop policy if exists "authenticated insert own response imports" on public.clima_responses;
create policy "authenticated insert own response imports"
on public.clima_responses
for insert
to authenticated
with check (
  exists (
    select 1
    from public.clima_surveys s
    where s.id = survey_id
      and s.owner_id = (select auth.uid())
  )
);

drop policy if exists "consultants delete own responses" on public.clima_responses;
create policy "consultants delete own responses"
on public.clima_responses
for delete
to authenticated
using (
  exists (
    select 1
    from public.clima_surveys s
    where s.id = survey_id
      and s.owner_id = (select auth.uid())
  )
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_clima_clients_updated_at on public.clima_clients;
create trigger trg_clima_clients_updated_at
before update on public.clima_clients
for each row execute function public.set_updated_at();

drop trigger if exists trg_clima_surveys_updated_at on public.clima_surveys;
create trigger trg_clima_surveys_updated_at
before update on public.clima_surveys
for each row execute function public.set_updated_at();
