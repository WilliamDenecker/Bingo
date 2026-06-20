-- Seed 12 users with hashed PINs and randomized bingo squares
-- PINs:
--   Yente   -> 7823
--   Sam     -> 4156
--   Wannes  -> 9034
--   William -> 3871
--   Joran   -> 6249
--   Floris  -> 5318
--   Jules   -> 2947
--   Levi    -> 8063
--   Matis   -> 1594
--   Robbe   -> 7402
--   Simon   -> 3786
--   Michiel -> 6127

do $$
declare
  uid_yente   uuid := gen_random_uuid();
  uid_sam     uuid := gen_random_uuid();
  uid_wannes  uuid := gen_random_uuid();
  uid_william uuid := gen_random_uuid();
  uid_joran   uuid := gen_random_uuid();
  uid_floris  uuid := gen_random_uuid();
  uid_jules   uuid := gen_random_uuid();
  uid_levi    uuid := gen_random_uuid();
  uid_matis   uuid := gen_random_uuid();
  uid_robbe   uuid := gen_random_uuid();
  uid_simon   uuid := gen_random_uuid();
  uid_michiel uuid := gen_random_uuid();
begin

  -- Insert auth users one at a time so the trigger fires per row.
  -- The trigger auto-creates the profile and user_squares for each user.
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_yente, 'yente@bingo.local', crypt('7823', gen_salt('bf')), now(), now(), now(), '{"display_name":"Yente"}', 'authenticated', 'authenticated');

  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_sam, 'sam@bingo.local', crypt('4156', gen_salt('bf')), now(), now(), now(), '{"display_name":"Sam"}', 'authenticated', 'authenticated');

  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_wannes, 'wannes@bingo.local', crypt('9034', gen_salt('bf')), now(), now(), now(), '{"display_name":"Wannes"}', 'authenticated', 'authenticated');

  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_william, 'william@bingo.local', crypt('3871', gen_salt('bf')), now(), now(), now(), '{"display_name":"William"}', 'authenticated', 'authenticated');

  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_joran, 'joran@bingo.local', crypt('6249', gen_salt('bf')), now(), now(), now(), '{"display_name":"Joran"}', 'authenticated', 'authenticated');

  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_floris, 'floris@bingo.local', crypt('5318', gen_salt('bf')), now(), now(), now(), '{"display_name":"Floris"}', 'authenticated', 'authenticated');

  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_jules, 'jules@bingo.local', crypt('2947', gen_salt('bf')), now(), now(), now(), '{"display_name":"Jules"}', 'authenticated', 'authenticated');

  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_levi, 'levi@bingo.local', crypt('8063', gen_salt('bf')), now(), now(), now(), '{"display_name":"Levi"}', 'authenticated', 'authenticated');

  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_matis, 'matis@bingo.local', crypt('1594', gen_salt('bf')), now(), now(), now(), '{"display_name":"Matis"}', 'authenticated', 'authenticated');

  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_robbe, 'robbe@bingo.local', crypt('7402', gen_salt('bf')), now(), now(), now(), '{"display_name":"Robbe"}', 'authenticated', 'authenticated');

  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_simon, 'simon@bingo.local', crypt('3786', gen_salt('bf')), now(), now(), now(), '{"display_name":"Simon"}', 'authenticated', 'authenticated');

  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_michiel, 'michiel@bingo.local', crypt('6127', gen_salt('bf')), now(), now(), now(), '{"display_name":"Michiel"}', 'authenticated', 'authenticated');

  -- Fix required Supabase auth fields so password login works
  update auth.users
  set
    instance_id = '00000000-0000-0000-0000-000000000000',
    confirmation_token = '',
    recovery_token = '',
    email_change_token_new = '',
    email_change = ''
  where email like '%@bingo.local';

  -- Randomize user_squares (trigger already inserted all rows as false,
  -- so we just update a random ~40% to done)
  update user_squares
  set
    is_done = true,
    completed_at = now() - (random() * interval '7 days')
  where
    user_id in (
      uid_yente, uid_sam, uid_wannes, uid_william, uid_joran,
      uid_floris, uid_jules, uid_levi, uid_matis, uid_robbe, uid_simon, uid_michiel
    )
    and random() < 0.4;

end $$;
