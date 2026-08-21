
# Directives pour Titan_tune (Java 21 & Spring Boot 3.2)

## Règles de code

- Stack : Java 21, Spring Boot 3.2, PostgreSQL, MinIO, Docker.
- DTOs : Utilise EXCLUSIVEMENT des `record` Java 21 immuables (pas de classes DTO avec Lombok).
- Flow : Utilise des guard clauses (retours anticipés) pour éviter les `if/else` imbriqués.
- Java 21 : Utilise le Pattern Matching (`switch`), les Sequenced Collections (`getFirst()`, `getLast()`) et `var`.
- Exceptions : Ne génère pas de blocs `try/catch` génériques ; laisse remonter vers `@RestControllerAdvice`.
- Commentaires : Supprime tout commentaire évident (ex: "// Constructeur"). Conserve uniquement les notes techniques complexes (ex: Presigned URLs MinIO, callbacks Mobile Money).
