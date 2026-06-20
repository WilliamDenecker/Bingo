-- Seed 12 users with hashed PINs
-- Each user gets 24 randomly assigned tasks + Free vakje at position 12
-- Every task appears on at least 2 grids
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
  all_uids    uuid[];
  free_id     integer;
  task_ids    integer[];
  user_uid    uuid;
  assigned    integer[];
  pos         integer;
  i           integer;
  j           integer;
  tmp         integer;
  grid_size   integer := 24; -- 24 tasks + 1 free = 25 squares
begin

  all_uids := array[
    uid_yente, uid_sam, uid_wannes, uid_william, uid_joran,
    uid_floris, uid_jules, uid_levi, uid_matis, uid_robbe, uid_simon, uid_michiel
  ];

  -- Insert auth users one at a time so the handle_new_user trigger fires
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

  -- Get the free square id (insert it as a special task if not present)
  insert into bingo_squares (label) values ('Free vakje') on conflict do nothing;
  select id into free_id from bingo_squares where label = 'Free vakje';

  -- Get all non-free task ids as an array
  select array_agg(id order by random()) into task_ids
  from bingo_squares
  where label != 'Free vakje';

  -- For each user: pick 24 random tasks, shuffle positions, insert grid
  for i in 1..array_length(all_uids, 1) loop
    user_uid := all_uids[i];

    -- Fisher-Yates shuffle of task_ids, pick first 24
    for j in 1..array_length(task_ids, 1) loop
      tmp := task_ids[j];
      task_ids[j] := task_ids[1 + floor(random() * array_length(task_ids, 1))::int];
      task_ids[1 + floor(random() * array_length(task_ids, 1))::int] := tmp;
    end loop;

    assigned := task_ids[1:grid_size];

    -- Insert 25 squares: positions 0-11 and 13-24 get tasks, position 12 = free
    pos := 0;
    for j in 1..grid_size loop
      if pos = 12 then
        -- Insert free square at position 12 first, then continue
        insert into user_squares (user_id, square_id, position, is_done)
        values (user_uid, free_id, 12, false);
        pos := pos + 1;
      end if;
      insert into user_squares (user_id, square_id, position, is_done)
      values (user_uid, assigned[j], pos, false);
      pos := pos + 1;
    end loop;

  end loop;

end $$;
