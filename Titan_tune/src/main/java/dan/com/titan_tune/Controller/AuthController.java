package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.EmailRequest;
import dan.com.titan_tune.dtos.dtorequest.LoginRequest;
import dan.com.titan_tune.dtos.dtorequest.OAuth2Request;
import dan.com.titan_tune.dtos.dtorequest.PasswordResetRequest;
import dan.com.titan_tune.dtos.dtorequest.RefreshTokenRequest;
import dan.com.titan_tune.dtos.dtorequest.RegisterRequest;
import dan.com.titan_tune.dtos.dtoresponse.AccountRecoveryResponse;
import dan.com.titan_tune.dtos.dtoresponse.AuthResponse;
import dan.com.titan_tune.dtos.dtoresponse.TokenRefreshResponse;
import dan.com.titan_tune.dtos.dtoresponse.UserProfileResponse;
import dan.com.titan_tune.entities.Abonnement;
import dan.com.titan_tune.entities.Artiste;
import dan.com.titan_tune.entities.Auditeur;
import dan.com.titan_tune.entities.Utilisateur;
import dan.com.titan_tune.enums.Role;
import dan.com.titan_tune.repository.AbonnementRepository;
import dan.com.titan_tune.repository.FavorisRepository;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.AuthService;
import dan.com.titan_tune.service.EmailVerificationService;
import dan.com.titan_tune.service.OAuth2Service;
import dan.com.titan_tune.service.RefreshTokenService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/auth", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class AuthController {

    private final AuthService              authService;
    private final EmailVerificationService emailVerificationService;
    private final OAuth2Service            oauth2Service;
    private final RefreshTokenService      refreshTokenService;
    private final SecurityUtils            securityUtils;
    private final AbonnementRepository     abonnementRepository;
    private final FavorisRepository        favorisRepository;

    /**
     * Inscription publique — ARTISTE et AUDITEUR uniquement.
     * Toute tentative avec ROLE_ADMIN est rejetée par le service.
     */
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AccountRecoveryResponse>> register(
            @Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Inscription réussie.", authService.register(request)));
    }

    /**
     * Création d'un compte admin — réservée aux admins authentifiés.
     * Retourne 403 si l'appelant n'est pas ROLE_ADMIN.
     * Retourne 400 si un admin existe déjà en base.
     */
    @PostMapping("/admin/create")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<AccountRecoveryResponse>> createAdmin(
            @Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Compte administrateur créé.", authService.createAdmin(request)));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Connexion réussie.", authService.login(request)));
    }

    /**
     * Retourne le profil complet de l'utilisateur authentifié.
     * Inclut les infos d'abonnement et le nombre de favoris.
     */
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserProfileResponse>> getCurrentUserProfile() {
        Utilisateur user = securityUtils.getCurrentUser();

        Boolean abonnementActif = null;
        LocalDateTime abonnementExpiry = null;
        if (user.getRole() == Role.ROLE_AUDITEUR && user instanceof Auditeur auditeur) {
            List<Abonnement> abonnements = abonnementRepository.findByAuditeurAndActiveTrue(auditeur);
            if (!abonnements.isEmpty()) {
                Abonnement dernier = abonnements.get(abonnements.size() - 1);
                abonnementActif = dernier.isActive() && dernier.getEndDate().isAfter(LocalDateTime.now());
                abonnementExpiry = dernier.getEndDate();
            } else {
                abonnementActif = false;
            }
        }

        int nbFavoris = favorisRepository.findByUtilisateurId(user.getId()).size();

        return ResponseEntity.ok(ApiResponse.success(
                "Profil récupéré avec succès.",
                UserProfileResponse.fromEntity(user, abonnementActif, abonnementExpiry, nbFavoris)
        ));
    }

    /**
     * Renouvelle l'access token à partir d'un refresh token valide (rotation de token).
     */
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<TokenRefreshResponse>> refreshToken(
            @Valid @RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                "Token renouvelé avec succès.",
                refreshTokenService.refreshToken(request)
        ));
    }

    /**
     * Déconnexion sécurisée : révoque l'access token courant (blacklist) et le refresh token de l'utilisateur.
     */
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        Long currentUserId = null;
        try {
            currentUserId = securityUtils.getCurrentUserId();
        } catch (Exception ignored) {
            // Utilisateur déjà non authentifié ou token expiré
        }
        authService.logout(authHeader, currentUserId);
        return ResponseEntity.ok(ApiResponse.success("Déconnexion réussie.", null));
    }

    /**
     * Connexion / inscription via OAuth2 Google ou Facebook.
     */
    @PostMapping("/oauth2/callback")
    public ResponseEntity<ApiResponse<AuthResponse>> oauth2Callback(
            @Valid @RequestBody OAuth2Request request) {
        return ResponseEntity.ok(ApiResponse.success(
                "Connexion OAuth2 réussie.", oauth2Service.loginOrRegister(request)));
    }

    @GetMapping("/verify")
    public ResponseEntity<ApiResponse<AccountRecoveryResponse>> verifyEmail(
            @RequestParam("token") String token) {
        return ResponseEntity.ok(ApiResponse.success("Email vérifié avec succès.",
                emailVerificationService.verifyEmail(token)));
    }

    @PostMapping("/verify-request")
    public ResponseEntity<ApiResponse<AccountRecoveryResponse>> requestEmailVerification(
            @Valid @RequestBody EmailRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Email de vérification envoyé.",
                emailVerificationService.requestEmailVerification(request.email())));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<AccountRecoveryResponse>> forgotPassword(
            @Valid @RequestBody EmailRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Email de réinitialisation envoyé.",
                emailVerificationService.requestPasswordReset(request)));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<AccountRecoveryResponse>> resetPassword(
            @Valid @RequestBody PasswordResetRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Mot de passe réinitialisé avec succès.",
                emailVerificationService.resetPassword(request)));
    }
}
