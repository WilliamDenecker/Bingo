-- Add avatar_url column to profiles
alter table profiles add column if not exists avatar_url text;

-- Storage bucket for avatars (run via Supabase dashboard or CLI if not using storage API)
-- The bucket "avatars" must be created in Supabase Storage with public access.
-- Policies below assume the bucket exists.

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Allow authenticated users to upload their own avatar
create policy "avatars_insert_own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

-- Allow authenticated users to update/delete their own avatar
create policy "avatars_update_own" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "avatars_delete_own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

-- Public read for all avatars
create policy "avatars_select_public" on storage.objects
  for select to public
  using (bucket_id = 'avatars');
