-- Add proof photo URL to user_squares
alter table user_squares add column if not exists proof_url text;

-- Storage bucket for proof photos
insert into storage.buckets (id, name, public)
values ('proofs', 'proofs', true)
on conflict (id) do nothing;

create policy "proofs_insert_own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'proofs' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "proofs_update_own" on storage.objects
  for update to authenticated
  using (bucket_id = 'proofs' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "proofs_delete_own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'proofs' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "proofs_select_public" on storage.objects
  for select to public
  using (bucket_id = 'proofs');
