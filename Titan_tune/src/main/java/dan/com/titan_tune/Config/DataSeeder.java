// package dan.com.titan_tune.config;

// import dan.com.titan_tune.entities.*;
// import dan.com.titan_tune.enums.ModePaiement;
// import dan.com.titan_tune.enums.Role;
// import dan.com.titan_tune.enums.Statut;
// import dan.com.titan_tune.repository.*;
// import lombok.RequiredArgsConstructor;
// import lombok.extern.slf4j.Slf4j;
// import org.springframework.boot.CommandLineRunner;
// import org.springframework.context.annotation.Bean;
// import org.springframework.context.annotation.Configuration;
// import org.springframework.security.crypto.password.PasswordEncoder;
// import org.springframework.transaction.annotation.Transactional;

// import java.time.LocalDate;
// import java.time.LocalDateTime;
// import java.util.List;

// /**
//  * Peuple la base de données avec des données fictives cohérentes au démarrage.
//  * Idempotent : ne crée rien si les données existent déjà (vérifie via existsByRole/count).
//  */
// @Slf4j
// @Configuration
// @RequiredArgsConstructor
// public class DataSeeder {

//     @Bean
//     @Transactional
//     public CommandLineRunner seed(
//             UtilisateurRepository utilisateurRepository,
//             ArtisteRepository     artisteRepository,
//             AuditeurRepository    auditeurRepository,
//             CategorieRepository   categorieRepository,
//             LabelRepository       labelRepository,
//             ChansonRepository     chansonRepository,
//             AlbumRepository       albumRepository,
//             AbonnementRepository  abonnementRepository,
//             PaiementRepository    paiementRepository,
//             NotificationRepository notificationRepository,
//             EvenementRepository   evenementRepository,
//             PasswordEncoder       passwordEncoder
//     ) {
//         return args -> {

//             // ── Admin : toujours créé/mis à jour indépendamment du reste ─────
//             // ── Admins : toujours créés/mis à jour indépendamment du reste ───
//             if (utilisateurRepository.findByEmail("admin@titan-tune.com").isEmpty()) {
//                 var admin1 = Admin.builder()
//                         .username("admin_titantune")
//                         .email("admin@titan-tune.com")
//                         .password(passwordEncoder.encode("Admin@2026!"))
//                         .telephone("+22890000000")
//                         .role(Role.ROLE_ADMIN)
//                         .status(Statut.ACTIF)
//                         .emailVerified(true)
//                         .niveauAcces("SUPER_ADMIN")
//                         .build();
//                 utilisateurRepository.save(admin1);
//                 log.info("  ✔ Admin créé : admin@titan-tune.com / Admin@2026!");
//             }

//             if (utilisateurRepository.findByEmail("admin@titan.com").isEmpty()) {
//                 var admin2 = Admin.builder()
//                         .username("admin")
//                         .email("admin@titan.com")
//                         .password(passwordEncoder.encode("titansupadmin@2005"))
//                         .telephone("+22890000001")
//                         .role(Role.ROLE_ADMIN)
//                         .status(Statut.ACTIF)
//                         .emailVerified(true)
//                         .niveauAcces("SUPER_ADMIN")
//                         .build();
//                 utilisateurRepository.save(admin2);
//                 log.info("  ✔ Admin créé : admin@titan.com / titansupadmin@2005");
//             }

//             // ── Guard : ne pas re-créer les données fictives si elles existent ─
//             // On compte sans l'admin (1 seul en base = juste l'admin = base vide)
//             if (utilisateurRepository.count() > 1) {
//                 log.info("DataSeeder : données fictives déjà présentes, seed ignoré.");
//                 return;
//             }

//             log.info("DataSeeder : initialisation des données fictives...");

//             // ─────────────────────────────────────────────────────────────────
//             // 2. CATÉGORIES musicales
//             // ─────────────────────────────────────────────────────────────────
//             var categories = categorieRepository.saveAll(List.of(
//                     Categorie.builder().nom("Afrobeat").build(),
//                     Categorie.builder().nom("Hip-Hop / Rap").build(),
//                     Categorie.builder().nom("Gospel").build(),
//                     Categorie.builder().nom("Coupé-Décalé").build(),
//                     Categorie.builder().nom("Reggae").build(),
//                     Categorie.builder().nom("R&B / Soul").build(),
//                     Categorie.builder().nom("Pop Africaine").build()
//             ));
//             var catAfrobeat   = categories.get(0);
//             var catRap        = categories.get(1);
//             var catGospel     = categories.get(2);
//             var catCoupeDecale = categories.get(3);
//             var catReggae     = categories.get(4);
//             var catRnb        = categories.get(5);
//             var catPop        = categories.get(6);
//             log.info("  ✔ {} catégories créées.", categories.size());

//             // ─────────────────────────────────────────────────────────────────
//             // 3. LABELS
//             // ─────────────────────────────────────────────────────────────────
//             var labels = labelRepository.saveAll(List.of(
//                     Label.builder().labelName("Titan Records").build(),
//                     Label.builder().labelName("Gold Coast Music").build(),
//                     Label.builder().labelName("Savane Beats").build()
//             ));
//             log.info("  ✔ {} labels créés.", labels.size());

//             // ─────────────────────────────────────────────────────────────────
//             // 4. ARTISTES (5 artistes togolais fictifs)
//             // ─────────────────────────────────────────────────────────────────
//             var artiste1 = (Artiste) utilisateurRepository.save(
//                 Artiste.builder()
//                     .username("kofi_beats")
//                     .email("kofi.mensah@music.tg")
//                     .password(passwordEncoder.encode("Artiste@2026!"))
//                     .telephone("+22891000001")
//                     .role(Role.ROLE_ARTISTE)
//                     .status(Statut.ACTIF)
//                     .emailVerified(true)
//                     .artistName("Kofi Mensah")
//                     .bio("Artiste afrobeat de Lomé, fusionnant rythmes traditionnels éwé et sons modernes depuis 2018.")
//                     .verifie(true)
//                     .build());

//             var artiste2 = (Artiste) utilisateurRepository.save(
//                 Artiste.builder()
//                     .username("nana_vibes")
//                     .email("nana.adjoa@music.tg")
//                     .password(passwordEncoder.encode("Artiste@2026!"))
//                     .telephone("+22891000002")
//                     .role(Role.ROLE_ARTISTE)
//                     .status(Statut.ACTIF)
//                     .emailVerified(true)
//                     .artistName("Nana Vibes")
//                     .bio("Chanteuse R&B / Soul de Kara, voix de velours et textes engagés sur la condition féminine.")
//                     .verifie(true)
//                     .build());

//             var artiste3 = (Artiste) utilisateurRepository.save(
//                 Artiste.builder()
//                     .username("mc_togoman")
//                     .email("togoman.rap@music.tg")
//                     .password(passwordEncoder.encode("Artiste@2026!"))
//                     .telephone("+22891000003")
//                     .role(Role.ROLE_ARTISTE)
//                     .status(Statut.ACTIF)
//                     .emailVerified(true)
//                     .artistName("MC TogoMan")
//                     .bio("Rappeur freestyle de Tsévié, connu pour ses punchlines en français, mina et éwé.")
//                     .verifie(false)
//                     .build());

//             var artiste4 = (Artiste) utilisateurRepository.save(
//                 Artiste.builder()
//                     .username("grace_gospel")
//                     .email("grace.amavi@music.tg")
//                     .password(passwordEncoder.encode("Artiste@2026!"))
//                     .telephone("+22891000004")
//                     .role(Role.ROLE_ARTISTE)
//                     .status(Statut.ACTIF)
//                     .emailVerified(true)
//                     .artistName("Grace Amavi")
//                     .bio("Chanteuse gospel qui illumine les scènes de Lomé avec une voix puissante et des messages d'espoir.")
//                     .verifie(true)
//                     .build());

//             var artiste5 = (Artiste) utilisateurRepository.save(
//                 Artiste.builder()
//                     .username("dj_savane")
//                     .email("dj.savane@music.tg")
//                     .password(passwordEncoder.encode("Artiste@2026!"))
//                     .telephone("+22891000005")
//                     .role(Role.ROLE_ARTISTE)
//                     .status(Statut.ACTIF)
//                     .emailVerified(true)
//                     .artistName("DJ Savane")
//                     .bio("DJ producteur spécialisé coupé-décalé et afro house. Collabore avec les plus grands artistes de la sous-région.")
//                     .verifie(true)
//                     .build());

//             log.info("  ✔ 5 artistes créés.");

//             // ─────────────────────────────────────────────────────────────────
//             // 5. ALBUMS
//             // ─────────────────────────────────────────────────────────────────
//             var album1 = albumRepository.save(Album.builder()
//                     .title("Racines du Golfe")
//                     .dateSortie(LocalDate.of(2024, 3, 15))
//                     .coverImage("racines_golfe_cover.jpg")
//                     .artiste(artiste1)
//                     .build());

//             var album2 = albumRepository.save(Album.builder()
//                     .title("Femme du Sahel")
//                     .dateSortie(LocalDate.of(2024, 7, 1))
//                     .coverImage("femme_sahel_cover.jpg")
//                     .artiste(artiste2)
//                     .build());

//             var album3 = albumRepository.save(Album.builder()
//                     .title("Street Togolais")
//                     .dateSortie(LocalDate.of(2023, 11, 20))
//                     .coverImage("street_togolais_cover.jpg")
//                     .artiste(artiste3)
//                     .build());

//             var album4 = albumRepository.save(Album.builder()
//                     .title("Lumière d'Afrique")
//                     .dateSortie(LocalDate.of(2025, 1, 10))
//                     .coverImage("lumiere_afrique_cover.jpg")
//                     .artiste(artiste4)
//                     .build());

//             log.info("  ✔ 4 albums créés.");

//             // ─────────────────────────────────────────────────────────────────
//             // 6. CHANSONS
//             // ─────────────────────────────────────────────────────────────────
//             // Chansons de Kofi Mensah
//             var c1 = chansonRepository.save(Chansons.builder()
//                     .titre("Lomé la Nuit").duree(214).nbEcoutes(4820L)
//                     .audioUrl("kofi_lome_la_nuit.mp3").artiste(artiste1)
//                     .album(album1).categorie(catAfrobeat).build());
//             var c2 = chansonRepository.save(Chansons.builder()
//                     .titre("Ewé Groove").duree(198).nbEcoutes(3210L)
//                     .audioUrl("kofi_ewe_groove.mp3").artiste(artiste1)
//                     .album(album1).categorie(catAfrobeat).build());
//             var c3 = chansonRepository.save(Chansons.builder()
//                     .titre("Plage de Cococodji").duree(243).nbEcoutes(6700L)
//                     .audioUrl("kofi_plage_cococodji.mp3").artiste(artiste1)
//                     .categorie(catAfrobeat).build());
//             var c4 = chansonRepository.save(Chansons.builder()
//                     .titre("Tam-Tam Moderne").duree(187).nbEcoutes(1540L)
//                     .audioUrl("kofi_tamtam_moderne.mp3").artiste(artiste1)
//                     .album(album1).categorie(catAfrobeat).build());

//             // Chansons de Nana Vibes
//             var c5 = chansonRepository.save(Chansons.builder()
//                     .titre("Femme Libre").duree(267).nbEcoutes(8920L)
//                     .audioUrl("nana_femme_libre.mp3").artiste(artiste2)
//                     .album(album2).categorie(catRnb).build());
//             var c6 = chansonRepository.save(Chansons.builder()
//                     .titre("Mon Coeur Kara").duree(231).nbEcoutes(5430L)
//                     .audioUrl("nana_mon_coeur_kara.mp3").artiste(artiste2)
//                     .album(album2).categorie(catRnb).build());
//             var c7 = chansonRepository.save(Chansons.builder()
//                     .titre("Danse avec Moi").duree(204).nbEcoutes(3870L)
//                     .audioUrl("nana_danse_avec_moi.mp3").artiste(artiste2)
//                     .categorie(catPop).build());

//             // Chansons de MC TogoMan
//             var c8 = chansonRepository.save(Chansons.builder()
//                     .titre("Rue de Tsévié").duree(189).nbEcoutes(2340L)
//                     .audioUrl("mc_rue_tsevie.mp3").artiste(artiste3)
//                     .album(album3).categorie(catRap).build());
//             var c9 = chansonRepository.save(Chansons.builder()
//                     .titre("Flow Mina").duree(213).nbEcoutes(1890L)
//                     .audioUrl("mc_flow_mina.mp3").artiste(artiste3)
//                     .album(album3).categorie(catRap).build());
//             var c10 = chansonRepository.save(Chansons.builder()
//                     .titre("Vérité Togolaise").duree(237).nbEcoutes(4120L)
//                     .audioUrl("mc_verite_togolaise.mp3").artiste(artiste3)
//                     .categorie(catRap).build());

//             // Chansons de Grace Amavi
//             var c11 = chansonRepository.save(Chansons.builder()
//                     .titre("Grâce et Gloire").duree(298).nbEcoutes(7650L)
//                     .audioUrl("grace_grace_et_gloire.mp3").artiste(artiste4)
//                     .album(album4).categorie(catGospel).build());
//             var c12 = chansonRepository.save(Chansons.builder()
//                     .titre("Espoir Infini").duree(315).nbEcoutes(5980L)
//                     .audioUrl("grace_espoir_infini.mp3").artiste(artiste4)
//                     .album(album4).categorie(catGospel).build());
//             var c13 = chansonRepository.save(Chansons.builder()
//                     .titre("Alléluia Lomé").duree(281).nbEcoutes(9230L)
//                     .audioUrl("grace_alleluia_lome.mp3").artiste(artiste4)
//                     .categorie(catGospel).build());

//             // Chansons de DJ Savane
//             var c14 = chansonRepository.save(Chansons.builder()
//                     .titre("Décalé Savane").duree(195).nbEcoutes(11400L)
//                     .audioUrl("dj_decale_savane.mp3").artiste(artiste5)
//                     .categorie(catCoupeDecale).build());
//             var c15 = chansonRepository.save(Chansons.builder()
//                     .titre("Afro House Togo").duree(382).nbEcoutes(8760L)
//                     .audioUrl("dj_afro_house_togo.mp3").artiste(artiste5)
//                     .categorie(catCoupeDecale).build());

//             log.info("  ✔ 15 chansons créées.");

//             // ─────────────────────────────────────────────────────────────────
//             // 7. AUDITEURS (6 auditeurs fictifs)
//             // ─────────────────────────────────────────────────────────────────
//             var aud1 = (Auditeur) utilisateurRepository.save(
//                 Auditeur.builder()
//                     .username("amina_k").email("amina.koffi@email.tg")
//                     .password(passwordEncoder.encode("Auditeur@2026!"))
//                     .telephone("+22892000001")
//                     .role(Role.ROLE_AUDITEUR).status(Statut.ACTIF)
//                     .emailVerified(true).abonnementActif(true).build());

//             var aud2 = (Auditeur) utilisateurRepository.save(
//                 Auditeur.builder()
//                     .username("yao_m").email("yao.mensah@email.tg")
//                     .password(passwordEncoder.encode("Auditeur@2026!"))
//                     .telephone("+22892000002")
//                     .role(Role.ROLE_AUDITEUR).status(Statut.ACTIF)
//                     .emailVerified(true).abonnementActif(true).build());

//             var aud3 = (Auditeur) utilisateurRepository.save(
//                 Auditeur.builder()
//                     .username("esi_a").email("esi.adjoa@email.tg")
//                     .password(passwordEncoder.encode("Auditeur@2026!"))
//                     .telephone("+22892000003")
//                     .role(Role.ROLE_AUDITEUR).status(Statut.ACTIF)
//                     .emailVerified(true).abonnementActif(false).build());

//             var aud4 = (Auditeur) utilisateurRepository.save(
//                 Auditeur.builder()
//                     .username("kwame_d").email("kwame.dossou@email.tg")
//                     .password(passwordEncoder.encode("Auditeur@2026!"))
//                     .telephone("+22892000004")
//                     .role(Role.ROLE_AUDITEUR).status(Statut.ACTIF)
//                     .emailVerified(true).abonnementActif(true).build());

//             var aud5 = (Auditeur) utilisateurRepository.save(
//                 Auditeur.builder()
//                     .username("akua_b").email("akua.boko@email.tg")
//                     .password(passwordEncoder.encode("Auditeur@2026!"))
//                     .telephone("+22892000005")
//                     .role(Role.ROLE_AUDITEUR).status(Statut.ACTIF)
//                     .emailVerified(true).abonnementActif(false).build());

//             var aud6 = (Auditeur) utilisateurRepository.save(
//                 Auditeur.builder()
//                     .username("tobi_f").email("tobi.fiagan@email.tg")
//                     .password(passwordEncoder.encode("Auditeur@2026!"))
//                     .telephone("+22892000006")
//                     .role(Role.ROLE_AUDITEUR).status(Statut.ACTIF)
//                     .emailVerified(true).abonnementActif(true).build());

//             log.info("  ✔ 6 auditeurs créés.");

//             // ─────────────────────────────────────────────────────────────────
//             // 8. ABONNEMENTS + PAIEMENTS
//             // ─────────────────────────────────────────────────────────────────
//             var now = LocalDateTime.now();

//             // Amina — abonnement mensuel actif
//             var ab1 = abonnementRepository.save(Abonnement.builder()
//                     .auditeur(aud1).offerCode("MONTHLY").mobileMoneyRef("FLOOZ-2026-001")
//                     .startDate(now.minusDays(10)).endDate(now.plusDays(20)).active(true).build());
//             paiementRepository.save(Paiement.builder()
//                     .auditeur(aud1).abonnement(ab1).montant(2000.0)
//                     .modePaiement(ModePaiement.FLOOZ).statut("SUCCES").build());

//             // Yao — abonnement annuel actif
//             var ab2 = abonnementRepository.save(Abonnement.builder()
//                     .auditeur(aud2).offerCode("YEARLY").mobileMoneyRef("TMONEY-2026-002")
//                     .startDate(now.minusMonths(2)).endDate(now.plusMonths(10)).active(true).build());
//             paiementRepository.save(Paiement.builder()
//                     .auditeur(aud2).abonnement(ab2).montant(18000.0)
//                     .modePaiement(ModePaiement.TMONEY).statut("SUCCES").build());

//             // Kwame — abonnement hebdomadaire actif
//             var ab3 = abonnementRepository.save(Abonnement.builder()
//                     .auditeur(aud4).offerCode("WEEKLY").mobileMoneyRef("WAVE-2026-003")
//                     .startDate(now.minusDays(2)).endDate(now.plusDays(5)).active(true).build());
//             paiementRepository.save(Paiement.builder()
//                     .auditeur(aud4).abonnement(ab3).montant(500.0)
//                     .modePaiement(ModePaiement.WAVE).statut("SUCCES").build());

//             // Tobi — abonnement mensuel actif
//             var ab4 = abonnementRepository.save(Abonnement.builder()
//                     .auditeur(aud6).offerCode("MONTHLY").mobileMoneyRef("FLOOZ-2026-004")
//                     .startDate(now.minusDays(5)).endDate(now.plusDays(25)).active(true).build());
//             paiementRepository.save(Paiement.builder()
//                     .auditeur(aud6).abonnement(ab4).montant(2000.0)
//                     .modePaiement(ModePaiement.FLOOZ).statut("SUCCES").build());

//             // Esi — abonnement expiré
//             var ab5 = abonnementRepository.save(Abonnement.builder()
//                     .auditeur(aud3).offerCode("WEEKLY").mobileMoneyRef("TMONEY-2026-005")
//                     .startDate(now.minusDays(14)).endDate(now.minusDays(7)).active(false).build());
//             paiementRepository.save(Paiement.builder()
//                     .auditeur(aud3).abonnement(ab5).montant(500.0)
//                     .modePaiement(ModePaiement.TMONEY).statut("SUCCES").build());

//             log.info("  ✔ 5 abonnements + 5 paiements créés.");

//             // ─────────────────────────────────────────────────────────────────
//             // 9. ÉVÉNEMENTS / CONCERTS
//             // ─────────────────────────────────────────────────────────────────
//             evenementRepository.saveAll(List.of(
//                 Evenement.builder()
//                     .nameConcert("Afrobeat Night — Lomé")
//                     .artiste(artiste1)
//                     .dateEvenement(now.plusMonths(1).withHour(20).withMinute(0))
//                     .dateLimite(now.plusMonths(1).minusDays(2))
//                     .lieu("Palais des Congrès de Lomé")
//                     .prixTicket(5000.0).build(),

//                 Evenement.builder()
//                     .nameConcert("Nana Vibes Live — Kara")
//                     .artiste(artiste2)
//                     .dateEvenement(now.plusMonths(2).withHour(19).withMinute(30))
//                     .dateLimite(now.plusMonths(2).minusDays(3))
//                     .lieu("Centre Culturel de Kara")
//                     .prixTicket(3000.0).build(),

//                 Evenement.builder()
//                     .nameConcert("Gospel en Fête — Lomé")
//                     .artiste(artiste4)
//                     .dateEvenement(now.plusWeeks(3).withHour(16).withMinute(0))
//                     .dateLimite(now.plusWeeks(3).minusDays(1))
//                     .lieu("Cathédrale de Lomé")
//                     .prixTicket(1000.0).build(),

//                 Evenement.builder()
//                     .nameConcert("DJ Savane — Pool Party")
//                     .artiste(artiste5)
//                     .dateEvenement(now.plusWeeks(5).withHour(17).withMinute(0))
//                     .dateLimite(now.plusWeeks(5).minusDays(1))
//                     .lieu("Hôtel Palm Beach, Lomé")
//                     .prixTicket(7500.0).build(),

//                 // Concert passé (historique)
//                 Evenement.builder()
//                     .nameConcert("MC TogoMan — Freestyle Battle")
//                     .artiste(artiste3)
//                     .dateEvenement(now.minusMonths(1).withHour(21).withMinute(0))
//                     .dateLimite(now.minusMonths(1).minusDays(2))
//                     .lieu("Bar Le Karaté, Tsévié")
//                     .prixTicket(1500.0).build()
//             ));
//             log.info("  ✔ 5 événements créés.");

//             // ─────────────────────────────────────────────────────────────────
//             // 10. NOTIFICATIONS
//             // ─────────────────────────────────────────────────────────────────
//             notificationRepository.saveAll(List.of(
//                 Notification.builder()
//                     .titre("Bienvenue sur Titan Tunes 🎵")
//                     .message("Découvrez les meilleurs artistes togolais et africains sur notre plateforme. Bon écoute !")
//                     .auditeur(aud1).build(),

//                 Notification.builder()
//                     .titre("Nouveau single de Kofi Mensah !")
//                     .message("\"Plage de Cococodji\" est maintenant disponible. Écoutez-le en avant-première !")
//                     .auditeur(aud1).build(),

//                 Notification.builder()
//                     .titre("Votre abonnement est actif")
//                     .message("Profitez de l'écoute illimitée sans publicité pendant 30 jours. Bonne musique !")
//                     .auditeur(aud2).build(),

//                 Notification.builder()
//                     .titre("Concert à ne pas manquer 🎤")
//                     .message("Nana Vibes sera en live à Kara le mois prochain. Réservez vos places maintenant !")
//                     .auditeur(aud2).build(),

//                 Notification.builder()
//                     .titre("Grace Amavi — Nouvel album !")
//                     .message("\"Lumière d'Afrique\" est sorti ! 12 titres gospel pour élever votre âme.")
//                     .auditeur(aud3).build(),

//                 Notification.builder()
//                     .titre("Votre abonnement a expiré")
//                     .message("Renouvelez votre abonnement pour continuer à profiter de Titan Tunes sans interruption.")
//                     .auditeur(aud3).build(),

//                 Notification.builder()
//                     .titre("DJ Savane — Pool Party !")
//                     .message("Le set de l'année approche. Réservez votre ticket pour la Pool Party du DJ Savane !")
//                     .auditeur(aud4).build(),

//                 Notification.builder()
//                     .titre("Tendances du moment 🔥")
//                     .message("\"Décalé Savane\" de DJ Savane est la chanson la plus écoutée cette semaine. Vous l'avez entendue ?")
//                     .auditeur(aud5).build(),

//                 Notification.builder()
//                     .titre("Bienvenue sur Titan Tunes 🎵")
//                     .message("Créez vos playlists, suivez vos artistes préférés et découvrez de nouveaux talents togolais !")
//                     .auditeur(aud6).build()
//             ));
//             log.info("  ✔ 9 notifications créées.");

//             // ─────────────────────────────────────────────────────────────────
//             log.info("DataSeeder ✅ Base de données initialisée avec succès !");
//             log.info("─────────────────────────────────────────────────────");
//             log.info("  ADMIN    → admin@titan.com            / titansupadmin@2005");
//             log.info("  ARTISTE  → kofi.mensah@music.tg       / Artiste@2026!");
//             log.info("  ARTISTE  → nana.adjoa@music.tg        / Artiste@2026!");
//             log.info("  ARTISTE  → togoman.rap@music.tg       / Artiste@2026!");
//             log.info("  ARTISTE  → grace.amavi@music.tg       / Artiste@2026!");
//             log.info("  ARTISTE  → dj.savane@music.tg         / Artiste@2026!");
//             log.info("  AUDITEUR → amina.koffi@email.tg       / Auditeur@2026!");
//             log.info("  AUDITEUR → yao.mensah@email.tg        / Auditeur@2026!");
//             log.info("  AUDITEUR → esi.adjoa@email.tg         / Auditeur@2026!");
//             log.info("─────────────────────────────────────────────────────");
//         };
//     }
// }
