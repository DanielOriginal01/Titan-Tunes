package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Evenement;

import java.time.LocalDateTime;

public record EvenementResponse(
    Long idEvenement,
    String nameConcert,
    LocalDateTime dateEvenement,
    LocalDateTime dateLimite,
    String lieu,
    Double prixTicket,
    String artistName
) {
    public static EvenementResponse fromEntity(Evenement e) {
        return new EvenementResponse(
            e.getIdEvenement(),
            e.getNameConcert(),
            e.getDateEvenement(),
            e.getDateLimite(),
            e.getLieu(),
            e.getPrixTicket(),
            e.getArtiste() != null ? e.getArtiste().getArtistName() : null
        );
    }
}