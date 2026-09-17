-- Run this once in Supabase SQL Editor.
-- auth_uid links each shop row to the authenticated Supabase user.

alter table public.shops
  add column if not exists auth_uid uuid references auth.users(id);

create index if not exists shops_auth_uid_idx
  on public.shops (auth_uid);

alter table public.shops enable row level security;

drop policy if exists "Users can read their own shop" on public.shops;
drop policy if exists "Users can create their own shop" on public.shops;
drop policy if exists "Users can update their own shop" on public.shops;

create policy "Users can read their own shop"
on public.shops for select
to authenticated
using (auth_uid = auth.uid());

create policy "Users can create their own shop"
on public.shops for insert
to authenticated
with check (auth_uid = auth.uid());

create policy "Users can update their own shop"
on public.shops for update
to authenticated
using (auth_uid = auth.uid())
with check (auth_uid = auth.uid());