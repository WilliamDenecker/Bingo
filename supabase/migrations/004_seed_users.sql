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
    'Iemand gaat op uitstap met een dame', 'Airport beers', 'Doe de Joran Lloret-dansmoves bij de huzz', 'De driesprong doen',
    'Le Lac du Connemara inzetten', 'We zijn iemand van de groep kwijt', 'Roulette spelen (minimale inzet 10 euro)', 'Een souvenir kopen',
    'Een liefdesverklaring doen', '€10 winnen op Sportbet', 'Split the G', 'Een polonaise meedoen in de club',
    -- position 12 = Free vakje (auto)
    'Op één dag op 4 verschillende locaties een pint drinken', 'Een seksspeeltje kopen', 'Een tactisch fapje', 'Een adjesestafette doen, minimaal 3 vs 3',
    'Robbe wakker maken', 'Op de toog dansen', 'Een adje doen met je broek op je enkels (in het openbaar)', 'Minstens 0.5m aan spullen op iemand stapelen',
    'Een potje Brawl Stars spelen in de club', 'In een fontein of vijver gaan', 'Je mama of papa bellen en zeggen dat je de liefde van je leven hebt ontmoet', 'Een potje Clash Royale winnen tegen Joran'
  ];

  sam_tasks text[] := array[
    'Een dance battle doen met een vreemde in de club', 'Blaffen naar vreemden', 'Airport beers', 'koop een kraslotje op het vliegtuig (als ze niet verkopen: Win 10 euro op sport bed)',
    'Een adjesestafette doen, minimaal 3 vs 3', 'Iemand gaat op uitstap met een dame', 'Een seksspeeltje kopen', 'Op de toog dansen',
    'De waarborg van het appartement verliezen', 'Een souvenir kopen', 'Robbe wakker maken', 'Een potje Brawl Stars spelen in de club',
    -- position 12 = Free vakje (auto)
    'Yente een compleet absurd verhaal laten geloven', 'Een tactisch fapje', 'In een fontein of vijver gaan', 'Een potje Clash Royale winnen tegen Joran',
    'Een Irish goodbye doen', 'Applaudisseren wanneer het vliegtuig landt', 'Ragebait iemand succesvol', 'Alcohol drinken vóór 10:00 uur',
    'Split the G', 'De zon zien opkomen', 'Breakfast beers', 'Drie of meer keren fastfood eten binnen 24 uur'
  ];

  wannes_tasks text[] := array[
    'Een DJ overtuigen om Belgische muziek te spelen', 'Een adje doen met je broek op je enkels (in het openbaar)', 'Airport beers', 'Een adjesestafette doen, minimaal 3 vs 3',
    'Alcohol drinken vóór 10:00 uur', 'Een liefdesverklaring doen', 'Iemand verliest zijn gsm', 'koop een kraslotje op het vliegtuig (als ze niet verkopen: Win 10 euro op sport bed)',
    '€10 winnen op Sportbet', 'Een potje Brawl Stars spelen in de club', 'Happy Birthday zingen voor een vreemde', 'Een Belgisch biertje drinken in Praag',
    -- position 12 = Free vakje (auto)
    'We zijn iemand van de groep kwijt', 'Yente een compleet absurd verhaal laten geloven', 'Een stripclub bezoeken', 'In een fontein of vijver gaan',
    'Split the G', 'Applaudisseren wanneer het vliegtuig landt', 'Een polonaise meedoen in de club', 'Een souvenir kopen',
    'Een bierflesje op 5 verschillende manieren openen', 'Minstens 0.5m aan spullen op iemand stapelen', 'Een tactisch fapje', 'De driesprong doen'
  ];

  william_tasks text[] := array[
    'Een adjesestafette doen, minimaal 3 vs 3', '10 toertijes tond een borstel/stok draaien tot je duizelig bent en daarna een pint adten', 'Een Irish goodbye doen', 'Airport beers',
    'Glas stelen uit een café', 'Een selfie nemen met random mensen', 'Iemand gaat op uitstap met een dame', 'Een dance battle doen met een vreemde in de club',
    'De zon zien opkomen', 'Een tactisch fapje', '€10 winnen op Sportbet', 'Een bierflesje op 5 verschillende manieren openen',
    -- position 12 = Free vakje (auto)
    'Iemand verliest zijn sleutels', 'Applaudisseren wanneer het vliegtuig landt', 'Roulette spelen (minimale inzet 10 euro)', 'Le Lac du Connemara inzetten',
    'Een seksspeeltje kopen', 'Ragebait iemand succesvol', 'Een adje doen met je broek op je enkels (in het openbaar)', 'Een souvenir kopen',
    'Op één dag op 4 verschillende locaties een pint drinken', 'De driesprong doen', 'Split the G', 'Een potje Brawl Stars spelen in de club'
  ];

  joran_tasks text[] := array[
    '€10 winnen op Sportbet', 'Doe de Joran Lloret-dansmoves bij de huzz', 'Iemand gaat op uitstap met een dame', 'Airport beers',
    'Een souvenir kopen', 'Blaffen naar vreemden', 'Een Irish goodbye doen', 'Een seksspeeltje kopen',
    'Een openingszin uitproberen gekozen door de groep', 'Split the G', 'Een bierflesje op 5 verschillende manieren openen', 'Een Belgisch biertje drinken in Praag',
    -- position 12 = Free vakje (auto)
    'We zijn iemand van de groep kwijt', 'Een badkamerfissa houden', 'Een stripclub bezoeken', 'Drie of meer keren fastfood eten binnen 24 uur',
    '10 toertijes tond een borstel/stok draaien tot je duizelig bent en daarna een pint adten', 'Een potje Brawl Stars spelen in de club', 'In een fontein of vijver gaan', 'Ragebait iemand succesvol',
    'Glas stelen uit een café', 'De driesprong doen', 'Een adjesestafette doen, minimaal 3 vs 3', 'Op één dag op 4 verschillende locaties een pint drinken'
  ];

  floris_tasks text[] := array[
    'Floris vindt een Fransman', 'koop een kraslotje op het vliegtuig (als ze niet verkopen: Win 10 euro op sport bed)', 'Airport beers', 'Een dance battle doen met een vreemde in de club',
    'De zon zien opkomen', 'Iemand de weg vragen en daarna bewust de andere kant uit wandelen', 'Op de toog dansen', 'Een seksspeeltje kopen',
    'Ragebait iemand succesvol', 'Een Irish goodbye doen', 'Roulette spelen (minimale inzet 10 euro)', 'Een bierflesje op 5 verschillende manieren openen',
    -- position 12 = Free vakje (auto)
    'Een stripclub bezoeken', 'Yente een compleet absurd verhaal laten geloven', '10 toertijes tond een borstel/stok draaien tot je duizelig bent en daarna een pint adten', 'Een polonaise meedoen in de club',
    'De driesprong doen', 'Een adje doen met je broek op je enkels (in het openbaar)', 'Een adjesestafette doen, minimaal 3 vs 3', 'Glas stelen uit een café',
    'We zijn iemand van de groep kwijt', 'Applaudisseren wanneer het vliegtuig landt', 'Een potje Brawl Stars spelen in de club', 'Op één dag op 4 verschillende locaties een pint drinken'
  ];

  jules_tasks text[] := array[
    'De zon zien opkomen', 'Een dance battle doen met een vreemde in de club', '10 toertijes tond een borstel/stok draaien tot je duizelig bent en daarna een pint adten', 'Airport beers',
    'Minstens 0.5m aan spullen op iemand stapelen', 'Een Belgisch biertje drinken in Praag', 'In een fontein of vijver gaan', 'Een potje Brawl Stars spelen in de club',
    'Een tactisch fapje', 'koop een kraslotje op het vliegtuig (als ze niet verkopen: Win 10 euro op sport bed)', 'Iemand gaat op uitstap met een dame', 'Een souvenir kopen',
    -- position 12 = Free vakje (auto)
    'Een polonaise meedoen in de club', 'Een badkamerfissa houden', 'Ragebait iemand succesvol', 'Simon rookt een wietje',
    'Applaudisseren wanneer het vliegtuig landt', 'YMCA aanvragen en meedoen in een club', 'Op de toog dansen', 'Le Lac du Connemara inzetten',
    'Glas stelen uit een café', 'Een bierflesje op 5 verschillende manieren openen', 'Drie of meer keren fastfood eten binnen 24 uur', 'Een potje Clash Royale winnen tegen Joran'
  ];

  levi_tasks text[] := array[
    'In een fontein of vijver gaan', 'Airport beers', 'Split the G', 'Roulette spelen (minimale inzet 10 euro)',
    'Een selfie nemen met random mensen', 'Iemand die geen Nederlands spreekt "Dekerk67" laten zeggen', 'Een challenge krijgen van een vreemde en die voltooien', 'Le Lac du Connemara inzetten',
    'Een seksspeeltje kopen', 'Ragebait iemand succesvol', 'Een adje doen met je broek op je enkels (in het openbaar)', 'Een bierflesje op 5 verschillende manieren openen',
    -- position 12 = Free vakje (auto)
    'Alcohol drinken vóór 10:00 uur', 'Applaudisseren wanneer het vliegtuig landt', 'Robbe wakker maken', 'De driesprong doen',
    '€10 winnen op Sportbet', 'Een potje Clash Royale winnen tegen Joran', 'De zon zien opkomen', 'Een Irish goodbye doen',
    'Een badkamerfissa houden', 'Een potje Brawl Stars spelen in de club', 'We zijn iemand van de groep kwijt', 'Drie of meer keren fastfood eten binnen 24 uur'
  ];

  matis_tasks text[] := array[
    'Je mama of papa bellen en zeggen dat je de liefde van je leven hebt ontmoet', 'Een openingszin uitproberen gekozen door de groep', 'Airport beers', 'Een Belgisch biertje drinken in Praag',
    '10 toertijes tond een borstel/stok draaien tot je duizelig bent en daarna een pint adten', 'Doe de Joran Lloret-dansmoves bij de huzz', 'Een DJ overtuigen om Belgische muziek te spelen', 'koop een kraslotje op het vliegtuig (als ze niet verkopen: Win 10 euro op sport bed)',
    'Een Irish goodbye doen', 'Een tactisch fapje', 'Een adje doen met je broek op je enkels (in het openbaar)', '€10 winnen op Sportbet',
    -- position 12 = Free vakje (auto)
    'Iemand verliest zijn sleutels', 'Alcohol drinken vóór 10:00 uur', 'Een stripclub bezoeken', 'Glas stelen uit een café',
    'Een seksspeeltje kopen', 'Robbe wakker maken', 'Roulette spelen (minimale inzet 10 euro)', 'Yente een compleet absurd verhaal laten geloven',
    'Breakfast beers', 'De zon zien opkomen', 'Simon rookt een wietje', 'Op één dag op 4 verschillende locaties een pint drinken'
  ];

  robbe_tasks text[] := array[
    '€10 winnen op Sportbet', 'Een DJ overtuigen om Belgische muziek te spelen', 'Airport beers', 'Deel waarborg van het  appartement verliezen',
    'Minstens 0.5m aan spullen op iemand stapelen', 'Je mama of papa bellen en zeggen dat je de liefde van je leven hebt ontmoet', 'Een badkamerfissa houden', 'Applaudisseren wanneer het vliegtuig landt',
    'Een adjesestafette doen, minimaal 3 vs 3', 'Een openingszin uitproberen gekozen door de groep', 'Iemand verliest zijn sleutels', 'Op de toog dansen',
    -- position 12 = Free vakje (auto)
    'Een souvenir kopen', 'Alcohol drinken vóór 10:00 uur', 'Breakfast beers', '10 toertijes tond een borstel/stok draaien tot je duizelig bent en daarna een pint adten',
    'Een tactisch fapje', 'Yente een compleet absurd verhaal laten geloven', 'Ragebait iemand succesvol', 'In een fontein of vijver gaan',
    'De zon zien opkomen', 'Le Lac du Connemara inzetten', 'Een potje Clash Royale winnen tegen Joran', 'Een stripclub bezoeken'
  ];

  simon_tasks text[] := array[
    'Simon rookt een wietje', 'Airport beers', '10 toertijes tond een borstel/stok draaien tot je duizelig bent en daarna een pint adten', 'Op één dag op 4 verschillende locaties een pint drinken',
    'Ragebait iemand succesvol', 'Alcohol drinken vóór 10:00 uur', 'Een tactisch fapje', 'De driesprong doen',
    'Een selfie vragen met een vreemde alsof die bekend is', 'Iemand verliest zijn gsm', 'Een polonaise meedoen in de club', 'Roulette spelen (minimale inzet 10 euro)',
    -- position 12 = Free vakje (auto)
    'Een seksspeeltje kopen', 'Aan iemand met een hond vragen of je hem mag aaien en vervolgens de eigenaar aaien', 'Een challenge krijgen van een vreemde en die voltooien', 'Een adje doen met je broek op je enkels (in het openbaar)',
    'Een Belgisch biertje drinken in Praag', 'Een souvenir kopen', 'De zon zien opkomen', 'Breakfast beers',
    'Minstens 0.5m aan spullen op iemand stapelen', '€10 winnen op Sportbet', 'Een Irish goodbye doen', 'Drie of meer keren fastfood eten binnen 24 uur'
  ];

  michiel_tasks text[] := array[
    'Airport beers', 'Iemand verliest zijn gsm', 'Een souvenir kopen', 'Een seksspeeltje kopen',
    'De zon zien opkomen', 'Een potje Clash Royale winnen tegen Joran', 'Iemand de weg vragen en daarna bewust de andere kant uit wandelen', 'Een Irish goodbye doen',
    'Een selfie vragen met een vreemde alsof die bekend is', 'Blaffen naar vreemden', 'Een stripclub bezoeken', 'Yente een compleet absurd verhaal laten geloven',
    -- position 12 = Free vakje (auto)
    'Iemand verliest zijn sleutels', 'Op één dag op 4 verschillende locaties een pint drinken', 'Minstens 0.5m aan spullen op iemand stapelen', 'Een tactisch fapje',
    'Split the G', 'Glas stelen uit een café', '€10 winnen op Sportbet', 'Robbe wakker maken',
    'De driesprong doen', '10 toertijes tond een borstel/stok draaien tot je duizelig bent en daarna een pint adten', 'Een potje Brawl Stars spelen in de club', 'Drie of meer keren fastfood eten binnen 24 uur'
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