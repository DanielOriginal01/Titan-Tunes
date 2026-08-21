package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Chansons;

public record ChansonResponse(
        Long id,
        String titre,
        Integer duree,
        String genre,
        String audioUrl,
        String coverImage,
        Long nbEcoutes,
        Long artisteId,
        String artisteNom,
        Long albumId,
        String albumTitre
) {
    public static ChansonResponse fromEntity(Chansons chanson) {
        if (chanson == null) {
            return null;
        }

        // On vérifie si l'URL audio est déjà un lien HTTP externe public
        String rawAudio = chanson.getAudioUrl();
        String finalAudioUrl;
        if (rawAudio != null && (rawAudio.startsWith("http://") || rawAudio.startsWith("https://"))) {
            finalAudioUrl = rawAudio;
        } else {
            // URL absolue pointant vers l'endpoint de streaming du contrôleur backend
            finalAudioUrl = "/api/v1/chansons/" + chanson.getId() + "/stream";
        }

        // Récupération de l'image de couverture (chanson ou album)
        String cover = chanson.getCoverImage();
        if ((cover == null || cover.isBlank()) && chanson.getAlbum() != null) {
            cover = chanson.getAlbum().getCoverImage();
        }

        String finalCoverUrl;
        if (cover != null && (cover.startsWith("http://") || cover.startsWith("https://"))) {
            finalCoverUrl = cover;
        } else {
            // URL absolue pointant vers l'endpoint d'image du contrôleur backend
            finalCoverUrl = "/api/v1/chansons/" + chanson.getId() + "/cover";
        }

        return new ChansonResponse(
                chanson.getId(),
                chanson.getTitre(),
                chanson.getDuree(),
                chanson.getCategorie() != null ? chanson.getCategorie().getNom() : null,
                finalAudioUrl,
                finalCoverUrl,
                chanson.getNbEcoutes(),
                chanson.getArtiste() != null ? chanson.getArtiste().getId() : null,
                chanson.getArtiste() != null ? chanson.getArtiste().getUsername() : null,
                chanson.getAlbum() != null ? chanson.getAlbum().getId() : null,
                chanson.getAlbum() != null ? chanson.getAlbum().getTitle() : null
        );
    }
}