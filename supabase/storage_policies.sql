-- Run this in Supabase Dashboard > SQL Editor.
-- The Flutter code uploads to: shop-images/<auth.uid>/<timestamp>.<extension>

insert into storage.buckets (id, name, public)
values ('shop-images', 'shop-images', true)
on conflict (id) do update set public = true;

drop policy if exists "Shop images: authenticated users can upload to own folder"
  on storage.objects;
drop policy if exists "Shop images: authenticated users can read own folder"
  on storage.objects;
drop policy if exists "Shop images: authenticated users can update own folder"
  on storage.objects;
drop policy if exists "Shop images: authenticated users can delete own folder"
  on storage.objects;

create policy "Shop images: authenticated users can upload to own folder"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'shop-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Shop images: authenticated users can read own folder"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'shop-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Shop images: authenticated users can update own folder"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'shop-images'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'shop-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Shop images: authenticated users can delete own folder"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'shop-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);
