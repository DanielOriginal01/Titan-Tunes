package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Reversement;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record ReversementResponse(
        Long id,
        Double montant,
        String periode,
        LocalDate dateVersement,
        String statut,
        String reference,
        LocalDateTime createdAt,
        Long artisteId,
        String artisteName,
        Long labelId,
        String labelName
) {
    public static ReversementResponse fromEntity(Reversement r) {
        return new ReversementResponse(
                r.getId(),
                r.getMontant(),
                r.getPeriode(),
                r.getDateVersement(),
                r.getStatut(),
                r.getReference(),
                r.getCreatedAt(),
                r.getArtiste() != null ? r.getArtiste().getId() : null,
                r.getArtiste() != null ? r.getArtiste().getArtistName() : null,
                r.getLabel()   != null ? r.getLabel().getIdLabel() : null,
                r.getLabel()   != null ? r.getLabel().getLabelName() : null
        );
    }
}
