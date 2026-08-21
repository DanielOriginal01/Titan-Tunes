package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtoresponse.UtilisateurResponse;
import dan.com.titan_tune.entities.Utilisateur;
import dan.com.titan_tune.enums.Role;
import dan.com.titan_tune.repository.UtilisateurRepository;
import dan.com.titan_tune.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/api/v1/utilisateurs", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class UtilisateurController {

    private final UtilisateurRepository utilisateurRepository;
    private final SecurityUtils securityUtils;

    /**
     * Récupère un utilisateur par son ID.
     * Accessible par l'auditeur (son propre profil) ou un admin (tout profil).
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('AUDITEUR', 'ADMIN')")
    public ResponseEntity<ApiResponse<UtilisateurResponse>> getUtilisateurById(@PathVariable Long id) {
        Role currentRole = securityUtils.getCurrentUser().getRole();

        if (currentRole == Role.ROLE_AUDITEUR) {
            securityUtils.assertAuditeurOwnerOrAdmin(id);
        }

        Utilisateur utilisateur = utilisateurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable avec l'ID : " + id));

        return ResponseEntity.ok(ApiResponse.success(
                "Utilisateur récupéré avec succès.",
                UtilisateurResponse.fromEntity(utilisateur)
        ));
    }
}
