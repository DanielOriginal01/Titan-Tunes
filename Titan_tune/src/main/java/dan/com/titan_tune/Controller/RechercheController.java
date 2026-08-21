package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtoresponse.SearchResponse;
import dan.com.titan_tune.service.RechercheService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(value = {"/api/v1/search", "/api/v1/recherche"}, produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class RechercheController {

    private final RechercheService rechercheService;

    /**
     * Recherche globale — cherche simultanément dans :
     *   - les chansons (titre + nom d'artiste)
     *   - les artistes (nom d'artiste + username)
     *   - les albums (titre)
     *   - les playlists publiques (titre)
     *
     * Accès public — aucun token requis.
     *
     * @param q     terme de recherche (optionnel si query fourni)
     * @param query terme de recherche alternatif
     * @param limit nombre max de résultats par catégorie (défaut : 10, max : 50)
     *
     * Exemple : GET /api/v1/search?q=kofi&limit=5 ou GET /api/v1/recherche?query=kofi&limit=5
     */
    @GetMapping
    public ResponseEntity<ApiResponse<SearchResponse>> search(
            @RequestParam(value = "q", required = false) String q,
            @RequestParam(value = "query", required = false) String query,
            @RequestParam(value = "limit", defaultValue = "10") int limit) {

        String searchTerm = (q != null && !q.isBlank()) ? q : (query != null ? query : "");

        // Borne la limite pour éviter des requêtes trop lourdes
        int safeLimit = Math.min(Math.max(limit, 1), 50);

        SearchResponse result = rechercheService.rechercher(searchTerm, safeLimit);

        String message = result.totalResultats() == 0
                ? "Aucun résultat pour \"" + searchTerm + "\"."
                : result.totalResultats() + " résultat(s) trouvé(s) pour \"" + searchTerm + "\".";

        return ResponseEntity.ok(ApiResponse.success(message, result));
    }
}
