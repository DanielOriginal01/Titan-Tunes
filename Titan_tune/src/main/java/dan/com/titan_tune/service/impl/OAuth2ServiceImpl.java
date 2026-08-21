package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.OAuth2Request;
import dan.com.titan_tune.dtos.dtoresponse.AuthResponse;
import dan.com.titan_tune.entities.Auditeur;
import dan.com.titan_tune.entities.Artiste;
import dan.com.titan_tune.entities.Utilisateur;
import dan.com.titan_tune.enums.OAuthProvider;
import dan.com.titan_tune.enums.Role;
import dan.com.titan_tune.enums.Statut;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.repository.UtilisateurRepository;
import dan.com.titan_tune.security.JwtUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.util.Collections;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class OAuth2ServiceImpl implements dan.com.titan_tune.service.OAuth2Service {

    private final UtilisateurRepository utilisateurRepository;
    private final JwtUtils              jwtUtils;
    private final PasswordEncoder       passwordEncoder;
    private final dan.com.titan_tune.service.RefreshTokenService refreshTokenService;

    @Value("${oauth2.google.userinfo-url}")
    private String googleUserInfoUrl;

    // RestTemplate léger pour appels vers Google/Facebook
    private final RestTemplate restTemplate = new RestTemplate();

    // ─────────────────────────────────────────────────────────────────────────
    // Entrée principale
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    @Transactional
    public AuthResponse loginOrRegister(OAuth2Request request) {
        String provider = request.provider().trim().toUpperCase();

        OAuthProviderInfo info = switch (provider) {
            case "GOOGLE"   -> fetchGoogleUserInfo(request.accessToken());
            case "FACEBOOK" -> fetchFacebookUserInfo(request.accessToken());
            default -> throw new BusinessException(
                    "Provider OAuth2 non supporté : " + provider, HttpStatus.BAD_REQUEST);
        };

        // Récupère ou crée le compte
        Utilisateur user = utilisateurRepository.findByProviderId(info.providerId())
                .or(() -> utilisateurRepository.findByEmail(info.email()))
                .orElseGet(() -> creerCompte(info, provider, request.role()));

        // Si compte existant sans providerId (compte local déjà créé avec ce mail)
        if (user.getProviderId() == null) {
            user.setProvider(OAuthProvider.valueOf(provider));
            user.setProviderId(info.providerId());
            utilisateurRepository.save(user);
        }

        // Génère le JWT Titan Tunes
        var auth = new UsernamePasswordAuthenticationToken(
                buildPrincipal(user), null,
                Collections.singletonList(new SimpleGrantedAuthority(user.getRole().name())));

        String token = jwtUtils.generateJwtToken(auth);
        var refreshToken = refreshTokenService.createRefreshToken(user.getId());
        return new AuthResponse(token, refreshToken.getToken(), user.getId(), user.getUsername(), user.getEmail(), user.getRole(), user.getPhotoProfil());
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Vérification Google — appel à l'API userinfo
    // ─────────────────────────────────────────────────────────────────────────

    @SuppressWarnings("unchecked")
    private OAuthProviderInfo fetchGoogleUserInfo(String accessToken) {
        try {
            String url = googleUserInfoUrl + "?access_token=" + accessToken;
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);

            if (response == null || response.containsKey("error")) {
                throw new BusinessException("Token Google invalide ou expiré.", HttpStatus.UNAUTHORIZED);
            }

            String sub   = (String) response.get("sub");
            String email = (String) response.get("email");
            String name  = (String) response.get("name");
            String picture = (String) response.get("picture");

            if (sub == null || email == null) {
                throw new BusinessException("Données Google incomplètes (sub ou email manquant).", HttpStatus.UNAUTHORIZED);
            }

            log.info("OAuth2 Google : utilisateur vérifié — email={}", email);
            return new OAuthProviderInfo(sub, email, name, picture);

        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.error("Erreur lors de la vérification du token Google : {}", e.getMessage());
            throw new BusinessException("Impossible de vérifier le token Google.", HttpStatus.UNAUTHORIZED);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Vérification Facebook — appel à Graph API
    // ─────────────────────────────────────────────────────────────────────────

    @SuppressWarnings("unchecked")
    private OAuthProviderInfo fetchFacebookUserInfo(String accessToken) {
        try {
            String url = "https://graph.facebook.com/me?fields=id,name,email,picture&access_token=" + accessToken;
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);

            if (response == null || response.containsKey("error")) {
                throw new BusinessException("Token Facebook invalide ou expiré.", HttpStatus.UNAUTHORIZED);
            }

            String id    = (String) response.get("id");
            String email = (String) response.get("email");
            String name  = (String) response.get("name");

            // Facebook peut ne pas retourner l'email si l'utilisateur ne l'a pas accordé
            if (id == null) {
                throw new BusinessException("Données Facebook incomplètes (id manquant).", HttpStatus.UNAUTHORIZED);
            }
            if (email == null) {
                // Fallback : email synthétique à partir de l'ID Facebook
                email = id + "@facebook.titan-tunes.local";
                log.warn("OAuth2 Facebook : email non fourni par Facebook, fallback utilisé pour id={}", id);
            }

            // Extraction de la photo de profil
            String picture = null;
            if (response.get("picture") instanceof Map<?,?> pictureMap) {
                if (pictureMap.get("data") instanceof Map<?,?> dataMap) {
                    picture = (String) dataMap.get("url");
                }
            }

            log.info("OAuth2 Facebook : utilisateur vérifié — id={}", id);
            return new OAuthProviderInfo(id, email, name, picture);

        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.error("Erreur lors de la vérification du token Facebook : {}", e.getMessage());
            throw new BusinessException("Impossible de vérifier le token Facebook.", HttpStatus.UNAUTHORIZED);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Création du compte à la première connexion OAuth2
    // ─────────────────────────────────────────────────────────────────────────

    private Utilisateur creerCompte(OAuthProviderInfo info, String provider, String roleStr) {
        // Détermine le rôle — AUDITEUR par défaut
        Role role = Role.ROLE_AUDITEUR;
        if ("ROLE_ARTISTE".equalsIgnoreCase(roleStr)) {
            role = Role.ROLE_ARTISTE;
        }

        // Génère un username unique à partir du nom ou de l'email
        String baseUsername = info.name() != null
                ? info.name().toLowerCase().replaceAll("[^a-z0-9]", "_")
                : info.email().split("@")[0];
        String username = baseUsername;
        int suffix = 1;
        while (Boolean.TRUE.equals(utilisateurRepository.existsByUsername(username))) {
            username = baseUsername + "_" + suffix++;
        }

        // Mot de passe aléatoire — le compte OAuth2 n'utilise pas le mot de passe
        String randomPassword = passwordEncoder.encode(UUID.randomUUID().toString());

        Utilisateur user;
        if (role == Role.ROLE_ARTISTE) {
            user = Artiste.builder()
                    .username(username)
                    .email(info.email())
                    .password(randomPassword)
                    .role(Role.ROLE_ARTISTE)
                    .status(Statut.ACTIF)
                    .emailVerified(true)
                    .provider(OAuthProvider.valueOf(provider))
                    .providerId(info.providerId())
                    .artistName(info.name() != null ? info.name() : username)
                    .photoProfil(info.pictureUrl())
                    .photoCouverture(info.pictureUrl())
                    .verifie(false)
                    .build();
        } else {
            user = Auditeur.builder()
                    .username(username)
                    .email(info.email())
                    .password(randomPassword)
                    .role(Role.ROLE_AUDITEUR)
                    .status(Statut.ACTIF)
                    .emailVerified(true)
                    .provider(OAuthProvider.valueOf(provider))
                    .providerId(info.providerId())
                    .photoProfil(info.pictureUrl())
                    .abonnementActif(false)
                    .build();
        }

        log.info("OAuth2 {} : nouveau compte créé — email={}, role={}", provider, info.email(), role);
        return utilisateurRepository.save(user);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────

    /** Construit un principal Spring Security depuis l'entité utilisateur. */
    private org.springframework.security.core.userdetails.User buildPrincipal(Utilisateur user) {
        return new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPassword(),
                Collections.singletonList(new SimpleGrantedAuthority(user.getRole().name()))
        );
    }

    /** DTO interne pour transporter les infos récupérées du provider. */
    private record OAuthProviderInfo(
            String providerId,
            String email,
            String name,
            String pictureUrl
    ) {}
}
