package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Playlist;

public record PlaylistResponse(
        Long id,
        String title,
        String description,
        boolean privee,
        Long auditeurId
) {
    public static PlaylistResponse fromEntity(Playlist playlist) {
        if (playlist == null) {
            return null;
        }
        return new PlaylistResponse(
                playlist.getId(),
                playlist.getTitle(),
                playlist.getDescription(),
                playlist.isPrivee(),
                playlist.getAuditeur() != null ? playlist.getAuditeur().getId() : null
        );
    }
}