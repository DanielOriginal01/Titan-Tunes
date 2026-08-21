package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Telechargement;
import dan.com.titan_tune.enums.Statut;

import java.time.LocalDateTime;

public record TelechargementResponse(
        Long id,
        Long chansonId,
        String chansonTitre,
        Long auditeurId,
        LocalDateTime dateTelecharger,
        Statut status
) {
    public static TelechargementResponse fromEntity(Telechargement t) {
        if (t == null) return null;
        return new TelechargementResponse(
                t.getIdTele(),
                t.getChanson() != null ? t.getChanson().getId() : null,
                t.getChanson() != null ? t.getChanson().getTitre() : null,
                t.getAuditeur() != null ? t.getAuditeur().getId() : null,
                t.getDateTelecharger(),
                t.getStatus()
        );
    }
}
