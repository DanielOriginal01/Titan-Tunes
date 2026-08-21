package dan.com.titan_tune.service;

public interface TokenBlacklistService {

    /**
     * Ajoute un access token JWT à la liste noire (révocation immédiate).
     *
     * @param token  le token JWT brut
     * @param reason le motif de la révocation (ex: "LOGOUT", "PASSWORD_RESET", "ACCOUNT_DEACTIVATED")
     */
    void blacklistToken(String token, String reason);

    /**
     * Vérifie si un token JWT est révoqué.
     *
     * @param token le token JWT brut
     * @return true si le token est dans la liste noire
     */
    boolean isTokenBlacklisted(String token);

    /**
     * Purge les tokens révoqués dont la date d'expiration naturelle est passée.
     */
    void cleanExpiredTokens();
}
