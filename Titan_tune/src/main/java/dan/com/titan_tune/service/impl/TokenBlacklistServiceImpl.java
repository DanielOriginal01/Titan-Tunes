package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.entities.RevokedToken;
import dan.com.titan_tune.repository.RevokedTokenRepository;
import dan.com.titan_tune.security.JwtUtils;
import dan.com.titan_tune.service.TokenBlacklistService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Slf4j
@Service
@RequiredArgsConstructor
public class TokenBlacklistServiceImpl implements TokenBlacklistService {

    private final RevokedTokenRepository revokedTokenRepository;
    private final JwtUtils jwtUtils;

    @Override
    @Transactional
    public void blacklistToken(String token, String reason) {
        if (token == null || token.isBlank()) {
            return;
        }

        try {
            String tokenHash = JwtUtils.hashToken(token);
            if (revokedTokenRepository.existsByTokenHash(tokenHash)) {
                return;
            }

            Instant expiryDate = jwtUtils.getExpirationInstantFromJwtToken(token);

            RevokedToken revokedToken = RevokedToken.builder()
                    .tokenHash(tokenHash)
                    .expiryDate(expiryDate)
                    .revokedAt(Instant.now())
                    .reason(reason != null ? reason : "LOGOUT")
                    .build();

            revokedTokenRepository.save(revokedToken);
            log.info("[TokenBlacklist] Token JWT révoqué avec succès (motif: {})", reason);
        } catch (Exception e) {
            log.error("[TokenBlacklist] Erreur lors de la mise en blacklist du token : {}", e.getMessage());
        }
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isTokenBlacklisted(String token) {
        if (token == null || token.isBlank()) {
            return false;
        }
        try {
            String tokenHash = JwtUtils.hashToken(token);
            return revokedTokenRepository.existsByTokenHash(tokenHash);
        } catch (Exception e) {
            log.error("[TokenBlacklist] Erreur lors de la vérification du token révoqué : {}", e.getMessage());
            return false;
        }
    }

    @Override
    @Scheduled(cron = "0 0 * * * *") // Toutes les heures
    @Transactional
    public void cleanExpiredTokens() {
        log.info("[TokenBlacklist] Nettoyage des tokens révoqués expirés...");
        revokedTokenRepository.deleteByExpiryDateBefore(Instant.now());
    }
}
