package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.RefreshTokenRequest;
import dan.com.titan_tune.dtos.dtoresponse.TokenRefreshResponse;
import dan.com.titan_tune.entities.RefreshToken;
import dan.com.titan_tune.entities.Utilisateur;
import dan.com.titan_tune.enums.Statut;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.RefreshTokenRepository;
import dan.com.titan_tune.repository.UtilisateurRepository;
import dan.com.titan_tune.security.JwtUtils;
import dan.com.titan_tune.service.RefreshTokenService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class RefreshTokenServiceImpl implements RefreshTokenService {

    @Value("${jwt.refresh-expiration:604800000}") // 7 jours par défaut (en ms)
    private Long refreshTokenDurationMs;

    private final RefreshTokenRepository refreshTokenRepository;
    private final UtilisateurRepository  utilisateurRepository;
    private final JwtUtils               jwtUtils;

    @Override
    @Transactional
    public RefreshToken createRefreshToken(Long userId) {
        Utilisateur user = utilisateurRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur non trouvé id: " + userId));

        // Supprimer l'ancien refresh token s'il existe (1 seul refresh token actif par utilisateur)
        refreshTokenRepository.deleteByUtilisateur(user);
        refreshTokenRepository.flush();

        RefreshToken refreshToken = RefreshToken.builder()
                .utilisateur(user)
                .token(UUID.randomUUID().toString())
                .expiryDate(Instant.now().plusMillis(refreshTokenDurationMs))
                .revoked(false)
                .createdAt(Instant.now())
                .build();

        return refreshTokenRepository.save(refreshToken);
    }

    @Override
    public RefreshToken verifyExpiration(RefreshToken token) {
        if (token.isRevoked()) {
            refreshTokenRepository.delete(token);
            throw new BusinessException(
                    "Ce refresh token a été révoqué. Veuillez vous reconnecter.",
                    HttpStatus.UNAUTHORIZED
            );
        }

        if (token.getExpiryDate().isBefore(Instant.now())) {
            refreshTokenRepository.delete(token);
            throw new BusinessException(
                    "Le refresh token a expiré. Veuillez vous reconnecter.",
                    HttpStatus.UNAUTHORIZED
            );
        }

        return token;
    }

    @Override
    @Transactional
    public TokenRefreshResponse refreshToken(RefreshTokenRequest request) {
        String requestToken = request.refreshToken();

        RefreshToken refreshToken = refreshTokenRepository.findByToken(requestToken)
                .orElseThrow(() -> new BusinessException(
                        "Refresh token invalide ou inexistant.",
                        HttpStatus.UNAUTHORIZED
                ));

        verifyExpiration(refreshToken);

        Utilisateur user = refreshToken.getUtilisateur();

        if (user.getStatus() != Statut.ACTIF) {
            refreshTokenRepository.delete(refreshToken);
            throw new BusinessException(
                    "Le compte utilisateur est suspendu ou inactif.",
                    HttpStatus.FORBIDDEN
            );
        }

        // Rotation du refresh token : générer un nouveau token et mettre à jour la date d'expiration
        String newRefreshTokenString = UUID.randomUUID().toString();
        refreshToken.setToken(newRefreshTokenString);
        refreshToken.setExpiryDate(Instant.now().plusMillis(refreshTokenDurationMs));
        refreshTokenRepository.save(refreshToken);

        // Générer le nouvel access token
        String newAccessToken = jwtUtils.generateTokenFromUsername(user.getEmail());

        log.info("[RefreshToken] Tokens renouvelés avec succès pour l'utilisateur id={}", user.getId());
        return new TokenRefreshResponse(newAccessToken, newRefreshTokenString);
    }

    @Override
    @Transactional
    public void revokeByUserId(Long userId) {
        refreshTokenRepository.deleteByUtilisateurId(userId);
        log.info("[RefreshToken] Refresh token révoqué pour l'utilisateur id={}", userId);
    }

    @Override
    @Scheduled(cron = "0 0 * * * *") // Toutes les heures
    @Transactional
    public void cleanExpiredTokens() {
        log.info("[RefreshToken] Nettoyage des refresh tokens expirés...");
        refreshTokenRepository.deleteByExpiryDateBefore(Instant.now());
    }
}
