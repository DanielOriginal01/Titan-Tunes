package dan.com.titan_tune.dtos.dtorequest;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * Requête envoyée par le frontend après qu'il a obtenu le token OAuth2
 * depuis Google.
 *
 * Flux :
 *   1. Frontend redirige l'utilisateur vers Google
 *   2. Google retourne un accessToken au frontend
 *   3. Frontend envoie cet accessToken + le provider à ce endpoint
 *   4. Backend vérifie le token auprès de Google
 *   5. Backend crée/récupère le compte et retourne un JWT Titan Tunes
 */
public record OAuth2Request(

        /**
         * Token d'accès obtenu depuis le provider OAuth2.
         * Pour Google : le "id_token" (JWT Google) ou "access_token".
         */
        @NotBlank(message = "Le token OAuth2 est obligatoire")
        String accessToken,

        /**
         * Fournisseur d'identité : "google" (insensible à la casse).
         */
        @NotBlank(message = "Le provider est obligatoire")
        String provider,

        /**
         * Rôle souhaité lors de la première inscription via OAuth2.
         * Ignoré si le compte existe déjà.
         * Valeurs : "ROLE_AUDITEUR" (défaut) ou "ROLE_ARTISTE".
         */
        String role
) {}
