package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Banniere;
import dan.com.titan_tune.enums.TypePromotion;

import java.time.LocalDateTime;

public record BanniereResponse(
        Long id,
        String titre,
        String description,
        String imageUrl,
        String lienCible,
        TypePromotion typePromotion,
        boolean active,
        LocalDateTime dateDebut,
        LocalDateTime dateFin,
        LocalDateTime createdAt,
        Long artisteId,
        String artisteName,
        Long albumId,
        String albumTitre,
        Long chansonId,
        String chansonTitre
) {
    public static BanniereResponse fromEntity(Banniere b) {
        return new BanniereResponse(
                b.getId(),
                b.getTitre(),
                b.getDescription(),
                b.getImageUrl(),
                b.getLienCible(),
                b.getTypePromotion(),
                b.isActive(),
                b.getDateDebut(),
                b.getDateFin(),
                b.getCreatedAt(),
                b.getArtiste() != null ? b.getArtiste().getId() : null,
                b.getArtiste() != null ? b.getArtiste().getArtistName() : null,
                b.getAlbum()   != null ? b.getAlbum().getId() : null,
                b.getAlbum()   != null ? b.getAlbum().getTitle() : null,
                b.getChanson() != null ? b.getChanson().getId() : null,
                b.getChanson() != null ? b.getChanson().getTitre() : null
        );
    }
}
