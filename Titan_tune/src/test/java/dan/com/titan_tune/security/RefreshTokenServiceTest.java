package dan.com.titan_tune.security;

import dan.com.titan_tune.dtos.dtorequest.RefreshTokenRequest;
import dan.com.titan_tune.dtos.dtoresponse.TokenRefreshResponse;
import dan.com.titan_tune.entities.Auditeur;
import dan.com.titan_tune.entities.RefreshToken;
import dan.com.titan_tune.enums.Role;
import dan.com.titan_tune.enums.Statut;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.repository.RefreshTokenRepository;
import dan.com.titan_tune.repository.UtilisateurRepository;
import dan.com.titan_tune.service.impl.RefreshTokenServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class RefreshTokenServiceTest {

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @Mock
    private UtilisateurRepository utilisateurRepository;

    private JwtUtils jwtUtils;

    private RefreshTokenServiceImpl refreshTokenService;

    private Auditeur testUser;

    @BeforeEach
    void setUp() {
        jwtUtils = new JwtUtils();
        ReflectionTestUtils.setField(jwtUtils, "jwtSecretValue", "change-me-please-very-long-secret-key-for-titan-tune");
        ReflectionTestUtils.setField(jwtUtils, "jwtExpirationMs", 3600000);

        refreshTokenService = new RefreshTokenServiceImpl(refreshTokenRepository, utilisateurRepository, jwtUtils);
        ReflectionTestUtils.setField(refreshTokenService, "refreshTokenDurationMs", 604800000L); // 7 jours

        testUser = Auditeur.builder()
                .id(1L)
                .username("testauditeur")
                .email("auditeur@test.tg")
                .password("encoded_pass")
                .role(Role.ROLE_AUDITEUR)
                .status(Statut.ACTIF)
                .build();
    }

    @Test
    @DisplayName("createRefreshToken doit supprimer l'ancien token et sauvegarder un nouveau token")
    void testCreateRefreshToken() {
        when(utilisateurRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(refreshTokenRepository.save(any(RefreshToken.class))).thenAnswer(invocation -> invocation.getArgument(0));

        RefreshToken token = refreshTokenService.createRefreshToken(1L);

        assertThat(token).isNotNull();
        assertThat(token.getToken()).isNotBlank();
        assertThat(token.getUtilisateur()).isEqualTo(testUser);
        assertThat(token.getExpiryDate()).isAfter(Instant.now());

        verify(refreshTokenRepository).deleteByUtilisateur(testUser);
        verify(refreshTokenRepository).save(any(RefreshToken.class));
    }

    @Test
    @DisplayName("refreshToken doit réussir la rotation du token et générer un access token")
    void testRefreshTokenSuccess() {
        String oldTokenString = UUID.randomUUID().toString();
        RefreshToken existingToken = RefreshToken.builder()
                .id(10L)
                .token(oldTokenString)
                .utilisateur(testUser)
                .expiryDate(Instant.now().plusSeconds(3600))
                .revoked(false)
                .build();

        when(refreshTokenRepository.findByToken(oldTokenString)).thenReturn(Optional.of(existingToken));
        when(refreshTokenRepository.save(any(RefreshToken.class))).thenAnswer(invocation -> invocation.getArgument(0));

        TokenRefreshResponse response = refreshTokenService.refreshToken(new RefreshTokenRequest(oldTokenString));

        assertThat(response).isNotNull();
        assertThat(response.accessToken()).isNotBlank();
        assertThat(jwtUtils.validateJwtToken(response.accessToken())).isTrue();
        assertThat(jwtUtils.getUserNameFromJwtToken(response.accessToken())).isEqualTo(testUser.getEmail());
        assertThat(response.refreshToken()).isNotEqualTo(oldTokenString); // rotation effectuée
        assertThat(response.tokenType()).isEqualTo("Bearer");
    }

    @Test
    @DisplayName("refreshToken doit échouer si le refresh token est expiré")
    void testRefreshTokenExpired() {
        String tokenString = UUID.randomUUID().toString();
        RefreshToken expiredToken = RefreshToken.builder()
                .id(10L)
                .token(tokenString)
                .utilisateur(testUser)
                .expiryDate(Instant.now().minusSeconds(60))
                .revoked(false)
                .build();

        when(refreshTokenRepository.findByToken(tokenString)).thenReturn(Optional.of(expiredToken));

        assertThatThrownBy(() -> refreshTokenService.refreshToken(new RefreshTokenRequest(tokenString)))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("expiré");

        verify(refreshTokenRepository).delete(expiredToken);
    }

    @Test
    @DisplayName("refreshToken doit échouer si l'utilisateur est INACTIF")
    void testRefreshTokenInactiveUser() {
        testUser.setStatus(Statut.INACTIF);
        String tokenString = UUID.randomUUID().toString();
        RefreshToken validToken = RefreshToken.builder()
                .id(10L)
                .token(tokenString)
                .utilisateur(testUser)
                .expiryDate(Instant.now().plusSeconds(3600))
                .revoked(false)
                .build();

        when(refreshTokenRepository.findByToken(tokenString)).thenReturn(Optional.of(validToken));

        assertThatThrownBy(() -> refreshTokenService.refreshToken(new RefreshTokenRequest(tokenString)))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("suspendu ou inactif");

        verify(refreshTokenRepository).delete(validToken);
    }
}
