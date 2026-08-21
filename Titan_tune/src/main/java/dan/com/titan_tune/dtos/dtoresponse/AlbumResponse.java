package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Album;
import java.time.LocalDate;

public record AlbumResponse(
        Long id,
        String title,
        LocalDate dateSortie,
        String coverImage,
        Long artisteId
) {
    public static AlbumResponse fromEntity(Album album) {
        if (album == null) {
            return null;
        }
        return new AlbumResponse(
                album.getId(),
                album.getTitle(),
                album.getDateSortie(),
                album.getCoverImage(),
                album.getArtiste() != null ? album.getArtiste().getId() : null
        );
    }
}