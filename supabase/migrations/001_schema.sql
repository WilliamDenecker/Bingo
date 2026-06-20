-- Profiles table linked to Supabase Auth
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  created_at timestamptz default now()
);

-- Task pool — all possible bingo tasks (no position, shared reference)
create table if not exists bingo_squares (
  id serial primary key,
  label text not null
);

-- Per-user grid: each user gets 25 tasks assigned to positions 0-24
create table if not exists user_squares (
  user_id uuid references profiles(id) on delete cascade,
  square_id integer references bingo_squares(id) on delete cascade,
  position integer not null check (position >= 0 and position <= 24),
  is_done boolean default false,
  completed_at timestamptz,
  primary key (user_id, square_id),
  unique (user_id, position)
);

-- Auto-create profile on first sign-up
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1)));
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();
