-- Run in Supabase SQL Editor (fixes missing profile rows after signup / blocked upserts under RLS).
--
-- 1) Replace the single "FOR ALL" policy with explicit SELECT / INSERT / UPDATE / DELETE.
-- 2) Auto-insert an empty profiles row when a user signs up (updates then work reliably).

-- ─── RLS policies for profiles ───────────────────────────────────────────────

alter table public.profiles enable row level security;

drop policy if exists "Users can manage own data" on public.profiles;

drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;
drop policy if exists "profiles_delete_own" on public.profiles;

create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles_insert_own"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "profiles_delete_own"
  on public.profiles for delete
  using (auth.uid() = id);

-- ─── Trigger: create profile stub on new auth user ───────────────────────────

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Optional: backfill profiles for existing auth users that have no row yet
insert into public.profiles (id)
select u.id from auth.users u
where not exists (select 1 from public.profiles p where p.id = u.id)
on conflict (id) do nothing;
