# Plan d'Implémentation Frontend Titan Tunes (Intégration Backend Complète)

Ce plan détaille la mise en place complète de l'interface et de la logique Front-end Flutter pour s'interfacer avec l'ensemble des endpoints et fonctionnalités de l'API Backend Spring Boot Titan Tunes (`http://localhost:8080/api/v1`).

---

## 1. Architecture & Nouveaux Composants

```
lib/
├── core/
│   ├── app_theme.dart                 # Thème Glassmorphism & Couleurs
│   └── api_config.dart                # [NEW] Configuration Base URL (Web/Android/IP)
├── network/
│   ├── network_api_client.dart        # [MODIFY] Dio Client + Intercepteur 401 Auto-Refresh
│   └── secure_token_storage.dart      # [MODIFY] Stockage JWT Access + Refresh Token
├── data/
│   ├── models/
│   │   ├── api_response.dart          # [MODIFY] Enveloppes ApiResponse<T> & PageResponse<T>
│   │   ├── offre_abonnement.dart      # [NEW] Modèle Offres (DAILY, WEEKLY, MONTHLY, etc.)
│   │   ├── paiement_result.dart       # [NEW] Modèle Retour Paiement Mobile Money
│   │   ├── artiste_dashboard.dart     # [NEW] Modèle Stats Dashboard & Royalties Artiste
│   │   ├── reversement.dart           # [NEW] Modèle Historique des reversements
│   │   ├── categorie.dart             # [NEW] Modèle Catégories musicales
│   │   └── search_result.dart         # [NEW] Modèle Résultats recherche globale
│   ├── services/
│   │   ├── api_auth_service.dart      # [MODIFY] Login, Register (rôles), Refresh, Logout, Forgot/Reset
│   │   ├── abonnement_service.dart    # [NEW] Offres + Souscription & Paiement Mobile Money
│   │   ├── artiste_service.dart       # [NEW] Dashboard stats, Royalties, Publication multipart
│   │   └── recherche_service.dart     # [NEW] Recherche multi-catégories
│   └── repositories/
│       ├── audio_repository.dart      # [MODIFY] Interface
│       └── remote_audio_repository.dart # [MODIFY] Intégration backend complète + écoutes async
├── providers/
│   ├── auth_provider.dart             # [MODIFY] Gestion session, refresh token, rôles, comptes test
│   ├── audio_provider.dart            # [MODIFY] Stream présigné, compteur d'écoute async, playlists API
│   ├── abonnement_provider.dart       # [NEW] État des offres et paiement Mobile Money
│   └── artiste_provider.dart          # [NEW] État du dashboard artiste et publication de chanson
└── presentation/
    ├── pages/
    │   ├── login_page.dart            # [MODIFY] Inscription avec choix de rôle + Sélecteur 1-clic Comptes Test + Dialog Forgot/Reset
    │   ├── subscription_page.dart     # [MODIFY] Offres dynamiques backend + Modal Paiement Mobile Money (Flooz, T-Money, Wave)
    │   ├── search_page.dart           # [MODIFY] Recherche globale multi-catégories
    │   ├── profil/
    │   │   └── page_profil.dart       # [MODIFY] Ajout de l'accès au Dashboard Artiste & gestion abonnement
    │   └── artiste/
    │       ├── artist_dashboard_page.dart # [NEW] KPI (Écoutes, Auditeurs, Royalties FCFA, Part catalogue) + Historique reversements
    │       └── publish_song_modal.dart    # [NEW] Formulaire d'upload multipart audio (.mp3, .wav) + métadonnées
    └── widgets/
        └── test_accounts_bottom_sheet.dart # [NEW] Sélecteur rapide des comptes de test fournis dans le guide
```

---

## 2. Détail des Modules & Modifications

### A. Authentification, Tokens & Comptes de Test (Section 3 & 8)
- **Stockage sécurisé (`secure_token_storage.dart`)** : Gestion persistante de l'Access Token et du Refresh Token.
- **Intercepteur Dio (`network_api_client.dart`)** : Détection des erreurs 401 Unauthorized pour renouveler automatiquement l'Access Token via `POST /auth/refresh` et rejouer la requête transparente pour l'utilisateur.
- **Service Auth (`api_auth_service.dart`)** :
  - `login` : Récupération du token, refreshToken, userId, role.
  - `register` : Prise en compte du rôle (`ROLE_AUDITEUR` ou `ROLE_ARTISTE`) et du champ `artistName`.
  - `logout` : Invalidation côté backend via `POST /auth/logout`.
  - `forgotPassword` & `resetPassword` : Réinitialisation de mot de passe par token.
  - `oauth2Callback` : Support Google / Facebook SSO.
- **Comptes de Test (1-Clic)** : Intégration d'un tiroir d'accès direct aux comptes de test du guide :
  - **ADMIN** : `admin@titan-tune.com`
  - **ARTISTE** : `kofi.mensah.artiste@music.tg` / `artiste.test@titan-tunes.com`
  - **ARTISTE** : `nana.adjoa.artiste@music.tg`
  - **AUDITEUR Abonné** : `amina.koffi@email.tg`
  - **AUDITEUR Non abonné** : `akua.boko@email.tg`

### B. Module Catalogue, Streaming & Écoutes Asynchrones (Section 4)
- **Flux Streaming** :
  - Appel `GET /api/v1/chansons/{id}/stream` pour récupérer le lien de streaming présigné (avec fallback transparent si local/démo).
  - Lecture fluide via `just_audio`.
- **Compteur d'écoute asynchrone** :
  - Appel asynchrone `POST /api/v1/ecoutes/async` avec `{ auditeurId, chansonId, dureeEcoute }` dès que l'auditeur écoute le morceau (> 30s ou morceau terminé).
- **Recherche Globale** :
  - Appel `GET /api/v1/recherche?query=...&limit=5` avec affichage par onglets/sections (Chansons, Artistes, Albums, Playlists).

### C. Module Abonnements & Paiements Mobile Money (Section 5)
- **Offres dynamiques** :
  - Appel `GET /api/v1/abonnements/offres` pour afficher les 5 offres (`DAILY` 100 F, `WEEKLY` 500 F, `MONTHLY` 2 000 F, `QUARTERLY` 5 000 F, `YEARLY` 18 000 F) avec leurs avantages détaillés et prix par jour.
- **Parcours de souscription en 1 étape** :
  - Sélection du moyen de paiement Mobile Money : **Moov Africa (FLOOZ)**, **Togocel (T-MONEY)**, **WAVE**.
  - Saisie du numéro de téléphone avec indicatif `+228`.
  - Génération d'une `idempotencyKey` unique (UUID v4 anti-double-clic).
  - Envoi vers `POST /api/v1/abonnements/souscrire-et-payer`.
  - Gestion des statuts 201 Created (abonnement activé, affichage reçu de transaction) et 402 Payment Required (message d'erreur opérateur explicite).

### D. Module Artiste, Dashboard & Publication (Section 6)
- **Dashboard Artiste (`artist_dashboard_page.dart`)** :
  - Récupération de `GET /api/v1/artistes/{id}/dashboard` : Total écoutes, auditeurs uniques, catalogue, royalties estimées en FCFA, part de catalogue.
  - Récupération de `GET /api/v1/reversements/artiste/{id}?page=0&size=10` : Historique paginé des reversements avec montants et statuts.
- **Publication d'un morceau (`publish_song_modal.dart`)** :
  - Sélection de fichier audio `.mp3` ou `.wav` via `file_picker`.
  - Formulaire : Titre, durée, paroles, sélection catégorie (`GET /api/v1/categories`), album optionnel.
  - Envoi multipart `POST /api/v1/chansons/publier` (part `data` JSON + part `file` binaire).

### E. Module Playlists & Favoris (Section 7)
- **Favoris** :
  - `POST /api/v1/favoris` avec `{ utilisateurId, targetId, type: "CHANSON" | "ALBUM" | "ARTISTE" | "PLAYLIST" }`.
  - `DELETE /api/v1/favoris/user/{id}/target/{targetId}?type=CHANSON`.
- **Playlists** :
  - Création : `POST /api/v1/playlists` (`{ nom, isPublic, auditeurId }`).
  - Ajout : `POST /api/v1/playlists/{playlistId}/chansons/{chansonId}`.
  - Retrait : `DELETE /api/v1/playlists/{playlistId}/chansons/{chansonId}`.

---

## 3. Plan de Vérification

### Tests Automatisés & Analyse de Code
- Exécuter `flutter analyze` pour vérifier l'absence totale d'erreurs et de warnings de compilation.
- Vérifier la validité des modèles Dart avec parsing JSON.

### Tests d'Intégration Réseau en Direct
- Valider le flux d'authentification (connexion, rafraîchissement token, déconnexion).
- Valider la souscription Mobile Money avec génération d'idempotency key.
- Valider le Dashboard Artiste et la publication de morceaux.
- Valider la lecture audio et le déclenchement des écoutes asynchrones.
