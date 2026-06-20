-- Profiles table linked to Supabase Auth
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  created_at timestamptz default now()
);

-- Shared bingo card template (25 squares, same for all users)
create table if not exists bingo_squares (
  id serial primary key,
  position integer not null unique check (position >= 0 and position <= 24),
  label text not null
);

-- Per-user completion state
create table if not exists user_squares (
  user_id uuid references profiles(id) on delete cascade,
  square_id integer references bingo_squares(id) on delete cascade,
  is_done boolean default false,
  completed_at timestamptz,
  primary key (user_id, square_id)
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

-- Auto-populate user_squares rows when a new profile is created
create or replace function initialize_user_squares()
returns trigger as $$
begin
  insert into user_squares (user_id, square_id, is_done)
  select new.id, id, false
  from bingo_squares;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_profile_created on profiles;
create trigger on_profile_created
  after insert on profiles
  for each row execute function initialize_user_squares();
