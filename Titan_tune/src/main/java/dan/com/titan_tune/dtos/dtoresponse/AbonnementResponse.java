package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Abonnement;
import java.time.LocalDateTime;

public record AbonnementResponse(
        Long id,
        String offerCode,
        String mobileMoneyRef,
        LocalDateTime startDate,
        LocalDateTime endDate,
        boolean active,
        Long auditeurId
) {
    public static AbonnementResponse fromEntity(Abonnement a) {
        if (a == null) {
            return null;
        }
        return new AbonnementResponse(
                a.getId(),
                a.getOfferCode(),
                a.getMobileMoneyRef(),
                a.getStartDate(),
                a.getEndDate(),
                a.isActive(),
                a.getAuditeur() != null ? a.getAuditeur().getId() : null
        );
    }
}