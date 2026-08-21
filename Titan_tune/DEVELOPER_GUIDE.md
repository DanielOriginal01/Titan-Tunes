# Titan Tunes — Guide Développeur

> Document de référence pour tout développeur reprenant ce projet.
> Dernière mise à jour : août 2026.

---

## Table des matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Stack technique](#2-stack-technique)
3. [Architecture du projet](#3-architecture-du-projet)
4. [Infrastructure & démarrage](#4-infrastructure--démarrage)
5. [Sécurité & authentification](#5-sécurité--authentification)
6. [Catalogue des 91 endpoints](#6-catalogue-des-91-endpoints)
7. [Modèle de données](#7-modèle-de-données)
8. [Services métier](#8-services-métier)
9. [Fonctionnalités à compléter](#9-fonctionnalités-à-compléter)
10. [Points d'amélioration technique](#10-points-damélioration-technique)
11. [Données de test](#11-données-de-test)
12. [Conventions de code](#12-conventions-de-code)

---

## 1. Vue d'ensemble

**Titan Tunes** est une API REST de streaming musical africain (Togo).
Elle permet à des artistes de publier leur musique, aux auditeurs d'écouter et s'abonner,
et aux admins de gérer la plateforme et les reversements financiers.

```
Chiffres clés du projet :
  - 167 fichiers Java
  - 5 538 lignes de code
  - 91 endpoints REST
  - 22 entités JPA
  - 22 repositories Spring Data
  - 23 interfaces de service / 20 implémentations
  - 18 controllers REST
```

---

## 2. Stack technique

| Composant         | Version       | Rôle                                       |
|-------------------|---------------|--------------------------------------------|
| Java              | 25.0.1        | Langage                                    |
| Spring Boot       | 3.3.2         | Framework principal                        |
| Spring Security   | 6.x           | Authentification JWT + autorisation        |
| JJWT              | 0.12.6        | Génération / validation des tokens JWT     |
| Spring Data JPA   | 3.x           | ORM (Hibernate 6.5)                        |
| PostgreSQL        | 16            | Base de données principale                 |
| H2                | —             | Base mémoire pour les tests uniquement     |
| MinIO SDK         | 8.5.12        | Stockage fichiers audio et images          |
| Spring Mail       | 3.x           | Envoi d'emails (vérification, reset mdp)   |
| SpringDoc OpenAPI | 2.6.0         | Documentation Swagger auto-générée         |
| Lombok            | 1.18.38       | Réduction boilerplate Java                 |
| Docker Compose    | —             | Orchestration PostgreSQL + MinIO + pgAdmin |

---

## 3. Architecture du projet

```
src/main/java/dan/com/titan_tune/
├── TitanTuneApplication.java       ← Point d'entrée (@SpringBootApplication, @EnableAsync)
│
├── config/
│   ├── DataSeeder.java             ← Seed des données fictives au démarrage (idempotent)
│   ├── MinioConfig.java            ← Bean MinioClient
│   └── SecurityConfig.java         ← Règles d'autorisation URL + CORS + JWT filter
│
├── controller/                     ← 18 controllers REST
│   ├── AuthController.java
│   ├── AdminController.java
│   ├── ArtisteController.java
│   ├── AuditeurController.java
│   ├── ChansonController.java
│   ├── AlbumController.java
│   ├── PlaylistController.java
│   ├── FavorisController.java
│   ├── EcouteController.java
│   ├── AbonnementController.java
│   ├── PaiementController.java
│   ├── NotificationController.java
│   ├── EvenementController.java
│   ├── TelechargementController.java
│   ├── CategorieController.java
│   ├── LabelController.java
│   ├── BanniereController.java
│   └── ReversementController.java
│
├── service/                        ← 23 interfaces de service
│   └── impl/                       ← 20 implémentations
│
├── repository/                     ← 22 repositories Spring Data JPA
├── entities/                       ← 22 entités JPA
├── enums/                          ← Role, Statut, ModePaiement, TypePromotion, QualiteAudio
├── dtos/
│   ├── dtorequest/                 ← 15 DTOs entrants (Java records avec validation)
│   └── dtoresponse/                ← 18 DTOs sortants (Java records avec fromEntity())
├── dto/                            ← ApiResponse<T> (enveloppe universelle)
├── security/
│   ├── JwtUtils.java               ← Génération/validation JWT
│   ├── JwtAuthenticationFilter.java ← Filtre Bearer token
│   ├── UserDetailsServiceImpl.java ← Chargement user + vérification statut compte
│   └── SecurityUtils.java          ← Helper ownership (assertOwnerOrAdmin)
└── exception/
    ├── GlobalExceptionHandler.java ← @RestControllerAdvice centralisé
    ├── BusinessException.java      ← Exception métier avec HttpStatus
    └── ResourceNotFoundException.java
```

### Pattern architectural

```
Requête HTTP
    → JwtAuthenticationFilter (valide le token, charge UserDetails)
    → SecurityConfig (règles URL)
    → Controller (@PreAuthorize + SecurityUtils.assertOwnerOrAdmin)
    → Service (logique métier)
    → Repository (Spring Data JPA)
    → Entité JPA (PostgreSQL)
    → DTO de réponse (fromEntity)
    → ApiResponse<T>
```

---

## 4. Infrastructure & démarrage

### Prérequis
- Docker Desktop installé et démarré
- Java 21+ (Java 25 recommandé)
- Maven (fourni via `mvnw.cmd`)

### Démarrage rapide

```powershell
# 1. Démarrer PostgreSQL + MinIO + pgAdmin
docker compose up -d postgres minio pgadmin

# 2. Lancer l'application
.\mvnw.cmd spring-boot:run
```

### Services disponibles

| Service         | URL                              | Credentials                              |
|-----------------|----------------------------------|------------------------------------------|
| API REST        | http://localhost:8080            | JWT Bearer token                         |
| Swagger UI      | http://localhost:8080/swagger-ui | Public                                   |
| pgAdmin (BDD)   | http://localhost:5050            | admin@titan-tune.com / admin             |
| MinIO Console   | http://localhost:9001            | minioadmin / Titan@tunes2026             |
| PostgreSQL JDBC | localhost:5433                   | titan_admin / Titan@tunes2026 / titan_tune_db |

### Variables d'environnement (.env)

```
POSTGRES_DB=titan_tune_db
POSTGRES_USER=titan_admin
POSTGRES_PASSWORD=Titan@tunes2026
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=Titan@tunes2026
PGADMIN_EMAIL=admin@titan-tune.com
PGADMIN_PASSWORD=admin

# SMTP (à configurer avec vos vraies valeurs)
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=votre-email@gmail.com
MAIL_PASSWORD=votre-app-password
MAIL_FROM=no-reply@titan-tune.com
MAIL_SMTP_AUTH=true
MAIL_SMTP_STARTTLS_ENABLE=true
APP_BASE_URL=http://localhost:8080
```

---

## 5. Sécurité & authentification

### Flux d'authentification

```
POST /api/v1/auth/login
Body: { "emailOuUsername": "...", "password": "..." }

Réponse:
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "type": "Bearer",
    "id": 1,
    "username": "kofi_beats",
    "email": "kofi.mensah@music.tg",
    "role": "ROLE_ARTISTE"
  }
}
```

### Utilisation du token

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

### Rôles et permissions

| Rôle             | Valeur JWT        | Accès                                                |
|------------------|-------------------|------------------------------------------------------|
| `ROLE_AUDITEUR`  | ROLE_AUDITEUR     | Playlists, favoris, écoutes, abonnements, profil     |
| `ROLE_ARTISTE`   | ROLE_ARTISTE      | Publication musique, profil, bannières, dashboard    |
| `ROLE_ADMIN`     | ROLE_ADMIN        | Tout + gestion users, reversements, stats globales   |

### Règles d'ownership

Implémentées via `SecurityUtils.assertOwnerOrAdmin(ownerId)` :

- Un **artiste** ne peut modifier que **son propre** profil / chansons / bannières / dashboard
- Un **auditeur** ne peut modifier que **son propre** profil
- Un **admin** contourne toutes les vérifications d'ownership

### Routes publiques (sans token)

```
GET  /api/v1/chansons            → liste des chansons
GET  /api/v1/chansons/tendances  → top écoutes
GET  /api/v1/chansons/recherche  → recherche
GET  /api/v1/artistes            → liste des artistes
GET  /api/v1/artistes/{id}       → profil artiste
GET  /api/v1/bannieres/actives   → carrousel homepage
GET  /api/v1/evenements          → liste concerts
GET  /api/v1/categories          → liste catégories
GET  /api/v1/labels              → liste labels
POST /api/v1/auth/**             → register, login, reset password
```

### Sécurité des comptes

Un compte avec le statut `INACTIF` ou `SUPPRIME` est bloqué dès la prochaine requête.
Le token JWT reste valide 24h — pour invalider immédiatement, implémenter une blacklist (voir section 9).

---

## 6. Catalogue des 91 endpoints

### Format de réponse universel

```json
{
  "success": true,
  "message": "Description de l'action",
  "data": { ... },
  "timestamp": "2026-08-13T10:00:00",
  "status": 200
}
```

### Authentification — `/api/v1/auth`

| Méthode | Endpoint               | Auth    | Description                              |
|---------|------------------------|---------|------------------------------------------|
| POST    | `/register`            | Public  | Inscription AUDITEUR ou ARTISTE          |
| POST    | `/login`               | Public  | Connexion → retourne JWT                 |
| POST    | `/admin/create`        | ADMIN   | Crée un compte admin (1 seul autorisé)   |
| GET     | `/verify?token=`       | Public  | Vérifie l'email via token                |
| POST    | `/verify-request`      | Public  | Renvoie l'email de vérification          |
| POST    | `/forgot-password`     | Public  | Demande reset mot de passe               |
| POST    | `/reset-password`      | Public  | Applique le nouveau mot de passe         |

### Artistes — `/api/v1/artistes`

| Méthode | Endpoint            | Auth               | Description                        |
|---------|---------------------|--------------------|------------------------------------|
| GET     | `/`                 | Public             | Liste tous les artistes            |
| GET     | `/{id}`             | Public             | Profil d'un artiste                |
| GET     | `/{id}/photo/url`   | Public             | URL présignée de la photo (1h)     |
| PUT     | `/{id}`             | ARTISTE (owner)    | Met à jour bio, nom, photo         |
| POST    | `/{id}/photo`       | ARTISTE (owner)    | Upload photo → MinIO               |
| GET     | `/{id}/dashboard`   | ARTISTE (owner)    | Stats : écoutes, royalties, etc.   |

### Auditeurs — `/api/v1/auditeurs`

| Méthode | Endpoint  | Auth               | Description                        |
|---------|-----------|--------------------|-------------------------------------|
| GET     | `/`       | ADMIN              | Liste tous les auditeurs            |
| GET     | `/{id}`   | AUDITEUR (owner)   | Profil d'un auditeur                |
| PUT     | `/{id}`   | AUDITEUR (owner)   | Met à jour username, tel, photo     |

### Admin — `/api/v1/admin` (tout ADMIN)

| Méthode | Endpoint                          | Description                       |
|---------|-----------------------------------|-----------------------------------|
| GET     | `/utilisateurs`                   | Liste tous les utilisateurs       |
| PUT     | `/utilisateurs/{id}/statut`       | Change le statut (ACTIF/INACTIF)  |
| PUT     | `/artistes/{id}/verifier`         | Badge de vérification artiste     |
| GET     | `/artistes/en-attente`            | Artistes non vérifiés             |
| GET     | `/dashboard/stats`                | Statistiques globales résumées    |
| GET     | `/dashboard/metriques`            | Compteurs users/artistes/auditeurs|
| GET     | `/dashboard/finances`             | Revenus, royalties, transactions  |

### Chansons — `/api/v1/chansons`

| Méthode | Endpoint          | Auth            | Description                        |
|---------|-------------------|-----------------|------------------------------------|
| GET     | `/`               | Public          | Liste toutes les chansons          |
| GET     | `/tendances`      | Public          | Top par nb d'écoutes               |
| GET     | `/recherche`      | Public          | Recherche par titre                |
| GET     | `/{id}`           | Public          | Détail d'une chanson               |
| GET     | `/{id}/stream`    | Authentifié     | URL de streaming MinIO (1h)        |
| POST    | `/publier`        | ARTISTE (owner) | Upload audio + métadonnées         |
| DELETE  | `/{id}`           | ARTISTE (owner) | Supprime sa chanson                |

### Albums — `/api/v1/albums`

| GET `/{id}`, GET `/artiste/{artisteId}` → Public | POST `/`, DELETE `/{id}` → ARTISTE/ADMIN |

### Playlists — `/api/v1/playlists`

| POST `/`, POST `/{id}/chansons/{chansonId}`, DELETE `/` → AUDITEUR |

### Favoris — `/api/v1/favoris`

```json
POST /api/v1/favoris
{
  "utilisateurId": 1,
  "targetId": 5,
  "type": "CHANSON"   // CHANSON | ALBUM | ARTISTE | PLAYLIST
}
```

### Écoutes — `/api/v1/ecoutes`

```json
POST /api/v1/ecoutes           → enregistre + incrémente nbEcoutes (synchrone)
POST /api/v1/ecoutes/async     → idem en arrière-plan (202 Accepted)
GET  /api/v1/ecoutes/historique/{auditeurId}
```

### Abonnements — `/api/v1/abonnements`

```json
POST /api/v1/abonnements/souscrire   → AUDITEUR
{
  "auditeurId": 1,
  "offre": "MONTHLY",    // WEEKLY (7j) | MONTHLY (30j) | YEARLY (365j)
  "description": "...",
  "montantAbonnement": 2000
}
```

### Paiements — `/api/v1/paiements`

```json
POST /api/v1/paiements   → AUDITEUR
{
  "auditeurId": 1,
  "montant": 2000,
  "modePaiement": "FLOOZ",   // FLOOZ | TMONEY | WAVE
  "abonnementId": 2
}
```

### Bannières — `/api/v1/bannieres`

```
GET  /actives                  → Public (carrousel homepage)
POST /                         → ARTISTE (owner), multipart: data + image
PUT  /{id}/activer             → ARTISTE (owner) → envoie notifs push à tous les auditeurs
PUT  /{id}/desactiver          → ARTISTE (owner)
DELETE /{id}                   → ARTISTE (owner)
```

### Reversements — `/api/v1/reversements`

```
GET  /artiste/{id}             → ARTISTE (owner) : son historique
GET  /artiste/{id}/total       → ARTISTE (owner) : total cumulé en FCFA
POST /calculer/mensuel         → ADMIN : calcule pour tous les artistes du mois courant
POST /calculer/artiste/{id}    → ADMIN : calcule pour un artiste + période YYYY-MM
PUT  /{id}/verser              → ADMIN : marque comme versé après virement
```

**Formule de calcul des royalties :**
```
Reversement = Revenus totaux × 70% × (chansons_artiste / total_chansons_globales)
```

### Notifications — `/api/v1/notifications`

```
GET  /auditeur/{id}            → AUDITEUR (owner)
PUT  /{id}/lire                → AUDITEUR
DELETE /{id}                   → AUDITEUR
POST /promo/artiste/{id}       → ARTISTE : notifie TOUS les auditeurs
POST /promo/auditeur/{id}      → ARTISTE : notifie un auditeur ciblé
```

### Autres

```
GET/POST/DELETE /api/v1/evenements      → Concerts / événements
GET/POST/DELETE /api/v1/telechargements → Téléchargements
GET/POST/DELETE /api/v1/categories      → Catégories musicales
GET/POST/DELETE /api/v1/labels          → Labels musicaux
```

---

## 7. Modèle de données

### Hiérarchie JPA (InheritanceType.JOINED)

```
Utilisateur (table: utilisateurs)
├── Admin    (table: admins)       + niveauAcces
├── Artiste  (table: artistes)     + artistName, bio, photoCouverture, verifie
└── Auditeur (table: auditeurs)    + photoProfil, abonnementActif

Favoris (table: favoris)
├── FavorisChanson   → Chansons
├── FavorisAlbum     → Album
├── FavorisArtiste   → Artiste
└── FavorisPlaylist  → Playlist
```

### Relations clés

```
Chansons   → Artiste (N:1), Album (N:1 nullable), Categorie (N:1)
Album      → Artiste (N:1), Chansons (1:N cascade ALL)
Playlist   → Auditeur (N:1), Chansons (N:N via playlist_chansons)
Abonnement → Auditeur (N:1)
Paiement   → Auditeur (N:1), Abonnement (N:1)
Ecoute     → Auditeur (N:1), Chansons (N:1)
Banniere   → Artiste (N:1), Album (N:1 nullable), Chansons (N:1 nullable)
Reversement → Artiste (N:1), Label (N:1 nullable)
Notification → Auditeur (N:1)
Evenement  → Artiste (N:1)
```

### Enums

| Enum            | Valeurs                                        |
|-----------------|------------------------------------------------|
| `Role`          | ROLE_AUDITEUR, ROLE_ARTISTE, ROLE_ADMIN        |
| `Statut`        | ACTIF, INACTIF, TELECHARGE, SUPPRIME           |
| `ModePaiement`  | FLOOZ, TMONEY, WAVE                            |
| `TypePromotion` | ALBUM, SINGLE, TOURNEE, GENERAL                |
| `QualiteAudio`  | LOW, MEDIUM, HIGH (déclaré, non encore utilisé)|

---

## 8. Services métier

### Services avec implémentation complète

| Service                      | Rôle principal                                             |
|------------------------------|------------------------------------------------------------|
| `AuthServiceImpl`            | Inscription (ARTISTE/AUDITEUR), login JWT, création admin  |
| `EmailServiceImpl`           | Envoi emails HTML async (vérification + reset mdp)         |
| `EmailVerificationServiceImpl` | Tokens vérif email + reset mot de passe                  |
| `ChansonServiceImpl`         | Publication audio → MinIO, streaming présigné, tendances   |
| `AlbumServiceImpl`           | CRUD albums                                                |
| `PlaylistServiceImpl`        | CRUD playlists + gestion des chansons                      |
| `FavorisServiceImpl`         | Favoris polymorphes (4 types)                              |
| `EcouteServiceImpl`          | Enregistrement + incrément atomique `nbEcoutes`            |
| `PaiementServiceImpl`        | Enregistrement paiements                                   |
| `AbonnementServiceImpl`      | Souscription avec calcul dates + désactivation anciens      |
| `MinioServiceImpl`           | Upload fichier + URL présignée (1h) avec rewrite Docker     |
| `AdminDashboardServiceImpl`  | Métriques globales + finances/royalties                    |
| `ArtisteDashboardServiceImpl`| Écoutes, auditeurs uniques, catalogue, finances estimées   |
| `BanniereServiceImpl`        | Upload bannière → MinIO + notifications push à l'activation|
| `NotificationPromoServiceImpl` | Notifications @Async vers tous les auditeurs             |
| `ReversementServiceImpl`     | Calcul mensuel prorata + marquage versement                |
| `TelechargementServiceImpl`  | Enregistrement téléchargements                             |
| `EvenementServiceImpl`       | CRUD événements/concerts                                   |
| `UserPreferencesServiceImpl` | Stub (retourne true pour tout)                             |

### Stockage MinIO — Buckets utilisés

| Bucket            | Contenu                  |
|-------------------|--------------------------|
| `chansons`        | Fichiers audio (mp3, wav)|
| `bannieres`       | Images des bannières     |
| `photos-artistes` | Photos de couverture     |

---

## 9. Fonctionnalités à compléter

### 🔴 Priorité haute — bloquant pour la production

#### 1. Réactiver la vérification email
**Fichier :** `AuthServiceImpl.java` (lignes 70, 82, 87, 121)

```java
// Actuellement (désactivé pour le développement) :
.emailVerified(true)
// emailService.sendVerificationEmail(...);  ← commenté

// À remettre en production :
.emailVerified(false)
emailService.sendVerificationEmail(user.getEmail(), user.getUsername(), verificationToken);
```

Et configurer les vraies valeurs SMTP dans `.env` (voir section 4).

#### 2. Intégrer une vraie passerelle de paiement
**Fichier :** `PaiementServiceImpl.java`

Actuellement, le statut est toujours `"SUCCES"` sans appel externe.
À intégrer avec les APIs mobiles money : **Orange Money**, **Moov Money (FLOOZ/TMONEY)**, **Wave**.

```java
// Actuel (stub) :
paiement.setStatut("SUCCES");

// À remplacer par un appel API réel :
String statut = mobileMoneyGateway.charge(request.montant(), request.telephone(), request.modePaiement());
paiement.setStatut(statut);
```

#### 3. Implémenter la blacklist des tokens JWT
Actuellement, changer le mot de passe ou suspendre un compte ne révoque pas le token JWT existant (valable 24h).

À implémenter : stocker les tokens révoqués en Redis ou en base, et vérifier dans `JwtAuthenticationFilter`.

#### 4. Implémenter le refresh token
Le token expire après 24h et l'utilisateur doit se reconnecter. À implémenter :
- Endpoint `POST /api/v1/auth/refresh`
- Table `refresh_tokens` en base
- Token de refresh valable 7 jours

---

### 🟠 Priorité moyenne — qualité et robustesse

#### 5. Ajouter la pagination sur toutes les listes
Toutes les listes retournent l'intégralité des données. À remplacer par `Pageable` :

```java
// Avant :
List<ChansonResponse> getAll();

// Après :
Page<ChansonResponse> getAll(Pageable pageable);
```

#### 6. Écrire les tests unitaires et d'intégration
**Couverture actuelle : 0%** (2 fichiers vides dans `src/test/`).

Priorités de tests :
- `AuthServiceImpl` (register, login, createAdmin)
- `ChansonServiceImpl` (publierChanson, getStreamingUrl)
- `ReversementServiceImpl` (calcul prorata)
- `SecurityUtils` (assertOwnerOrAdmin)
- Tests d'intégration sur les endpoints REST avec MockMvc

#### 7. Implémenter les préférences de notification utilisateur
**Fichier :** `UserPreferencesServiceImpl.java` — stub qui retourne `true` pour tout.

À implémenter avec une table `user_preferences` :
```sql
CREATE TABLE user_preferences (
  id BIGINT PRIMARY KEY,
  user_id BIGINT REFERENCES utilisateurs(id),
  category VARCHAR(50),  -- SUBSCRIPTION, PROMOTION, SYSTEM
  enabled BOOLEAN DEFAULT TRUE
);
```

#### 8. Relier Label aux Artistes
L'entité `Label` existe mais n'est liée à aucune autre entité.

```java
// Dans Artiste.java, ajouter :
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "label_id")
private Label label;
```

#### 9. Implémenter les statistiques réelles
**Fichier :** `StatistiquesService.java` — certaines valeurs sont estimées.

`AdminDashboardServiceImpl.getFinancesAndRoyalty()` calcule les royalties depuis `paiementRepository.findAll()` sans filtrer par période. À améliorer avec des requêtes JPQL filtrées.

---

### 🟡 Priorité basse — améliorations futures

#### 10. Cache Redis pour les tendances et les stats
Les requêtes `getTopTendances()` et `getMetricsGlobales()` sont coûteuses. À mettre en cache avec `@Cacheable` et Redis.

#### 11. Qualité audio adaptative
L'enum `QualiteAudio` (LOW, MEDIUM, HIGH) est déclaré mais jamais utilisé. À implémenter pour encoder les fichiers en plusieurs qualités selon le type d'abonnement.

#### 12. Notification email lors d'un reversement
Quand un reversement est marqué comme versé (`PUT /{id}/verser`), envoyer un email à l'artiste.

#### 13. Exposer Swagger uniquement en dev/staging
Actuellement, Swagger est accessible en production. À conditionner :

```yaml
springdoc:
  api-docs:
    enabled: ${SWAGGER_ENABLED:false}
```

#### 14. Chiffrer les données sensibles
`mobileMoneyRef` dans `Abonnement` et `Paiement` contient des références mobiles en clair.
À chiffrer avec un attribut converter JPA.

---

## 10. Points d'amélioration technique

### Architecture

| Point                          | Situation actuelle                    | Recommandation                          |
|-------------------------------|---------------------------------------|-----------------------------------------|
| `UtilisateurService`           | Classe morte, doublon de AuthService  | Supprimer                               |
| `StatistiquesService`          | `@Service` concret sans interface     | Transformer en interface + impl         |
| `MinioStorageService`          | Doublon partiel de MinioServiceImpl   | Fusionner ou clarifier les responsabilités |
| Controllers sans service layer | AbonnementController, NotificationController injectent le repo directement | Ajouter une couche service |

### Performances

| Point                 | Recommandation                                                         |
|-----------------------|------------------------------------------------------------------------|
| `findAll()` partout   | Ajouter `Pageable` + `@PageableDefault`                                |
| Lazy loading N+1      | Ajouter `@EntityGraph` sur les requêtes qui chargent des associations  |
| Requêtes finances     | Remplacer `paiementRepository.findAll()` par des agrégats JPQL/SQL     |
| Chargement tenant     | `UserDetailsServiceImpl.loadUserByUsername` → requête BDD à chaque requête → ajouter cache |

### Sécurité production

| Point                              | Action requise                                          |
|------------------------------------|----------------------------------------------------------|
| Clé JWT hardcodée en fallback      | Forcer `JWT_SECRET` obligatoire, supprimer la valeur par défaut |
| Mot de passe admin dans `DataSeeder` | Lire depuis variable d'env `ADMIN_PASSWORD`             |
| Idempotence admin `createAdmin()`  | Un seul admin autorisé — revoir si multi-admin nécessaire |
| CORS en production                 | Remplacer `localhost:3000` par les vraies origines        |

---

## 11. Données de test

Le `DataSeeder` peuple automatiquement la base au premier démarrage :

### Comptes disponibles

| Rôle     | Email                       | Mot de passe    | Notes                 |
|----------|-----------------------------|------------------|-----------------------|
| ADMIN    | admin@titan-tune.com        | Admin@2026!      | Super admin           |
| ARTISTE  | kofi.mensah@music.tg        | Artiste@2026!    | Afrobeat, vérifié     |
| ARTISTE  | nana.adjoa@music.tg         | Artiste@2026!    | R&B, vérifiée         |
| ARTISTE  | togoman.rap@music.tg        | Artiste@2026!    | Rap, non vérifié      |
| ARTISTE  | grace.amavi@music.tg        | Artiste@2026!    | Gospel, vérifiée      |
| ARTISTE  | dj.savane@music.tg          | Artiste@2026!    | Coupé-Décalé, vérifié |
| AUDITEUR | amina.koffi@email.tg        | Auditeur@2026!   | Abonnement actif      |
| AUDITEUR | yao.mensah@email.tg         | Auditeur@2026!   | Abonnement actif      |
| AUDITEUR | esi.adjoa@email.tg          | Auditeur@2026!   | Abonnement expiré     |
| AUDITEUR | kwame.dossou@email.tg       | Auditeur@2026!   | Abonnement actif      |
| AUDITEUR | akua.boko@email.tg          | Auditeur@2026!   | Sans abonnement       |
| AUDITEUR | tobi.fiagan@email.tg        | Auditeur@2026!   | Abonnement actif      |

### Données pré-chargées

- 7 catégories musicales
- 3 labels
- 4 albums
- 15 chansons avec compteurs d'écoutes réalistes
- 5 abonnements (WEEKLY/MONTHLY/YEARLY) avec paiements FLOOZ/TMONEY/WAVE
- 5 événements/concerts (4 futurs, 1 passé)
- 9 notifications

---

## 12. Conventions de code

### DTOs

- **Request** : Java records avec annotations Bean Validation (`@NotBlank`, `@Email`, `@Size`)
- **Response** : Java records avec méthode statique `fromEntity(Entity)` pour le mapping

```java
// Exemple
public record ChansonResponse(Long id, String titre, ...) {
    public static ChansonResponse fromEntity(Chansons c) {
        return new ChansonResponse(c.getId(), c.getTitre(), ...);
    }
}
```

### Réponses HTTP

Toujours utiliser `ApiResponse<T>` :

```java
// Succès
return ResponseEntity.ok(ApiResponse.success("Message.", data));
return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Créé.", data));

// Erreur (via GlobalExceptionHandler automatiquement)
throw new ResourceNotFoundException("Chanson non trouvée id: " + id);
throw new BusinessException("Message d'erreur.", HttpStatus.FORBIDDEN);
```

### Ownership

Toujours appeler `securityUtils.assertOwnerOrAdmin(ownerId)` avant toute mutation :

```java
@PutMapping("/{id}")
@PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
public ResponseEntity<...> update(@PathVariable Long id, ...) {
    securityUtils.assertOwnerOrAdmin(id); // ← toujours en premier
    // ... logique métier
}
```

### Transactions

- `@Transactional` sur les méthodes de service qui écrivent
- `@Transactional(readOnly = true)` sur les méthodes qui lisent seulement
- Ne pas mettre `@Transactional` sur les controllers

### Async

Les opérations non bloquantes (emails, notifications) utilisent `@Async`.
Nécessite `@EnableAsync` sur `TitanTuneApplication` (déjà présent).

```java
@Async
public void sendVerificationEmail(String to, ...) { ... }
```

### Logging

Utiliser Lombok `@Slf4j` et non `System.out.println` :

```java
@Slf4j
public class MonService {
    // Bon :
    log.info("Chanson créée : {}", chanson.getId());
    log.warn("Token expiré pour {}", email);
    log.error("Erreur MinIO : {}", e.getMessage());

    // Mauvais :
    System.out.println("...");
    System.err.println("...");
}
```

---

*Document généré le 13 août 2026 — Titan Tunes v0.0.1-SNAPSHOT*
