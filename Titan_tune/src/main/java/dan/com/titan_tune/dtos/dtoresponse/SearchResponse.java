package dan.com.titan_tune.dtos.dtoresponse;

import java.util.List;

/**
 * Résultat d'une recherche globale.
 * Chaque catégorie contient les résultats correspondants.
 * Les listes vides sont incluses pour que le frontend sache qu'il n'y a pas de résultats
 * dans cette catégorie (plutôt qu'une absence de clé).
 */
public record SearchResponse(
        String query,
        int totalResultats,
        List<ChansonResponse>  chansons,
        List<ArtisteResponse>  artistes,
        List<AlbumResponse>    albums,
        List<PlaylistResponse> playlists
) {}
