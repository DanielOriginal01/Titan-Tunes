package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Utilisateur;
import dan.com.titan_tune.enums.Role;
import dan.com.titan_tune.enums.Statut;

public record UtilisateurResponse(
    Long id,
    String username,
    String email,
    String telephone,
    Role role,
    Statut statut,
    String photoProfil
) {
    public UtilisateurResponse(Long id, String username, String email, String telephone, Role role, Statut statut) {
        this(id, username, email, telephone, role, statut, null);
    }

    public static UtilisateurResponse fromEntity(Utilisateur u) {
        return new UtilisateurResponse(
            u.getId(),
            u.getUsername(),
            u.getEmail(),
            u.getTelephone(),
            u.getRole(),
            u.getStatus(),
            u.getPhotoProfil()
        );
    }
}