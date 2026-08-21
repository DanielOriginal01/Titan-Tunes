package dan.com.titan_tune.security;

import dan.com.titan_tune.entities.RevokedToken;
import dan.com.titan_tune.repository.RevokedTokenRepository;
import dan.com.titan_tune.service.impl.TokenBlacklistServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.Instant;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TokenBlacklistServiceTest {

    @Mock
    private RevokedTokenRepository revokedTokenRepository;

    private JwtUtils jwtUtils;

    private TokenBlacklistServiceImpl tokenBlacklistService;

    @BeforeEach
    void setUp() {
        jwtUtils = new JwtUtils();
        ReflectionTestUtils.setField(jwtUtils, "jwtSecretValue", "change-me-please-very-long-secret-key-for-titan-tune");
        ReflectionTestUtils.setField(jwtUtils, "jwtExpirationMs", 3600000);

        tokenBlacklistService = new TokenBlacklistServiceImpl(revokedTokenRepository, jwtUtils);
    }

    @Test
    @DisplayName("blacklistToken doit hacher le token et le sauvegarder dans la base")
    void testBlacklistToken() {
        String token = jwtUtils.generateTokenFromUsername("test@email.tg");

        when(revokedTokenRepository.existsByTokenHash(any())).thenReturn(false);

        tokenBlacklistService.blacklistToken(token, "LOGOUT");

        ArgumentCaptor<RevokedToken> captor = ArgumentCaptor.forClass(RevokedToken.class);
        verify(revokedTokenRepository).save(captor.capture());

        RevokedToken saved = captor.getValue();
        assertThat(saved.getTokenHash()).isEqualTo(JwtUtils.hashToken(token));
        assertThat(saved.getExpiryDate()).isAfter(Instant.now());
        assertThat(saved.getReason()).isEqualTo("LOGOUT");
    }

    @Test
    @DisplayName("isTokenBlacklisted doit retourner true si le hash existe")
    void testIsTokenBlacklistedTrue() {
        String rawToken = "sample.token";
        String hash = JwtUtils.hashToken(rawToken);

        when(revokedTokenRepository.existsByTokenHash(hash)).thenReturn(true);

        boolean result = tokenBlacklistService.isTokenBlacklisted(rawToken);

        assertThat(result).isTrue();
    }

    @Test
    @DisplayName("isTokenBlacklisted doit retourner false si le token n'est pas dans la blacklist")
    void testIsTokenBlacklistedFalse() {
        String rawToken = "valid.token";
        String hash = JwtUtils.hashToken(rawToken);

        when(revokedTokenRepository.existsByTokenHash(hash)).thenReturn(false);

        boolean result = tokenBlacklistService.isTokenBlacklisted(rawToken);

        assertThat(result).isFalse();
    }

    @Test
    @DisplayName("cleanExpiredTokens doit purger les tokens dont l'expiration est passée")
    void testCleanExpiredTokens() {
        tokenBlacklistService.cleanExpiredTokens();

        verify(revokedTokenRepository).deleteByExpiryDateBefore(any(Instant.class));
    }
}
