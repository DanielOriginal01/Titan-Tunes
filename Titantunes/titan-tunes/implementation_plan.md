# Ajout de photo de profil pour les utilisateurs

Permettre à tous les utilisateurs (auditeurs, artistes, administrateurs) d'ajouter, modifier, consulter (URL présignée MinIO / OAuth2) et supprimer leur photo de profil.

## Changements Proposés

### 1. Entités JPA (`dan.com.titan_tune.entities`)

#### [MODIFY] [Utilisateur.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/entities/Utilisateur.java)
- Déplacer/Ajouter le champ `private String photoProfil;` sur la classe mère `Utilisateur`.
- Tous les rôles (`Auditeur`, `Artiste`, `Admin`) héritent ainsi de `photoProfil`.

#### [MODIFY] [Auditeur.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/entities/Auditeur.java)
- Nettoyer le champ redondant `photoProfil` pour hériter proprement de `Utilisateur`.

---

### 2. Stockage MinIO (`dan.com.titan_tune.service`)

#### [MODIFY] [MinioService.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/MinioService.java)
- Ajouter `void deleteFile(String objectName, String bucketName);` à l'interface.

#### [MODIFY] [MinioServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/MinioServiceImpl.java)
- Création automatique du bucket MinIO s'il n'existe pas encore (`bucketExists` / `makeBucket`).
- Implémentation de `deleteFile`.
- Gestion intelligente de `getPresignedUrl` : si le champ commence par `http://` ou `https://` (ex: photo Google/Facebook OAuth2), renvoyer directement l'URL sans passer par MinIO.

---

### 3. DTOs (`dan.com.titan_tune.dtos`)

#### [MODIFY] [UtilisateurResponse.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/dtos/dtoresponse/UtilisateurResponse.java)
- Ajouter `String photoProfil` dans le record et dans `fromEntity(Utilisateur u)`.

#### [MODIFY] [ArtisteResponse.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/dtos/dtoresponse/ArtisteResponse.java)
- Ajouter `String photoProfil` dans le record en plus de `photoCouverture`.

#### [MODIFY] [AuthResponse.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/dtos/dtoresponse/AuthResponse.java)
- Ajouter `String photoProfil` pour renvoyer la photo de profil dès la connexion / enregistrement.

---

### 4. Contrôleurs REST (`dan.com.titan_tune.controller`)

#### [MODIFY] [AuditeurController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/AuditeurController.java)
- `POST /api/v1/auditeurs/{id}/photo` (MultipartFile `photo`) : téléversement de la photo de profil dans le bucket `photos-profils`, suppression de l'ancienne photo MinIO si existante, mise à jour de l'entité.
- `GET /api/v1/auditeurs/{id}/photo/url` : récupération de l'URL présignée ou URL externe.
- `DELETE /api/v1/auditeurs/{id}/photo` : suppression de la photo de profil.

#### [MODIFY] [ArtisteController.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/controller/ArtisteController.java)
- `POST /api/v1/artistes/{id}/photo-profil` (MultipartFile `photo`) : upload de l'avatar de l'artiste (distinct de sa photo de couverture).
- `GET /api/v1/artistes/{id}/photo-profil/url` : URL présignée de l'avatar de l'artiste.
- `DELETE /api/v1/artistes/{id}/photo-profil` : suppression de l'avatar.

#### [MODIFY] [OAuth2ServiceImpl.java](file:///d:/Titan-tunes/Titan_tune/src/main/java/dan/com/titan_tune/service/impl/OAuth2ServiceImpl.java)
- Associer `info.pictureUrl()` à `photoProfil` pour tous les types d'utilisateurs lors de la connexion OAuth2 Google/Facebook.

---

### 5. Validation et Tests

#### [NEW] [AuditeurPhotoControllerTest.java](file:///d:/Titan-tunes/Titan_tune/src/test/java/dan/com/titan_tune/controller/AuditeurPhotoControllerTest.java)
- Tests unitaires et d'intégration :
  - Upload réussi d'une photo de profil (multipart).
  - Récupération de l'URL présignée.
  - Suppression de la photo de profil.
  - Vérification de sécurité (403 Forbidden si un autre utilisateur tente de modifier la photo).
  - Validation du type de fichier (rejet si fichier non-image ou vide).

## Plan de Vérification

### Tests Automatisés
- Exécuter la suite complète de tests via Maven :
  `.\mvnw.cmd test`
- Vérifier que tous les tests passent avec succès sans régressions.

### Vérification Manuelle
- Vérifier la génération des endpoints dans Swagger UI (`/swagger-ui.html`).
