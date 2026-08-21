package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.RefreshTokenRequest;
import dan.com.titan_tune.dtos.dtoresponse.TokenRefreshResponse;
import dan.com.titan_tune.entities.RefreshToken;
import dan.com.titan_tune.entities.Utilisateur;

public interface RefreshTokenService {

    /**
     * Crée ou renouvelle le Refresh Token associé à un utilisateur.
     */
    RefreshToken createRefreshToken(Long userId);

    /**
     * Valide l'état et l'expiration du refresh token.
     */
    RefreshToken verifyExpiration(RefreshToken token);

    /**
     * Renouvelle l'Access Token et le Refresh Token (rotation de token).
     */
    TokenRefreshResponse refreshToken(RefreshTokenRequest request);

    /**
     * Révoque et supprime le refresh token d'un utilisateur.
     */
    void revokeByUserId(Long userId);

    /**
     * Supprime les tokens expirés.
     */
    void cleanExpiredTokens();
}
