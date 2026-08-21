package dan.com.titan_tune.dtos.dtoresponse;

public record StatistiquesArtisteResponse(
        Long totalEcoutes,
        Long auditeursUniques,
        Long totalChansons,
        Long totalAlbums,
        Long totalFavoris,
        Double royaltiesEstimees,
        String partCatalogue
) {
    /** Constructeur de compatibilité avec l'ancien code (4 paramètres). */
    public StatistiquesArtisteResponse(Long totalEcoutes, Long totalFavoris,
                                       Long totalAlbums, Long totalChansons) {
        this(totalEcoutes, 0L, totalChansons, totalAlbums, totalFavoris, 0.0, "0.00%");
    }
}
