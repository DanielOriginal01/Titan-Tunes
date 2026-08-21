package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Ecoute;
import java.time.LocalDateTime;

public record EcouteResponse(
        Long id,
        Long chansonId,
        String chansonTitre,
        Long auditeurId,
        LocalDateTime listenedAt
) {
    public static EcouteResponse fromEntity(Ecoute ecoute) {
        if (ecoute == null) {
            return null;
        }
        return new EcouteResponse(
                ecoute.getId(),
                ecoute.getChanson() != null ? ecoute.getChanson().getId() : null,
                ecoute.getChanson() != null ? ecoute.getChanson().getTitre() : null,
                ecoute.getAuditeur() != null ? ecoute.getAuditeur().getId() : null,
                ecoute.getListenedAt()
        );
    }
}