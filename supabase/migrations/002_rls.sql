-- Enable RLS on all tables
alter table profiles enable row level security;
alter table bingo_squares enable row level security;
alter table user_squares enable row level security;

-- profiles: any authenticated user can read all; only own row updatable
create policy "profiles_select" on profiles
  for select to authenticated using (true);

create policy "profiles_update_own" on profiles
  for update to authenticated using (auth.uid() = id);

-- bingo_squares: read-only for all authenticated users
create policy "bingo_squares_select" on bingo_squares
  for select to authenticated using (true);

-- user_squares: all authenticated can read; only own rows insertable/updatable
create policy "user_squares_select" on user_squares
  for select to authenticated using (true);

create policy "user_squares_insert_own" on user_squares
  for insert to authenticated with check (auth.uid() = user_id);

create policy "user_squares_update_own" on user_squares
  for update to authenticated using (auth.uid() = user_id);
