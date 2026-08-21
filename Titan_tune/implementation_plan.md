# Implémentation : Sécurité des Tokens (Refresh & Blacklist) & Pagination Standardisée

Ce document détaille le plan technique pour réaliser les deux chantiers prioritaires identifiés pour l'API REST **Titan Tunes** :
1. **Point 3 — Sécurité des Tokens** : Ajout du Refresh Token (rotation, expiration 7 jours), Blacklist de révocation de tokens (déconnexion, suspension de compte, changement de mot de passe) et vérification dans le filtre d'authentification.
2. **Point 4 — Pagination Standardisée** : Généralisation de `Pageable` Spring Data et d'un conteneur générique `PageResponse<T>` sur l'ensemble des endpoints de listes volumineuses.

---

## User Review Required

> [!IMPORTANT]
> - **Format des réponses de liste** : Les endpoints de listing (`/chansons`, `/artistes`, `/admin/utilisateurs`, `/ecoutes/historique/{id}`, etc.) encapsuleront désormais les résultats dans un DTO `PageResponse<T>` au lieu d'une simple `List<T>`. Les clients front-end pourront envoyer les paramètres de pagination standard `?page=0&size=20&sort=id,desc`.
> - **Rétrocompatibilité DTO d'authentification** : `AuthResponse` contiendra désormais le champ `refreshToken` en plus du `token` (access token).

---

## Proposed Changes

### 1. Module Sécurité des Tokens (Point 3)

#### [NEW] [RefreshToken.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/entities/RefreshToken.java)
- Entité JPA représentant un refresh token :
  - `id` (Long)
  - `token` (UUID / token unique indexé)
  - `expiryDate` (Instant, par défaut 7 jours)
  - `revoked` (boolean)
  - `utilisateur` (relation `@ManyToOne` / `@OneToOne` avec `Utilisateur`)

#### [NEW] [RevokedToken.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/entities/RevokedToken.java)
- Entité JPA pour la blacklist des tokens révoqués (access tokens invalidés avant leur expiration naturelle lors d'une déconnexion, suspension de compte ou changement de mot de passe) :
  - `id` (Long)
  - `tokenHash` (SHA-256 du token ou token JWT)
  - `expiryDate` (Instant de fin de validité)
  - `revokedAt` (Instant de révocation)
  - `reason` (String: "LOGOUT", "PASSWORD_RESET", "ACCOUNT_DEACTIVATED")

#### [NEW] [RefreshTokenRepository.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/repository/RefreshTokenRepository.java)
- Méthodes de recherche et suppression :
  - `Optional<RefreshToken> findByToken(String token)`
  - `Optional<RefreshToken> findByUtilisateur(Utilisateur utilisateur)`
  - `void deleteByUtilisateur(Utilisateur utilisateur)`
  - `void deleteByExpiryDateBefore(Instant now)`

#### [NEW] [RevokedTokenRepository.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/repository/RevokedTokenRepository.java)
- Méthodes pour vérifier et purger les tokens révoqués expirés :
  - `boolean existsByTokenHash(String tokenHash)`
  - `void deleteByExpiryDateBefore(Instant now)`

#### [NEW] [RefreshTokenRequest.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/dtos/dtorequest/RefreshTokenRequest.java)
- Record de requête : `public record RefreshTokenRequest(@NotBlank String refreshToken) {}`

#### [NEW] [TokenRefreshResponse.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/dtos/dtoresponse/TokenRefreshResponse.java)
- Record de réponse : `public record TokenRefreshResponse(String accessToken, String refreshToken, String tokenType) {}`

#### [NEW] [RefreshTokenService.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/RefreshTokenService.java) & [RefreshTokenServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/RefreshTokenServiceImpl.java)
- Logique métier du cycle de vie du Refresh Token :
  - `createRefreshToken(Long userId)`
  - `verifyExpiration(RefreshToken token)`
  - `refreshToken(RefreshTokenRequest request)` : rotation de refresh token (invalidation de l'ancien, émission d'un nouveau couple Access/Refresh token)
  - `revokeByUser(Utilisateur user)`

#### [NEW] [TokenBlacklistService.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/TokenBlacklistService.java) & [TokenBlacklistServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/TokenBlacklistServiceImpl.java)
- Service de gestion de la blacklist :
  - `blacklistToken(String rawToken, String reason)`
  - `isTokenBlacklisted(String rawToken)`
  - `cleanExpiredTokens()` (tâche planifiée `@Scheduled(cron = "0 0 * * * *")`)

#### [MODIFY] [AuthResponse.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/dtos/dtoresponse/AuthResponse.java)
- Ajout du champ `refreshToken` dans le record de réponse d'authentification.

#### [MODIFY] [JwtUtils.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/security/JwtUtils.java)
- Ajout de méthodes pour extraire l'expiration `getExpirationDateFromJwtToken(String token)` et générer un token à partir d'un nom d'utilisateur/email directement.

#### [MODIFY] [JwtAuthenticationFilter.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/security/JwtAuthenticationFilter.java)
- Intégration de la vérification `tokenBlacklistService.isTokenBlacklisted(jwt)` : si le token est dans la blacklist, la requête est rejetée (non authentifiée).

#### [MODIFY] [AuthService.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/AuthService.java) & [AuthServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/AuthServiceImpl.java)
- Génération d'un `RefreshToken` lors de `login()` et intégration de la méthode `logout(String bearerToken, Long userId)`.

#### [MODIFY] [OAuth2ServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/OAuth2ServiceImpl.java)
- Émission du `refreshToken` lors de la connexion OAuth2 Google/Facebook.

#### [MODIFY] [AuthController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/AuthController.java)
- Ajout des routes :
  - `POST /api/v1/auth/refresh` : Renouvellement de l'access token avec rotation
  - `POST /api/v1/auth/logout` : Déconnexion avec mise en blacklist du token actuel et révocation du refresh token

#### [MODIFY] [AdminController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/AdminController.java) & [EmailVerificationServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/EmailVerificationServiceImpl.java)
- Révocation automatique des tokens lors du passage d'un compte à `INACTIF`/`SUPPRIME` ou lors de la réinitialisation du mot de passe.

#### [MODIFY] [application.yml](file:///d:/Titan-tunes/Titan_tune/src/main/resources/application.yml)
- Paramétrage de `jwt.refresh-expiration` (ex: 604800000 ms = 7 jours) et `jwt.expiration` (3600000 ms = 1 heure).

---

### 2. Module Pagination Standardisée (Point 4)

#### [NEW] [PageResponse.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/dtos/dtoresponse/PageResponse.java)
- Record/Classe générique représentant une page de résultats avec métadonnées :
  ```java
  public record PageResponse<T>(
      List<T> content,
      int page,
      int size,
      long totalElements,
      int totalPages,
      boolean first,
      boolean last,
      boolean empty
  ) {
      public static <T> PageResponse<T> from(Page<T> page) { ... }
      public static <T, R> PageResponse<R> from(Page<T> page, Function<T, R> mapper) { ... }
  }
  ```

#### [MODIFY] Repositories Spring Data
Mise à jour des méthodes des repositories pour supporter `Pageable` :
- [ChansonRepository.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/repository/ChansonRepository.java) : `searchByTitreOrArtiste(String q, Pageable p)`, `findAllByOrderByNbEcoutesDesc(Pageable p)`, `findByCategorieId(Long id, Pageable p)`, `findByArtisteId(Long id, Pageable p)`
- [ArtisteRepository.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/repository/ArtisteRepository.java) : `findByVerifieFalse(Pageable p)`, `findByArtistNameContainingIgnoreCaseOrUsernameContainingIgnoreCase(String name, String username, Pageable p)`
- [AuditeurRepository.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/repository/AuditeurRepository.java) : support de `Pageable`
- [AlbumRepository.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/repository/AlbumRepository.java) : `findByArtisteId(Long id, Pageable p)`
- [PlaylistRepository.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/repository/PlaylistRepository.java) : `findByAuditeurId(Long id, Pageable p)`, `findByPriveeFalse(Pageable p)`
- [EcouteRepository.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/repository/EcouteRepository.java) : `findByAuditeurId(Long id, Pageable p)`
- [NotificationRepository.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/repository/NotificationRepository.java) : `findByAuditeurId(Long id, Pageable p)`, `findByLuFalse(Pageable p)`
- [PaiementRepository.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/repository/PaiementRepository.java) : `findByAuditeurId(Long id, Pageable p)`
- [ReversementRepository.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/repository/ReversementRepository.java) : `findByArtisteId(Long id, Pageable p)`
- [EvenementRepository.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/repository/EvenementRepository.java) : support de `Pageable`

#### [MODIFY] Services & Controllers
Mise à jour des signatures de méthodes pour accepter `Pageable` et retourner `PageResponse<DTO>` :
- [ChansonController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/ChansonController.java) & [ChansonServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/ChansonServiceImpl.java)
- [AdminController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/AdminController.java) & [AdminDashboardServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/AdminDashboardServiceImpl.java)
- [ArtisteController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/ArtisteController.java)
- [AuditeurController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/AuditeurController.java)
- [AlbumController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/AlbumController.java) & [AlbumServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/AlbumServiceImpl.java)
- [PlaylistController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/PlaylistController.java) & [PlaylistServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/PlaylistServiceImpl.java)
- [EcouteController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/EcouteController.java) & [EcouteServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/EcouteServiceImpl.java)
- [NotificationController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/NotificationController.java)
- [PaiementController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/PaiementController.java) & [PaiementServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/PaiementServiceImpl.java)
- [ReversementController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/ReversementController.java) & [ReversementServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/ReversementServiceImpl.java)
- [EvenementController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/EvenementController.java) & [EvenementServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/EvenementServiceImpl.java)

---

## Verification Plan

### Automated Tests
1. **Tests unitaires et d'intégration Spring Boot** :
   - [NEW] `RefreshTokenServiceTest.java` : Test de génération de refresh token, rotation, expiration et révocation.
   - [NEW] `TokenBlacklistServiceTest.java` : Test de mise en blacklist, vérification dans le filtre et purge.
   - [NEW] `PaginationIntegrationTest.java` : Test des endpoints paginés (`/chansons?page=0&size=5`, `/admin/utilisateurs?page=0&size=10`, etc.).
2. **Compilation et exécution de la suite de tests** :
   ```powershell
   .\mvnw.cmd clean test
   ```

### Manual Verification
1. Effectuer une requête `POST /api/v1/auth/login` et vérifier la présence de `token` et `refreshToken`.
2. Tester `POST /api/v1/auth/refresh` avec le refresh token reçu et constater l'obtention d'un nouveau token.
3. Tester `POST /api/v1/auth/logout`, puis tenter d'utiliser l'ancien access token pour accéder à une route protégée (ex: `/api/v1/chansons/1/stream`) -> doit renvoyer `401 Unauthorized`.
4. Tester `GET /api/v1/chansons?page=0&size=3` et vérifier la structure de réponse `PageResponse` (contenu restreint à 3 éléments, nombre de pages calculé correctement).
