-- Изпълни целия файл веднъж в Supabase:
-- Dashboard > SQL Editor > New query > постави кода > Run

create table if not exists public.app_state (
    user_id uuid primary key references auth.users(id) on delete cascade,
    data jsonb not null default '{}'::jsonb,
    updated_at timestamptz not null default now()
);

alter table public.app_state enable row level security;

revoke all on table public.app_state from anon;
grant select, insert, update, delete on table public.app_state to authenticated;

drop policy if exists "Users read own AromaControl data" on public.app_state;
create policy "Users read own AromaControl data"
on public.app_state
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users create own AromaControl data" on public.app_state;
create policy "Users create own AromaControl data"
on public.app_state
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users update own AromaControl data" on public.app_state;
create policy "Users update own AromaControl data"
on public.app_state
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users delete own AromaControl data" on public.app_state;
create policy "Users delete own AromaControl data"
on public.app_state
for delete
to authenticated
using ((select auth.uid()) = user_id);

comment on table public.app_state is
'Защитено облачно състояние на AromaControl. Всеки потребител вижда само собствения си ред.';
