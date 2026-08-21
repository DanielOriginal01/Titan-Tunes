package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.LoginRequest;
import dan.com.titan_tune.dtos.dtorequest.RegisterRequest;
import dan.com.titan_tune.dtos.dtoresponse.AccountRecoveryResponse;
import dan.com.titan_tune.dtos.dtoresponse.AuthResponse;
import dan.com.titan_tune.entities.Admin;
import dan.com.titan_tune.entities.Artiste;
import dan.com.titan_tune.entities.Auditeur;
import dan.com.titan_tune.entities.RefreshToken;
import dan.com.titan_tune.entities.Utilisateur;
import dan.com.titan_tune.enums.Role;
import dan.com.titan_tune.enums.Statut;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.repository.UtilisateurRepository;
import dan.com.titan_tune.security.JwtUtils;
import dan.com.titan_tune.service.AuthService;
import dan.com.titan_tune.service.EmailService;
import dan.com.titan_tune.service.RefreshTokenService;
import dan.com.titan_tune.service.TokenBlacklistService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;
    private final EmailService emailService;
    private final RefreshTokenService refreshTokenService;
    private final TokenBlacklistService tokenBlacklistService;

    /**
     * Inscription publique — accessible sans authentification.
     * Seuls les rôles ARTISTE et AUDITEUR sont autorisés ici.
     * Toute tentative de s'inscrire comme ADMIN est rejetée.
     */
    @Override
    @Transactional
    public AccountRecoveryResponse register(RegisterRequest request) {
        if (request.role() == Role.ROLE_ADMIN) {
            throw new BusinessException("L'inscription d'un administrateur n'est pas autorisée via cette route.");
        }

        if (utilisateurRepository.existsByEmail(request.email())) {
            throw new BusinessException("Cet email est déjà utilisé");
        }
        if (utilisateurRepository.existsByUsername(request.username())) {
            throw new BusinessException("Ce nom d'utilisateur est déjà pris");
        }

        var encodedPassword = passwordEncoder.encode(request.password());
        String verificationToken = UUID.randomUUID().toString();

        Utilisateur user;
        if (request.role() == Role.ROLE_ARTISTE) {
            user = Artiste.builder()
                    .username(request.username())
                    .email(request.email())
                    .password(encodedPassword)
                    .telephone(request.telephone())
                    .role(Role.ROLE_ARTISTE)
                    .status(Statut.ACTIF)
                    .artistName(request.artistName() != null ? request.artistName() : request.username())
                    .verifie(false)
                    .emailVerified(true)   // vérification email désactivée temporairement
                    .build();
        } else {
            // ROLE_AUDITEUR
            user = Auditeur.builder()
                    .username(request.username())
                    .email(request.email())
                    .password(encodedPassword)
                    .telephone(request.telephone())
                    .role(Role.ROLE_AUDITEUR)
                    .status(Statut.ACTIF)
                    .abonnementActif(false)
                    .emailVerified(true)   // vérification email désactivée temporairement
                    .build();
        }

        utilisateurRepository.save(user);
        // email de vérification désactivé temporairement — à réactiver en production
        // emailService.sendVerificationEmail(user.getEmail(), user.getUsername(), verificationToken);

        return new AccountRecoveryResponse("Inscription réussie.", true);
    }

    /**
     * Création d'un admin — réservée aux admins authentifiés.
     * Vérifie qu'aucun admin n'existe déjà avant de créer le nouveau compte.
     * L'appelant est responsable d'avoir le rôle ROLE_ADMIN (@PreAuthorize côté controller).
     */
    @Override
    @Transactional
    public AccountRecoveryResponse createAdmin(RegisterRequest request) {
        if (utilisateurRepository.existsByRole(Role.ROLE_ADMIN)) {
            throw new BusinessException("Un administrateur existe déjà. Un seul compte administrateur est autorisé.");
        }

        if (utilisateurRepository.existsByEmail(request.email())) {
            throw new BusinessException("Cet email est déjà utilisé");
        }
        if (utilisateurRepository.existsByUsername(request.username())) {
            throw new BusinessException("Ce nom d'utilisateur est déjà pris");
        }

        String verificationToken = UUID.randomUUID().toString();

        var admin = Admin.builder()
                .username(request.username())
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .telephone(request.telephone())
                .role(Role.ROLE_ADMIN)
                .status(Statut.ACTIF)
                .emailVerified(true)   // vérification email désactivée temporairement
                .build();
        admin.setNiveauAcces("SUPER_ADMIN");

        utilisateurRepository.save(admin);
        // emailService.sendVerificationEmail(admin.getEmail(), admin.getUsername(), verificationToken);

        return new AccountRecoveryResponse("Compte administrateur créé.", true);
    }

    @Override
    @Transactional
    public AuthResponse login(LoginRequest request) {
        var authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.emailOuUsername(), request.password())
        );

        var user = utilisateurRepository.findByEmail(request.emailOuUsername())
                .or(() -> utilisateurRepository.findByUsername(request.emailOuUsername()))
                .orElseThrow(() -> new BusinessException("Utilisateur non trouvé"));

        var token = jwtUtils.generateJwtToken(authentication);
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(user.getId());

        return new AuthResponse(token, refreshToken.getToken(), user.getId(), user.getUsername(), user.getEmail(), user.getRole(), user.getPhotoProfil());
    }

    @Override
    @Transactional
    public void logout(String bearerToken, Long currentUserId) {
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            bearerToken = bearerToken.substring(7);
        }

        if (bearerToken != null && !bearerToken.isBlank()) {
            tokenBlacklistService.blacklistToken(bearerToken, "LOGOUT");
        }

        if (currentUserId != null) {
            refreshTokenService.revokeByUserId(currentUserId);
        }

        log.info("[Auth] Déconnexion effectuée avec succès pour userId={}", currentUserId);
    }
}
