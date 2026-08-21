package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Utilisateur;
import dan.com.titan_tune.enums.Role;

import java.time.LocalDateTime;

public record UserProfileResponse(
    Long id,
    String username,
    String email,
    String telephone,
    Role role,
    String photoProfil,
    Boolean abonnementActif,
    LocalDateTime abonnementExpiry,
    int nbFavoris,
    LocalDateTime createdAt
) {
    public static UserProfileResponse fromEntity(Utilisateur u, Boolean abonnementActif, LocalDateTime abonnementExpiry, int nbFavoris) {
        return new UserProfileResponse(
            u.getId(),
            u.getUsername(),
            u.getEmail(),
            u.getTelephone(),
            u.getRole(),
            u.getPhotoProfil(),
            abonnementActif,
            abonnementExpiry,
            nbFavoris,
            u.getCreatedAt()
        );
    }
}
