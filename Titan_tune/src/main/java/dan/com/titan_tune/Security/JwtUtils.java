package dan.com.titan_tune.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.Date;
import java.util.HexFormat;

@Slf4j
@Component
public class JwtUtils {

    @Value("${jwt.secret:change-me-please-very-long-secret-key-for-titan-tune}")
    private String jwtSecretValue;

    @Value("${jwt.expiration:86400000}")
    private int jwtExpirationMs;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecretValue.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * Génère un token JWT à partir d'un objet Authentication.
     */
    public String generateJwtToken(Authentication authentication) {
        UserDetails userPrincipal = (UserDetails) authentication.getPrincipal();
        return generateTokenFromUsername(userPrincipal.getUsername());
    }

    /**
     * Génère un token JWT directement depuis l'identifiant (email ou username).
     */
    public String generateTokenFromUsername(String username) {
        return Jwts.builder()
                .subject(username)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
                .signWith(getSigningKey())
                .compact();
    }

    /** Extrait l'email (subject) depuis le token. */
    public String getUserNameFromJwtToken(String token) {
        return parseClaims(token).getSubject();
    }

    /** Extrait la date d'expiration (Instant) depuis le token. */
    public Instant getExpirationInstantFromJwtToken(String token) {
        try {
            Date exp = parseClaims(token).getExpiration();
            return exp.toInstant();
        } catch (Exception e) {
            return Instant.now().plusMillis(jwtExpirationMs);
        }
    }

    /** Valide le token et retourne true si valide et non expiré. */
    public boolean validateJwtToken(String authToken) {
        try {
            parseClaims(authToken);
            return true;
        } catch (ExpiredJwtException e) {
            log.warn("Token JWT expiré : {}", e.getMessage());
        } catch (JwtException e) {
            log.warn("Token JWT invalide : {}", e.getMessage());
        }
        return false;
    }

    /** Calcule l'empreinte SHA-256 d'un token pour stockage sécurisé et compact en base. */
    public static String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Erreur calcul SHA-256", e);
        }
    }

    // ── Privé ──────────────────────────────────────────────────────────────────

    private Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
