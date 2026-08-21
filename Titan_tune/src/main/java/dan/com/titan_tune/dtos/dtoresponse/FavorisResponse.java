package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Favoris;

import java.time.LocalDateTime;

public record FavorisResponse(
    Long idFav,
    LocalDateTime dateAjout,
    Long utilisateurId,
    String targetType
) {
    public static FavorisResponse fromEntity(Favoris f, String targetType) {
        return new FavorisResponse(
            f.getIdFav(),
            f.getDateAjout(),
            f.getUtilisateur().getId(),
            targetType
        );
    }
}