package dan.com.titan_tune.security;

import dan.com.titan_tune.entities.Utilisateur;
import dan.com.titan_tune.enums.Role;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.repository.UtilisateurRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

/**
 * Utilitaire centralisé pour toutes les vérifications de sécurité par acteur.
 *
 * Règles générales :
 *  - Un ADMIN peut tout faire.
 *  - Un ARTISTE ne peut agir que sur ses propres ressources.
 *  - Un AUDITEUR ne peut agir que sur ses propres ressources.
 *  - Toute tentative d'agir sur les ressources d'autrui → 403 FORBIDDEN.
 */
@Component
@RequiredArgsConstructor
public class SecurityUtils {

    private final UtilisateurRepository utilisateurRepository;

    // ─────────────────────────────────────────────────────────────────────────
    // Récupération de l'utilisateur courant
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Retourne l'entité Utilisateur de la personne actuellement connectée.
     * Lève 401 si aucun utilisateur n'est authentifié.
     */
    public Utilisateur getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()
                || "anonymousUser".equals(auth.getPrincipal())) {
            throw new BusinessException("Aucun utilisateur authentifié.", HttpStatus.UNAUTHORIZED);
        }
        String email = ((UserDetails) auth.getPrincipal()).getUsername();
        return utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new BusinessException(
                        "Utilisateur courant introuvable.", HttpStatus.UNAUTHORIZED));
    }

    /** Retourne l'ID de l'utilisateur courant. */
    public Long getCurrentUserId() {
        return getCurrentUser().getId();
    }

    /** Retourne true si l'utilisateur courant est ADMIN. */
    public boolean isAdmin() {
        return getCurrentUser().getRole() == Role.ROLE_ADMIN;
    }

    /** Retourne true si l'ID courant correspond à l'ID donné. */
    public boolean isCurrentUser(Long userId) {
        return getCurrentUser().getId().equals(userId);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Vérifications d'ownership génériques
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Vérifie que l'utilisateur courant est propriétaire de la ressource ou ADMIN.
     * Lève 403 FORBIDDEN sinon.
     */
    public void assertOwnerOrAdmin(Long ownerId) {
        Utilisateur current = getCurrentUser();
        if (current.getRole() != Role.ROLE_ADMIN && !current.getId().equals(ownerId)) {
            throw new BusinessException(
                    "Accès refusé : vous ne pouvez accéder qu'à vos propres ressources.",
                    HttpStatus.FORBIDDEN);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Vérifications par rôle métier
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Vérifie que l'utilisateur courant est bien l'AUDITEUR identifié par {@code auditeurId},
     * ou un ADMIN. Protège contre les IDOR sur les routes auditeur.
     */
    public void assertAuditeurOwnerOrAdmin(Long auditeurId) {
        Utilisateur current = getCurrentUser();
        if (current.getRole() == Role.ROLE_ADMIN) return;
        if (current.getRole() != Role.ROLE_AUDITEUR) {
            throw new BusinessException(
                    "Accès refusé : cette action est réservée aux auditeurs.",
                    HttpStatus.FORBIDDEN);
        }
        if (!current.getId().equals(auditeurId)) {
            throw new BusinessException(
                    "Accès refusé : vous ne pouvez accéder qu'à vos propres données d'auditeur.",
                    HttpStatus.FORBIDDEN);
        }
    }

    /**
     * Vérifie que l'utilisateur courant est bien l'ARTISTE identifié par {@code artisteId},
     * ou un ADMIN. Protège contre les IDOR sur les routes artiste.
     */
    public void assertArtisteOwnerOrAdmin(Long artisteId) {
        Utilisateur current = getCurrentUser();
        if (current.getRole() == Role.ROLE_ADMIN) return;
        if (current.getRole() != Role.ROLE_ARTISTE) {
            throw new BusinessException(
                    "Accès refusé : cette action est réservée aux artistes.",
                    HttpStatus.FORBIDDEN);
        }
        if (!current.getId().equals(artisteId)) {
            throw new BusinessException(
                    "Accès refusé : vous ne pouvez accéder qu'à vos propres données d'artiste.",
                    HttpStatus.FORBIDDEN);
        }
    }

    /**
     * Vérifie qu'un auditeur ne peut soumettre une action qu'en son propre nom.
     * Le champ {@code requestedId} est l'ID fourni dans le body de la requête.
     * Lève 403 si c'est différent de l'ID courant (sauf ADMIN).
     */
    public void assertSelfActionAuditeur(Long requestedId) {
        assertAuditeurOwnerOrAdmin(requestedId);
    }

    /**
     * Vérifie qu'un artiste ne peut soumettre une action qu'en son propre nom.
     */
    public void assertSelfActionArtiste(Long requestedId) {
        assertArtisteOwnerOrAdmin(requestedId);
    }
}
