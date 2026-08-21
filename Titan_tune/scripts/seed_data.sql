-- ============================================================
-- Titan Tunes — Seed de données réalistes
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. CATÉGORIES MUSICALES
-- ────────────────────────────────────────────────────────────
INSERT INTO categories (nom) VALUES
  ('Afrobeat'),
  ('Hip-Hop / Rap'),
  ('Gospel'),
  ('Coupé-Décalé'),
  ('Reggae'),
  ('R&B / Soul'),
  ('Pop Africaine'),
  ('Highlife'),
  ('Afro-Pop'),
  ('Musique Traditionnelle');

-- ────────────────────────────────────────────────────────────
-- 2. LABELS
-- ────────────────────────────────────────────────────────────
INSERT INTO labels (label_name) VALUES
  ('Titan Records'),
  ('Gold Coast Music'),
  ('Savane Beats'),
  ('Lomé Sound'),
  ('Africa United Records');

-- ────────────────────────────────────────────────────────────
-- 3. ADMIN
-- password BCrypt de : titansupadmin@2005
-- ────────────────────────────────────────────────────────────
INSERT INTO utilisateurs (username, email, password, telephone, role, status, email_verified, created_at, updated_at)
VALUES ('admin', 'admin@titan.com',
  '$2a$10$s3ByQVi4dJQF1X2oQWpyNuZ7VBn9w6S4yp3vGNjDk1oeqGnBh/Y4K',
  '+22890000001', 'ROLE_ADMIN', 'ACTIF', true, NOW(), NOW());
INSERT INTO admins (id, niveau_acces)
SELECT id, 'SUPER_ADMIN' FROM utilisateurs WHERE email = 'admin@titan.com';

-- ────────────────────────────────────────────────────────────
-- 4. ARTISTES
-- password BCrypt de : Artiste@2026!
-- ────────────────────────────────────────────────────────────
INSERT INTO utilisateurs (username, email, password, telephone, role, status, email_verified, created_at, updated_at) VALUES
  ('kofi_mensah',  'kofi.mensah@music.tg',   '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22891000001', 'ROLE_ARTISTE', 'ACTIF', true, NOW() - INTERVAL '2 years',   NOW()),
  ('nana_vibes',   'nana.adjoa@music.tg',    '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22891000002', 'ROLE_ARTISTE', 'ACTIF', true, NOW() - INTERVAL '18 months', NOW()),
  ('mc_togoman',   'togoman.rap@music.tg',   '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22891000003', 'ROLE_ARTISTE', 'ACTIF', true, NOW() - INTERVAL '1 year',    NOW()),
  ('grace_amavi',  'grace.amavi@music.tg',   '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22891000004', 'ROLE_ARTISTE', 'ACTIF', true, NOW() - INTERVAL '3 years',   NOW()),
  ('dj_savane',    'dj.savane@music.tg',     '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22891000005', 'ROLE_ARTISTE', 'ACTIF', true, NOW() - INTERVAL '2 years',   NOW()),
  ('ama_sossou',   'ama.sossou@music.tg',    '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22891000006', 'ROLE_ARTISTE', 'ACTIF', true, NOW() - INTERVAL '6 months',  NOW()),
  ('black_volta',  'blackvolta@music.tg',    '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22891000007', 'ROLE_ARTISTE', 'ACTIF', true, NOW() - INTERVAL '14 months', NOW()),
  ('tina_gospel',  'tina.yovo@music.tg',     '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22891000008', 'ROLE_ARTISTE', 'ACTIF', true, NOW() - INTERVAL '4 years',   NOW()),
  ('prince_ewe',   'prince.ewe@music.tg',    '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22891000009', 'ROLE_ARTISTE', 'ACTIF', true, NOW() - INTERVAL '8 months',  NOW()),
  ('soro_afro',    'soro.afroking@music.tg', '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22891000010', 'ROLE_ARTISTE', 'ACTIF', true, NOW() - INTERVAL '10 months', NOW());

INSERT INTO artistes (id, artist_name, bio, verifie)
SELECT u.id,
  CASE u.username
    WHEN 'kofi_mensah' THEN 'Kofi Mensah'   WHEN 'nana_vibes'  THEN 'Nana Vibes'
    WHEN 'mc_togoman'  THEN 'MC TogoMan'    WHEN 'grace_amavi' THEN 'Grace Amavi'
    WHEN 'dj_savane'   THEN 'DJ Savane'     WHEN 'ama_sossou'  THEN 'Ama Sossou'
    WHEN 'black_volta' THEN 'Black Volta'   WHEN 'tina_gospel' THEN 'Tina Yovo'
    WHEN 'prince_ewe'  THEN 'Prince Ewé'   WHEN 'soro_afro'   THEN 'Soro Afro King'
  END,
  CASE u.username
    WHEN 'kofi_mensah' THEN 'Artiste afrobeat de Lomé, fusionnant rythmes éwé et sons modernes depuis 2018.'
    WHEN 'nana_vibes'  THEN 'Chanteuse R&B / Soul de Kara. Voix de velours, textes engagés sur la condition féminine africaine.'
    WHEN 'mc_togoman'  THEN 'Rappeur freestyle de Tsévié, punchlines percutantes en français, mina et éwé. Champion du battle rap.'
    WHEN 'grace_amavi' THEN 'Chanteuse gospel de Lomé. Sa voix puissante rassemble des milliers de fidèles à travers le pays.'
    WHEN 'dj_savane'   THEN 'DJ producteur spécialisé coupé-décalé et afro house. Plus de 50 collaborations africaines.'
    WHEN 'ama_sossou'  THEN 'Jeune talent afro-pop togolaise, découverte lors de Togo Idol saison 3.'
    WHEN 'black_volta' THEN 'Groupe highlife ghanéen-togolais, guitares acoustiques et percussions traditionnelles.'
    WHEN 'tina_gospel' THEN 'Icône du gospel togolais depuis 15 ans. Lauréate meilleure artiste gospel Afrique de l''Ouest 2023.'
    WHEN 'prince_ewe'  THEN 'Chanteur musique traditionnelle éwé modernisée. Préserve l''héritage culturel du peuple éwé.'
    WHEN 'soro_afro'   THEN 'Roi de l''afrobeat burkinabè installé à Lomé. Rythmes chaleureux résonnant dans toute la sous-région.'
  END,
  u.username IN ('kofi_mensah','nana_vibes','grace_amavi','dj_savane','black_volta','tina_gospel','soro_afro')
FROM utilisateurs u WHERE u.role = 'ROLE_ARTISTE';

-- ────────────────────────────────────────────────────────────
-- 5. AUDITEURS (15 profils)
-- password BCrypt de : Auditeur@2026!
-- ────────────────────────────────────────────────────────────
INSERT INTO utilisateurs (username, email, password, telephone, role, status, email_verified, created_at, updated_at) VALUES
  ('amina_k',     'amina.koffi@gmail.com',      '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000001', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '1 year',    NOW()),
  ('yao_mensah',  'yao.mensah@yahoo.fr',         '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000002', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '8 months',  NOW()),
  ('esi_adjoa',   'esi.adjoa@outlook.com',        '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000003', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '6 months',  NOW()),
  ('kwame_d',     'kwame.dossou@gmail.com',       '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000004', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '14 months', NOW()),
  ('akua_b',      'akua.boko@gmail.com',          '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000005', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '3 months',  NOW()),
  ('tobi_fiagan', 'tobi.fiagan@gmail.com',        '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000006', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '9 months',  NOW()),
  ('diana_k',     'diana.klutse@yahoo.fr',        '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000007', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '5 months',  NOW()),
  ('felix_agu',   'felix.agudze@gmail.com',       '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000008', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '2 years',   NOW()),
  ('mariam_t',    'mariam.tchassou@gmail.com',    '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000009', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '4 months',  NOW()),
  ('serge_a',     'serge.amevor@hotmail.com',     '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000010', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '11 months', NOW()),
  ('beatrice_n',  'beatrice.nunyonu@gmail.com',   '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000011', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '7 months',  NOW()),
  ('kodjo_h',     'kodjo.hatchinou@gmail.com',    '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000012', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '16 months', NOW()),
  ('afiwa_d',     'afiwa.djiwa@gmail.com',        '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000013', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '2 months',  NOW()),
  ('mawuli_s',    'mawuli.segla@gmail.com',       '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000014', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '1 month',   NOW()),
  ('pascaline_a', 'pascaline.agbo@gmail.com',     '$2a$10$rB8pZ1Xm5kLn2vQ3dYhWaOJWVeMfK7TuHg9sNzR4pC6iBxAoDE1sa', '+22892000015', 'ROLE_AUDITEUR', 'ACTIF', true, NOW() - INTERVAL '20 months', NOW());

INSERT INTO auditeurs (id, abonnement_actif)
SELECT u.id,
  u.username IN ('amina_k','yao_mensah','kwame_d','tobi_fiagan','diana_k','felix_agu','serge_a','kodjo_h','pascaline_a')
FROM utilisateurs u WHERE u.role = 'ROLE_AUDITEUR';

-- ────────────────────────────────────────────────────────────
-- 6. ALBUMS (12 albums)
-- ────────────────────────────────────────────────────────────
INSERT INTO albums (title, date_sortie, cover_image, artiste_id)
SELECT t.titre, t.date_s, t.cover, u.id
FROM (VALUES
  ('Racines du Golfe',       '2023-03-15'::date, 'racines_golfe.jpg',      'kofi_mensah'),
  ('Nuit de Lomé',           '2024-08-01'::date, 'nuit_lome.jpg',          'kofi_mensah'),
  ('Femme du Sahel',         '2023-07-20'::date, 'femme_sahel.jpg',        'nana_vibes'),
  ('Amour et Liberté',       '2025-02-14'::date, 'amour_liberte.jpg',      'nana_vibes'),
  ('Street Togolais Vol.1',  '2022-11-05'::date, 'street_tg1.jpg',         'mc_togoman'),
  ('Freestyle Mina',         '2024-04-01'::date, 'freestyle_mina.jpg',     'mc_togoman'),
  ('Lumiere Afrique',        '2023-01-06'::date, 'lumiere_afrique.jpg',    'grace_amavi'),
  ('Gloire Eternelle',       '2025-04-12'::date, 'gloire_eternelle.jpg',   'grace_amavi'),
  ('Savane Sessions',        '2023-06-01'::date, 'savane_sessions.jpg',    'dj_savane'),
  ('Afro House Togo',        '2024-10-18'::date, 'afro_house_togo.jpg',    'dj_savane'),
  ('Premier Envol',          '2024-09-01'::date, 'premier_envol.jpg',      'ama_sossou'),
  ('Heritage Volta',         '2023-11-15'::date, 'heritage_volta.jpg',     'black_volta')
) AS t(titre, date_s, cover, uname)
JOIN utilisateurs u ON u.username = t.uname;

-- ────────────────────────────────────────────────────────────
-- 7. CHANSONS (40 titres)
-- ────────────────────────────────────────────────────────────
INSERT INTO chansons (titre, duree, parole, audio_url, nb_ecoutes, add_date, artiste_id, album_id, categorie_id)
SELECT c.titre, c.duree, c.parole, c.audio_url, c.nb_ecoutes,
  NOW() - (RANDOM() * INTERVAL '24 months'),
  u.id, al.id, cat.id
FROM (VALUES
  ('Lomé la Nuit',          214, 'Lomé tu brilles sous les étoiles, tes rues racontent mille histoires',                        'kofi_lome_la_nuit.mp3',    12840, 'kofi_mensah', 'Racines du Golfe',      'Afrobeat'),
  ('Ewe Groove',            198, 'Mon sang pulse au rythme du tam-tam, Ewé dans âme Africa dans le coeur',                      'kofi_ewe_groove.mp3',       9320, 'kofi_mensah', 'Racines du Golfe',      'Afrobeat'),
  ('Plage de Cococodji',    243, 'Les vagues caressent le sable blanc, le soleil se couche sur ocean',                          'kofi_plage_coco.mp3',      18670, 'kofi_mensah', NULL,                    'Afrobeat'),
  ('Tam-Tam Moderne',       187, 'Le vieux tam-tam rencontre la basse, la tradition danse avec le présent',                     'kofi_tamtam.mp3',           6540, 'kofi_mensah', 'Racines du Golfe',      'Afrobeat'),
  ('Volta Sunrise',         256, 'A aube le fleuve chante, porte nos reves jusqu a la mer',                                     'kofi_volta_sunrise.mp3',   14320, 'kofi_mensah', 'Nuit de Lomé',          'Afrobeat'),
  ('Gbagbe Oo',             221, 'Oublie les soucis ce soir, danse et profite de la vie',                                       'kofi_gbagbe.mp3',          23450, 'kofi_mensah', 'Nuit de Lomé',          'Afrobeat'),
  ('Femme Libre',           267, 'Je suis femme libre et fiere, mon destin cest moi qui lecris',                                'nana_femme_libre.mp3',     28920, 'nana_vibes',  'Femme du Sahel',        'R&B / Soul'),
  ('Mon Coeur Kara',        231, 'Kara tu es dans mon coeur, tes montagnes me rappellent chez moi',                             'nana_coeur_kara.mp3',      16430, 'nana_vibes',  'Femme du Sahel',        'R&B / Soul'),
  ('Danse avec Moi',        204, 'Prends ma main laisse-toi aller, la nuit nous appartient',                                    'nana_danse.mp3',           11870, 'nana_vibes',  NULL,                    'Pop Africaine'),
  ('Aimer Fort',            289, 'Aimer cest risquer sa liberté, mais sans amour la vie na plus de sens',                       'nana_aimer_fort.mp3',      19650, 'nana_vibes',  'Amour et Liberté',      'R&B / Soul'),
  ('Brise de Nuit',         198, 'La brise de nuit porte tes mots, je tentends meme dans le silence',                          'nana_brise_nuit.mp3',       8340, 'nana_vibes',  'Amour et Liberté',      'R&B / Soul'),
  ('Rue de Tsevie',         189, 'Je suis né dans la poussiere, jai grandi entre les rires et les larmes',                     'mc_rue_tsevie.mp3',         7830, 'mc_togoman',  'Street Togolais Vol.1', 'Hip-Hop / Rap'),
  ('Flow Mina',             213, 'Mon flow coule comme la riviere Mina, personne ne peut stopper ma maree',                    'mc_flow_mina.mp3',          5940, 'mc_togoman',  'Street Togolais Vol.1', 'Hip-Hop / Rap'),
  ('Verite Togolaise',      237, 'Je dis ce que les autres pensent tout bas, la vérité ne se cache pas',                       'mc_verite_togo.mp3',       13280, 'mc_togoman',  NULL,                    'Hip-Hop / Rap'),
  ('Freestyle Lome',        201, 'Micro en main je prends le micro, Lomé tremble sous mes rimes de feu',                       'mc_freestyle_lome.mp3',     9160, 'mc_togoman',  'Freestyle Mina',        'Hip-Hop / Rap'),
  ('Encore Debout',         245, 'On ma dit que je ne pouvais pas, me voila encore debout plus fort',                          'mc_encore_debout.mp3',     17890, 'mc_togoman',  'Freestyle Mina',        'Hip-Hop / Rap'),
  ('Grace et Gloire',       298, 'Ta grâce me porte chaque matin, ta gloire illumine mon chemin',                              'grace_grace_gloire.mp3',   32650, 'grace_amavi', 'Lumiere Afrique',       'Gospel'),
  ('Espoir Infini',         315, 'Dans les ténèbres tu es ma lumière, ton espoir infini brise chaque barrière',                'grace_espoir.mp3',         21480, 'grace_amavi', 'Lumiere Afrique',       'Gospel'),
  ('Alleluia Lome',         281, 'Lomé chante alleluia, la ville entière se lève pour louer',                                  'grace_alleluia.mp3',       43220, 'grace_amavi', NULL,                    'Gospel'),
  ('Portee par ta Main',    324, 'Quand mes forces m''abandonnent, tu me portes sur tes ailes',                                'grace_portee_main.mp3',    18760, 'grace_amavi', 'Gloire Eternelle',      'Gospel'),
  ('Miracle de Kara',       267, 'A Kara jai vu ton miracle, un enfant guéri ta parole accomplie',                             'grace_miracle_kara.mp3',   14390, 'grace_amavi', 'Gloire Eternelle',      'Gospel'),
  ('Decale Savane',         195, NULL,                                                                                          'dj_decale_savane.mp3',     47800, 'dj_savane',   'Savane Sessions',       'Coupé-Décalé'),
  ('Afro House Mix',        382, NULL,                                                                                          'dj_afro_house.mp3',        31240, 'dj_savane',   'Savane Sessions',       'Coupé-Décalé'),
  ('Nuit Abidjan',          278, NULL,                                                                                          'dj_nuit_abidjan.mp3',      22670, 'dj_savane',   NULL,                    'Coupé-Décalé'),
  ('Lagos to Lome',         341, NULL,                                                                                          'dj_lagos_lome.mp3',        38950, 'dj_savane',   'Afro House Togo',       'Afrobeat'),
  ('Percussion Ewe',        290, NULL,                                                                                          'dj_percussion_ewe.mp3',    19430, 'dj_savane',   'Afro House Togo',       'Coupé-Décalé'),
  ('Nouveau Matin',         198, 'Chaque matin est une nouvelle chance de danser au rythme de la vie',                         'ama_nouveau_matin.mp3',    15670, 'ama_sossou',  'Premier Envol',         'Pop Africaine'),
  ('Reve Grand',            221, 'Rêve grand jeune Togolaise, ton avenir est plus beau que horizon',                           'ama_reve_grand.mp3',       22840, 'ama_sossou',  'Premier Envol',         'Pop Africaine'),
  ('Sweet Lome',            187, 'Sweet Lomé ma ville dorée, tu es la perle de Afrique de Ouest',                              'ama_sweet_lome.mp3',       31290, 'ama_sossou',  NULL,                    'Pop Africaine'),
  ('Volta Flow',            276, 'Le fleuve Volta nous unit, Ghana Togo un seul peuple un seul coeur',                        'bv_volta_flow.mp3',        11230, 'black_volta', 'Heritage Volta',        'Highlife'),
  ('Harmonie Frontiere',    312, 'Nos cultures se melent et dansent, a la frontiere la vie est belle',                         'bv_harmonie.mp3',           8760, 'black_volta', 'Heritage Volta',        'Highlife'),
  ('Puissance Divine',      334, 'Ta puissance est au-dela de tout, Seigneur tu règnes sur univers',                          'tina_puissance.mp3',       29870, 'tina_gospel', NULL,                    'Gospel'),
  ('Chant des Anges',       298, 'J''entends le chant des anges qui monte vers le trône de grâce',                            'tina_anges.mp3',           18450, 'tina_gospel', NULL,                    'Gospel'),
  ('Agbadza Royal',         298, 'L agbadza résonne dans la savane, les ancêtres dansent avec nous',                          'prince_agbadza.mp3',        7840, 'prince_ewe',  NULL,                    'Musique Traditionnelle'),
  ('Kpanlogo Lome',         245, 'Le kpanlogo unit les générations, hier et aujourd hui main dans la main',                   'prince_kpanlogo.mp3',       5620, 'prince_ewe',  NULL,                    'Musique Traditionnelle'),
  ('Burkina Soro',          213, 'Du Burkina je porte les couleurs, au Togo je partage mes chaleurs',                         'soro_burkina.mp3',         16780, 'soro_afro',   NULL,                    'Afro-Pop'),
  ('Africa Rise',           256, 'Africa rise together we stand, notre continent uni jusqu au bout',                          'soro_africa_rise.mp3',     24560, 'soro_afro',   NULL,                    'Afro-Pop'),
  ('Sahel Blues',           289, 'Le Sahel pleure mais résiste, la terre aride garde son âme artiste',                        'soro_sahel_blues.mp3',     12340, 'soro_afro',   NULL,                    'Afrobeat'),
  ('Ouaga Nuit',            231, 'Ouaga la nuit s éveille enfin, les djembés parlent jusqu au matin',                         'soro_ouaga_nuit.mp3',       9870, 'soro_afro',   NULL,                    'Afro-Pop'),
  ('Lomé Soleil',           203, 'Lomé dore sous le soleil d harmattan, ses plages chantent jusqu au lendemain',              'kofi_lome_soleil.mp3',     34100, 'kofi_mensah', NULL,                    'Afrobeat')
) AS c(titre, duree, parole, audio_url, nb_ecoutes, uname, album_titre, cat_nom)
JOIN utilisateurs u ON u.username = c.uname
LEFT JOIN albums al ON al.title = c.album_titre AND al.artiste_id = u.id
JOIN categories cat ON cat.nom = c.cat_nom;

-- ────────────────────────────────────────────────────────────
-- 8. ABONNEMENTS
-- ────────────────────────────────────────────────────────────
INSERT INTO abonnements (offer_code, mobile_money_ref, start_date, end_date, active, auditeur_id)
SELECT t.offer, t.ref, t.start_d, t.end_d, t.actif, u.id
FROM (VALUES
  ('MONTHLY', 'FLOOZ-001', NOW()-INTERVAL '15 days', NOW()+INTERVAL '15 days',  true,  'amina_k'),
  ('YEARLY',  'TMONY-002', NOW()-INTERVAL '2 months',NOW()+INTERVAL '10 months',true,  'yao_mensah'),
  ('WEEKLY',  'WAVE-003',  NOW()-INTERVAL '3 days',  NOW()+INTERVAL '4 days',   true,  'kwame_d'),
  ('MONTHLY', 'FLOOZ-004', NOW()-INTERVAL '5 days',  NOW()+INTERVAL '25 days',  true,  'tobi_fiagan'),
  ('YEARLY',  'TMONY-005', NOW()-INTERVAL '6 months',NOW()+INTERVAL '6 months', true,  'diana_k'),
  ('MONTHLY', 'FLOOZ-006', NOW()-INTERVAL '20 days', NOW()+INTERVAL '10 days',  true,  'felix_agu'),
  ('WEEKLY',  'WAVE-007',  NOW()-INTERVAL '8 days',  NOW()-INTERVAL '1 day',    false, 'esi_adjoa'),
  ('MONTHLY', 'TMONY-008', NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 day',    true,  'serge_a'),
  ('YEARLY',  'FLOOZ-009', NOW()-INTERVAL '3 months',NOW()+INTERVAL '9 months', true,  'kodjo_h'),
  ('MONTHLY', 'WAVE-010',  NOW()-INTERVAL '7 months',NOW()-INTERVAL '6 months', false, 'beatrice_n'),
  ('MONTHLY', 'TMONY-011', NOW()-INTERVAL '2 days',  NOW()+INTERVAL '28 days',  true,  'pascaline_a')
) AS t(offer, ref, start_d, end_d, actif, uname)
JOIN utilisateurs u ON u.username = t.uname;

-- ────────────────────────────────────────────────────────────
-- 9. PAIEMENTS
-- ────────────────────────────────────────────────────────────
INSERT INTO paiements (montant, mode_paiement, statut, auditeur_id, abonnement_id)
SELECT
  CASE ab.offer_code WHEN 'WEEKLY' THEN 500.0 WHEN 'MONTHLY' THEN 2000.0 ELSE 18000.0 END,
  CASE u.username
    WHEN 'amina_k' THEN 'FLOOZ' WHEN 'yao_mensah' THEN 'TMONEY' WHEN 'kwame_d' THEN 'WAVE'
    WHEN 'tobi_fiagan' THEN 'FLOOZ' WHEN 'diana_k' THEN 'TMONEY' WHEN 'felix_agu' THEN 'FLOOZ'
    WHEN 'esi_adjoa' THEN 'WAVE' WHEN 'serge_a' THEN 'TMONEY' WHEN 'kodjo_h' THEN 'FLOOZ'
    WHEN 'beatrice_n' THEN 'WAVE' ELSE 'TMONEY'
  END,
  'SUCCES', ab.auditeur_id, ab.id
FROM abonnements ab
JOIN utilisateurs u ON u.id = ab.auditeur_id;

-- ────────────────────────────────────────────────────────────
-- 10. ÉCOUTES (historique)
-- ────────────────────────────────────────────────────────────
INSERT INTO ecoutes (duree_ecoute, listened_at, chanson_id, auditeur_id)
SELECT
  GREATEST(30, c.duree - (RANDOM() * 60)::int),
  NOW() - (RANDOM() * INTERVAL '90 days'),
  c.id, u.id
FROM chansons c
CROSS JOIN (SELECT id FROM utilisateurs WHERE role = 'ROLE_AUDITEUR') u
WHERE RANDOM() > 0.55;

-- ────────────────────────────────────────────────────────────
-- 11. PLAYLISTS
-- ────────────────────────────────────────────────────────────
INSERT INTO playlists (title, description, privee, auditeur_id)
SELECT t.titre, t.descr, t.priv, u.id
FROM (VALUES
  ('Mes Afrobeats Preferes', 'Les meilleurs sons afro du moment',     false, 'amina_k'),
  ('Gospel du Matin',        'Pour commencer la journée avec foi',    false, 'amina_k'),
  ('Rap Togo Best Of',       'Le meilleur du rap togolais',           true,  'yao_mensah'),
  ('Soiree Coupe-Decale',    'Pour faire danser tout le monde',       false, 'kwame_d'),
  ('Voyage Musical',         'De Lomé à Lagos en musique',            false, 'felix_agu'),
  ('Soul R&B Vibes',         'Pour les belles soirées romantiques',   true,  'diana_k'),
  ('Musique de Travail',     'Focus et productivité garantis',        false, 'tobi_fiagan'),
  ('Hits du Moment',         'Top des écoutes de la semaine',         false, 'serge_a')
) AS t(titre, descr, priv, uname)
JOIN utilisateurs u ON u.username = t.uname;

INSERT INTO playlist_chansons (playlist_id, chanson_id)
SELECT pl.id, ch.id FROM playlists pl
CROSS JOIN chansons ch
WHERE
  (pl.title = 'Mes Afrobeats Preferes' AND ch.categorie_id = (SELECT id FROM categories WHERE nom = 'Afrobeat')        AND RANDOM() > 0.5)
  OR (pl.title = 'Gospel du Matin'     AND ch.categorie_id = (SELECT id FROM categories WHERE nom = 'Gospel')          AND RANDOM() > 0.4)
  OR (pl.title = 'Rap Togo Best Of'    AND ch.categorie_id = (SELECT id FROM categories WHERE nom = 'Hip-Hop / Rap')   AND RANDOM() > 0.3)
  OR (pl.title = 'Soiree Coupe-Decale' AND ch.categorie_id = (SELECT id FROM categories WHERE nom = 'Coupé-Décalé')   AND RANDOM() > 0.3)
  OR (pl.title = 'Hits du Moment'      AND ch.nb_ecoutes > 15000                                                       AND RANDOM() > 0.4);

-- ────────────────────────────────────────────────────────────
-- 12. ÉVÉNEMENTS
-- ────────────────────────────────────────────────────────────
INSERT INTO evenements (name_concert, date_evenement, date_limite, lieu, prix_ticket, artiste_id)
SELECT t.nom, t.date_ev, t.date_lim, t.lieu_ev, t.prix, u.id
FROM (VALUES
  ('Afrobeat Night Palais des Congres', NOW()+INTERVAL '5 weeks',  NOW()+INTERVAL '4 weeks 5 days', 'Palais des Congrès de Lomé',      5000.0, 'kofi_mensah'),
  ('Nana Vibes Live Kara',              NOW()+INTERVAL '2 months', NOW()+INTERVAL '7 weeks',         'Centre Culturel de Kara',         3000.0, 'nana_vibes'),
  ('Gospel en Fete Cathedrale',         NOW()+INTERVAL '3 weeks',  NOW()+INTERVAL '2 weeks 6 days',  'Cathedrale Sacre-Coeur de Lomé',  1000.0, 'grace_amavi'),
  ('DJ Savane Pool Party',              NOW()+INTERVAL '6 weeks',  NOW()+INTERVAL '5 weeks 6 days',  'Hotel Palm Beach Lomé',           7500.0, 'dj_savane'),
  ('MC TogoMan Battle Freestyle',       NOW()+INTERVAL '10 days',  NOW()+INTERVAL '9 days',          'Bar Le Karate Tsevie',            1500.0, 'mc_togoman'),
  ('Ama Sossou Premier Grand Concert',  NOW()+INTERVAL '8 weeks',  NOW()+INTERVAL '7 weeks',         'Institut Francais de Lomé',       2500.0, 'ama_sossou'),
  ('Tina Yovo Nuit de Louange',         NOW()+INTERVAL '4 weeks',  NOW()+INTERVAL '3 weeks 6 days',  'Assemblee de Dieu Lomé',           500.0, 'tina_gospel'),
  ('Soro Afro King Festival',           NOW()+INTERVAL '12 weeks', NOW()+INTERVAL '11 weeks',        'Stade Municipal de Lomé',         4000.0, 'soro_afro'),
  ('Kofi Mensah Retour Aux Sources',    NOW()-INTERVAL '2 months', NOW()-INTERVAL '2 months 2 days', 'Brasserie du Benin Lomé',         3000.0, 'kofi_mensah'),
  ('Gospel United Africa',              NOW()-INTERVAL '1 month',  NOW()-INTERVAL '1 month 2 days',  'Palais des Congrès de Lomé',      2000.0, 'grace_amavi')
) AS t(nom, date_ev, date_lim, lieu_ev, prix, uname)
JOIN utilisateurs u ON u.username = t.uname;

-- ────────────────────────────────────────────────────────────
-- 13. NOTIFICATIONS
-- ────────────────────────────────────────────────────────────
INSERT INTO notifications (titre, message, date_envoie, lu, auditeur_id)
SELECT n.titre, n.msg, NOW()-n.delta, n.lu, u.id
FROM (VALUES
  ('Bienvenue sur Titan Tunes',     'Decouvrez des centaines artistes togolais et africains. Bonne ecoute !',           INTERVAL '5 hours',  false, 'amina_k'),
  ('Nouveau single Gbagbe Oo',      'Kofi Mensah vient de sortir Gbagbe Oo. Cest deja le hit de la semaine !',         INTERVAL '2 days',   true,  'amina_k'),
  ('Abonnement actif',              'Profitez de ecoute illimitee sans publicite pendant 30 jours.',                    INTERVAL '15 days',  true,  'amina_k'),
  ('Concert Afrobeat Night',        'Kofi Mensah en live au Palais des Congres dans 5 semaines. Reservez vite !',       INTERVAL '1 day',    false, 'yao_mensah'),
  ('Abonnement annuel active',      'Merci pour votre fidelite ! Votre abonnement annuel est maintenant actif.',        INTERVAL '2 months', true,  'yao_mensah'),
  ('Nana Vibes Nouvel Album',       'Amour et Liberte est disponible ! 11 titres soul pour toucher votre coeur.',       INTERVAL '3 days',   false, 'kwame_d'),
  ('Abonnement expire',             'Votre abonnement a expire. Renouvelez pour continuer sans interruption.',          INTERVAL '1 day',    false, 'esi_adjoa'),
  ('DJ Savane Pool Party',          'Le DJ set de ete approche ! Reservez votre ticket maintenant.',                    INTERVAL '12 hours', false, 'kwame_d'),
  ('Alleluia Lome 40000 ecoutes',   'La chanson de Grace Amavi est un phenomene. Lavez-vous ecoutee ?',                 INTERVAL '4 days',   true,  'felix_agu'),
  ('Tendances Sweet Lome',          'Sweet Lome de Ama Sossou grimpe dans les charts. A decouvrir !',                  INTERVAL '6 hours',  false, 'felix_agu'),
  ('Bienvenue',                     'Creez vos playlists, suivez vos artistes preferes, explorez la musique togolaise', INTERVAL '20 days',  true,  'diana_k'),
  ('Gospel en Fete dimanche',       'Tina Yovo et Grace Amavi reunis pour une nuit de louange inoubliable.',            INTERVAL '2 days',   false, 'beatrice_n'),
  ('MC TogoMan Freestyle Battle',   'Battle dans 10 jours a Tsevie. Entree 1500 FCFA. Venez nombreux !',               INTERVAL '3 hours',  false, 'serge_a'),
  ('Playlist recommandee',          'Basee sur vos ecoutes nous avons prepare Hits du Moment pour vous.',               INTERVAL '1 week',   true,  'kodjo_h'),
  ('Merci pour votre fidelite',     'Vous etes avec Titan Tunes depuis plus d un an. Merci !',                          INTERVAL '20 days',  true,  'pascaline_a')
) AS n(titre, msg, delta, lu, uname)
JOIN utilisateurs u ON u.username = n.uname;

-- ────────────────────────────────────────────────────────────
-- 14. FAVORIS (chansons)
-- ────────────────────────────────────────────────────────────
INSERT INTO favoris (date_ajout, utilisateur_id)
SELECT NOW() - (RANDOM() * INTERVAL '6 months'), u.id
FROM utilisateurs u
WHERE u.role = 'ROLE_AUDITEUR'
CROSS JOIN generate_series(1,3);

INSERT INTO favoris_chanson (id_fav, chanson_id)
SELECT f.id_fav, c.id
FROM (
  SELECT id_fav, ROW_NUMBER() OVER (ORDER BY id_fav) rn FROM favoris
) f
JOIN (
  SELECT id, ROW_NUMBER() OVER (ORDER BY nb_ecoutes DESC) rn FROM chansons
) c ON c.rn = ((f.rn - 1) % 10) + 1
ON CONFLICT DO NOTHING;

-- ────────────────────────────────────────────────────────────
-- RÉSUMÉ FINAL
-- ────────────────────────────────────────────────────────────
SELECT
  (SELECT COUNT(*) FROM utilisateurs)  AS utilisateurs,
  (SELECT COUNT(*) FROM artistes)      AS artistes,
  (SELECT COUNT(*) FROM auditeurs)     AS auditeurs,
  (SELECT COUNT(*) FROM admins)        AS admins,
  (SELECT COUNT(*) FROM chansons)      AS chansons,
  (SELECT COUNT(*) FROM albums)        AS albums,
  (SELECT COUNT(*) FROM categories)    AS categories,
  (SELECT COUNT(*) FROM abonnements)   AS abonnements,
  (SELECT COUNT(*) FROM paiements)     AS paiements,
  (SELECT COUNT(*) FROM evenements)    AS evenements,
  (SELECT COUNT(*) FROM playlists)     AS playlists,
  (SELECT COUNT(*) FROM ecoutes)       AS ecoutes,
  (SELECT COUNT(*) FROM notifications) AS notifications,
  (SELECT COUNT(*) FROM favoris)       AS favoris;
