-- Run this in Supabase SQL Editor if needed for public.profiles table
-- This links each profile row to the authenticated Supabase user.

create table if not exists public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  name text,
  full_name text,
  email text,
  profile_img text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

alter table public.profiles enable row level security;

drop policy if exists "Users can read own profile" on public.profiles;
drop policy if exists "Authenticated users can read profiles" on public.profiles;

create policy "Authenticated users can read profiles"
on public.profiles for select
to authenticated
using (true);

create policy "Users can insert own profile"
on public.profiles for insert
to authenticated
with check (id = auth.uid());

create policy "Users can update own profile"
on public.profiles for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

