package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtoresponse.SearchResponse;

public interface RechercheService {

    /**
     * Recherche globale sur chansons, artistes, albums et playlists publiques.
     *
     * @param query       texte à rechercher (insensible à la casse)
     * @param limit       nombre max de résultats par catégorie (défaut 10)
     */
    SearchResponse rechercher(String query, int limit);
}
