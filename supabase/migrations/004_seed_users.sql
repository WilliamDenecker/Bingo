-- Seed 12 users with explicit grids
-- To change someone's grid: edit their task array below (24 tasks, position 12 = Free vakje)
-- PINs:
--   Yente   -> 7823  |  Sam     -> 4156  |  Wannes  -> 9034  |  William -> 3871
--   Joran   -> 6249  |  Floris  -> 5318  |  Jules   -> 2947  |  Levi    -> 8063
--   Matis   -> 1594  |  Robbe   -> 7402  |  Simon   -> 3786  |  Michiel -> 6127

-- Helper function must be created before the do $$ block that calls it
create or replace function insert_grid(p_uid uuid, p_tasks text[]) returns void as $$
declare
  free_id integer;
  task_id integer;
  pos     integer := 0;
  j       integer;
begin
  select id into free_id from bingo_squares where label = 'Free vakje';
  for j in 1..24 loop
    if pos = 12 then
      insert into user_squares (user_id, square_id, position, is_done)
      values (p_uid, free_id, 12, false);
      pos := pos + 1;
    end if;
    select id into task_id from bingo_squares where label = p_tasks[j];
    if task_id is null then
      raise exception 'Task not found in bingo_squares: "%"', p_tasks[j];
    end if;
    insert into user_squares (user_id, square_id, position, is_done)
    values (p_uid, task_id, pos, false);
    pos := pos + 1;
  end loop;
end;
$$ language plpgsql;

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

  -- ============================================================
  -- EDIT GRIDS HERE — 24 tasks per person (position 12 = Free vakje auto-inserted)
  -- Use exact labels from bingo_squares table (003_seed.sql)
  -- ============================================================

  yente_tasks text[] := array[
    'win 10 euro in sportbed', 'Breakfast beers', 'We zijn iemand kwijt', 'selfie me randoms',
    'groep mensen/kinders 67 laten doen', 'Roha wakker maken', 'Irish goodbye', 'Open flesje bier op 5 verschillende manieren',
    'Roulette', 'Barfje', 'blaffen naar vreemden', 'Iemand verliest GSM',
    -- position 12 = Free vakje (auto)
    'achter DJ booth', 'Items stacken op iemand >= 0.5m', 'zon zien opkomen', 'doe YMCA -> vraag aan in een club',
    'buitengesmeten uit cafe', 'Adjes estafette', 'vliegtuig applaus', 'Slide in de DM''s',
    'Iemand verliest sleutels', 'airport beers', 'Koop een souvenir', 'Polonaise'
  ];

  sam_tasks text[] := array[
    'Breakfast beers', 'selfie me randoms', 'Win potje clash royal tegen Joran', 'Koop een seksspeeltje',
    'Start Le lac de connemara (mag thuis)', 'Roha geragebait', 'Simon Wietjes', 'een niet nederlandstalig Dekerk67 laten zeggen',
    'Vraag de weg aan iemand en ga de omgekeerde kant op', 'Rene Le Blanc', 'meer dan twee keer in 24 uur fast food', 'we verliezen waarborg',
    -- position 12 = Free vakje (auto)
    'Joran: Lloret dansmovekes', 'Yente op uitstap met dame', 'bij iemand met een hond vragen voor te aaien en dan hun aaien', 'Gaslight iemand om ... te geloven',
    'Challenge van een vreemde krijgen en voltooien', 'Adje met broek op uw enkels (openbaar)', 'fight me rando''s', 'Simon wietje',
    'Potje Brawl in de club', 'Happybd zingen voor een vreemden', 'Split the GG', 'Badkamerfissa'
  ];

  wannes_tasks text[] := array[
    'win 10 euro in sportbed', 'We zijn iemand kwijt', 'Koop een seksspeeltje', 'Irish goodbye',
    'Roulette', 'Start Le lac de connemara (mag thuis)', 'Barfje', 'Roha geragebait',
    'Iemand verliest GSM', 'Simon Wietjes', 'een niet nederlandstalig Dekerk67 laten zeggen', 'zon zien opkomen',
    -- position 12 = Free vakje (auto)
    'Rene Le Blanc', 'buitengesmeten uit cafe', 'er is ruzie wegens zetelke', 'Joran: Lloret dansmovekes',
    'vliegtuig applaus', 'Gaslight iemand om ... te geloven', 'Slide in de DM''s', 'fight me rando''s',
    'Floris: vind ne Fransen', 'Toertjes draaien rond borstel/stok dan pintje ad', 'Drank voor 10u', 'overtuig een dj om Belgische muziek te spelen'
  ];

  william_tasks text[] := array[
    'Breakfast beers', 'selfie me randoms', 'groep mensen/kinders 67 laten doen', 'Roha wakker maken',
    'Win potje clash royal tegen Joran', 'Open flesje bier op 5 verschillende manieren', 'Barfje', 'blaffen naar vreemden',
    'achter DJ booth', 'Items stacken op iemand >= 0.5m', 'doe YMCA -> vraag aan in een club', 'Rene Le Blanc',
    -- position 12 = Free vakje (auto)
    'meer dan twee keer in 24 uur fast food', 'we verliezen waarborg', 'Yente op uitstap met dame', 'Adjes estafette',
    'bij iemand met een hond vragen voor te aaien en dan hun aaien', 'Challenge van een vreemde krijgen en voltooien', 'Iemand verliest sleutels', 'Adje met broek op uw enkels (openbaar)',
    'Simon wietje', 'Vraag een selfie met een vreemde alzof ie bekend is', 'Koop een souvenir', 'in een fontein of vijver gaan'
  ];

  joran_tasks text[] := array[
    'win 10 euro in sportbed', 'We zijn iemand kwijt', 'Koop een seksspeeltje', 'Irish goodbye',
    'Start Le lac de connemara (mag thuis)', 'Roha geragebait', 'Iemand verliest GSM', 'achter DJ booth',
    'een niet nederlandstalig Dekerk67 laten zeggen', 'Vraag de weg aan iemand en ga de omgekeerde kant op', 'doe YMCA -> vraag aan in een club', 'er is ruzie wegens zetelke',
    -- position 12 = Free vakje (auto)
    'Joran: Lloret dansmovekes', 'Adjes estafette', 'vliegtuig applaus', 'bij iemand met een hond vragen voor te aaien en dan hun aaien',
    'Slide in de DM''s', 'Iemand verliest sleutels', 'airport beers', 'Potje Brawl in de club',
    'Toertjes draaien rond borstel/stok dan pintje ad', 'Happybd zingen voor een vreemden', 'Split the GG', 'Polonaise'
  ];

  floris_tasks text[] := array[
    'Breakfast beers', 'selfie me randoms', 'groep mensen/kinders 67 laten doen', 'Roha wakker maken',
    'Win potje clash royal tegen Joran', 'Open flesje bier op 5 verschillende manieren', 'Roulette', 'Simon Wietjes',
    'Items stacken op iemand >= 0.5m', 'zon zien opkomen', 'Rene Le Blanc', 'buitengesmeten uit cafe',
    -- position 12 = Free vakje (auto)
    'we verliezen waarborg', 'Yente op uitstap met dame', 'Gaslight iemand om ... te geloven', 'Challenge van een vreemde krijgen en voltooien',
    'fight me rando''s', 'Floris: vind ne Fransen', 'Floris: Kraslotjes in vliegtuig', 'Slechte openingszin proberen',
    'Singles: naar de mama/papa bellen en zeggen dat je de liefde van uw leven ontmoet hebt', 'in een fontein of vijver gaan', 'overtuig een dj om Belgische muziek te spelen', 'Drank voor 10u'
  ];

  jules_tasks text[] := array[
    'win 10 euro in sportbed', 'We zijn iemand kwijt', 'Irish goodbye', 'Barfje',
    'Roha geragebait', 'blaffen naar vreemden', 'Iemand verliest GSM', 'Simon Wietjes',
    'een niet nederlandstalig Dekerk67 laten zeggen', 'Vraag de weg aan iemand en ga de omgekeerde kant op', 'Rene Le Blanc', 'meer dan twee keer in 24 uur fast food',
    -- position 12 = Free vakje (auto)
    'er is ruzie wegens zetelke', 'Joran: Lloret dansmovekes', 'Adjes estafette', 'bij iemand met een hond vragen voor te aaien en dan hun aaien',
    'Challenge van een vreemde krijgen en voltooien', 'Slide in de DM''s', 'Adje met broek op uw enkels (openbaar)', 'airport beers',
    'Vraag een selfie met een vreemde alzof ie bekend is', 'Koop een souvenir', 'Badkamerfissa', 'Polonaise'
  ];

  levi_tasks text[] := array[
    'Breakfast beers', 'selfie me randoms', 'groep mensen/kinders 67 laten doen', 'Koop een seksspeeltje',
    'Roulette', 'Start Le lac de connemara (mag thuis)', 'Open flesje bier op 5 verschillende manieren', 'achter DJ booth',
    'Items stacken op iemand >= 0.5m', 'zon zien opkomen', 'doe YMCA -> vraag aan in een club', 'buitengesmeten uit cafe',
    -- position 12 = Free vakje (auto)
    'we verliezen waarborg', 'Yente op uitstap met dame', 'vliegtuig applaus', 'Gaslight iemand om ... te geloven',
    'Iemand verliest sleutels', 'fight me rando''s', 'Simon wietje', 'Potje Brawl in de club',
    'Toertjes draaien rond borstel/stok dan pintje ad', 'Split the GG', 'Drank voor 10u', 'in een fontein of vijver gaan'
  ];

  matis_tasks text[] := array[
    'win 10 euro in sportbed', 'We zijn iemand kwijt', 'Roha wakker maken', 'Win potje clash royal tegen Joran',
    'Irish goodbye', 'Barfje', 'Roha geragebait', 'blaffen naar vreemden',
    'Simon Wietjes', 'een niet nederlandstalig Dekerk67 laten zeggen', 'Vraag de weg aan iemand en ga de omgekeerde kant op', 'er is ruzie wegens zetelke',
    -- position 12 = Free vakje (auto)
    'Joran: Lloret dansmovekes', 'bij iemand met een hond vragen voor te aaien en dan hun aaien', 'Challenge van een vreemde krijgen en voltooien', 'Slide in de DM''s',
    'Adje met broek op uw enkels (openbaar)', 'airport beers', 'Floris: vind ne Fransen', 'Happybd zingen voor een vreemden',
    'Vraag een selfie met een vreemde alzof ie bekend is', 'Koop een souvenir', 'stripclub visit', 'overtuig een dj om Belgische muziek te spelen'
  ];

  robbe_tasks text[] := array[
    'Breakfast beers', 'selfie me randoms', 'groep mensen/kinders 67 laten doen', 'Koop een seksspeeltje',
    'Open flesje bier op 5 verschillende manieren', 'Roulette', 'Start Le lac de connemara (mag thuis)', 'achter DJ booth',
    'Items stacken op iemand >= 0.5m', 'zon zien opkomen', 'doe YMCA -> vraag aan in een club', 'Rene Le Blanc',
    -- position 12 = Free vakje (auto)
    'meer dan twee keer in 24 uur fast food', 'we verliezen waarborg', 'Adjes estafette', 'vliegtuig applaus',
    'Gaslight iemand om ... te geloven', 'fight me rando''s', 'Simon wietje', 'Toertjes draaien rond borstel/stok dan pintje ad',
    'Split the GG', 'Badkamerfissa', 'Tactisch fapje', 'Polonaise'
  ];

  simon_tasks text[] := array[
    'win 10 euro in sportbed', 'We zijn iemand kwijt', 'Roha wakker maken', 'Win potje clash royal tegen Joran',
    'Koop een seksspeeltje', 'Irish goodbye', 'Barfje', 'blaffen naar vreemden',
    'Iemand verliest GSM', 'een niet nederlandstalig Dekerk67 laten zeggen', 'Vraag de weg aan iemand en ga de omgekeerde kant op', 'buitengesmeten uit cafe',
    -- position 12 = Free vakje (auto)
    'er is ruzie wegens zetelke', 'Yente op uitstap met dame', 'bij iemand met een hond vragen voor te aaien en dan hun aaien', 'Slide in de DM''s',
    'Iemand verliest sleutels', 'Adje met broek op uw enkels (openbaar)', 'airport beers', 'Potje Brawl in de club',
    'Happybd zingen voor een vreemden', 'Koop een souvenir', 'Drank voor 10u', 'in een fontein of vijver gaan'
  ];

  michiel_tasks text[] := array[
    'Breakfast beers', 'selfie me randoms', 'groep mensen/kinders 67 laten doen', 'Open flesje bier op 5 verschillende manieren',
    'Roulette', 'Start Le lac de connemara (mag thuis)', 'Roha geragebait', 'Simon Wietjes',
    'achter DJ booth', 'zon zien opkomen', 'doe YMCA -> vraag aan in een club', 'Rene Le Blanc',
    -- position 12 = Free vakje (auto)
    'meer dan twee keer in 24 uur fast food', 'we verliezen waarborg', 'Joran: Lloret dansmovekes', 'Adjes estafette',
    'vliegtuig applaus', 'Challenge van een vreemde krijgen en voltooien', 'fight me rando''s', 'Floris: vind ne Fransen',
    'Vraag een selfie met een vreemde alzof ie bekend is', 'Split the GG', 'stripclub visit', 'overtuig een dj om Belgische muziek te spelen'
  ];

begin

  -- Insert auth users
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_yente,   'yente@bingo.local',   crypt('7823', gen_salt('bf')), now(), now(), now(), '{"display_name":"Yente"}',   'authenticated', 'authenticated');
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_sam,     'sam@bingo.local',     crypt('4156', gen_salt('bf')), now(), now(), now(), '{"display_name":"Sam"}',     'authenticated', 'authenticated');
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_wannes,  'wannes@bingo.local',  crypt('9034', gen_salt('bf')), now(), now(), now(), '{"display_name":"Wannes"}',  'authenticated', 'authenticated');
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_william, 'william@bingo.local', crypt('3871', gen_salt('bf')), now(), now(), now(), '{"display_name":"William"}', 'authenticated', 'authenticated');
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_joran,   'joran@bingo.local',   crypt('6249', gen_salt('bf')), now(), now(), now(), '{"display_name":"Joran"}',   'authenticated', 'authenticated');
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_floris,  'floris@bingo.local',  crypt('5318', gen_salt('bf')), now(), now(), now(), '{"display_name":"Floris"}',  'authenticated', 'authenticated');
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_jules,   'jules@bingo.local',   crypt('2947', gen_salt('bf')), now(), now(), now(), '{"display_name":"Jules"}',   'authenticated', 'authenticated');
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_levi,    'levi@bingo.local',    crypt('8063', gen_salt('bf')), now(), now(), now(), '{"display_name":"Levi"}',    'authenticated', 'authenticated');
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_matis,   'matis@bingo.local',   crypt('1594', gen_salt('bf')), now(), now(), now(), '{"display_name":"Matis"}',   'authenticated', 'authenticated');
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_robbe,   'robbe@bingo.local',   crypt('7402', gen_salt('bf')), now(), now(), now(), '{"display_name":"Robbe"}',   'authenticated', 'authenticated');
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_simon,   'simon@bingo.local',   crypt('3786', gen_salt('bf')), now(), now(), now(), '{"display_name":"Simon"}',   'authenticated', 'authenticated');
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data, aud, role)
  values (uid_michiel, 'michiel@bingo.local', crypt('6127', gen_salt('bf')), now(), now(), now(), '{"display_name":"Michiel"}', 'authenticated', 'authenticated');

  -- Fix Supabase auth fields so password login works
  update auth.users set
    instance_id = '00000000-0000-0000-0000-000000000000',
    confirmation_token = '', recovery_token = '',
    email_change_token_new = '', email_change = ''
  where email like '%@bingo.local';

  -- Insert each user's grid explicitly (avoids PL/pgSQL 2D array issues)
  perform insert_grid(uid_yente,   yente_tasks);
  perform insert_grid(uid_sam,     sam_tasks);
  perform insert_grid(uid_wannes,  wannes_tasks);
  perform insert_grid(uid_william, william_tasks);
  perform insert_grid(uid_joran,   joran_tasks);
  perform insert_grid(uid_floris,  floris_tasks);
  perform insert_grid(uid_jules,   jules_tasks);
  perform insert_grid(uid_levi,    levi_tasks);
  perform insert_grid(uid_matis,   matis_tasks);
  perform insert_grid(uid_robbe,   robbe_tasks);
  perform insert_grid(uid_simon,   simon_tasks);
  perform insert_grid(uid_michiel, michiel_tasks);

end $$;
