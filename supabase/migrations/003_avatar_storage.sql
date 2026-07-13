-- ============================================================
-- PageTurn – Avatar Storage Bucket & RLS Policies
-- Run in the Supabase SQL Editor (Dashboard → SQL Editor → New query)
-- ============================================================

-- Create storage bucket for avatars if not exists
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Policies for avatars bucket

-- 1. Allow public access to view/select avatars
create policy "Public access to avatars bucket"
  on storage.objects for select
  using (bucket_id = 'avatars');

-- 2. Allow authenticated users to upload new avatars
create policy "Authenticated users can upload avatars"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- 3. Allow authenticated users to update their own avatars
create policy "Users can update their own avatars"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- 4. Allow authenticated users to delete their own avatars
create policy "Users can delete their own avatars"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
