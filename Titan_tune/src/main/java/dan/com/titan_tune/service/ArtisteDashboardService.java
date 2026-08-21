package dan.com.titan_tune.service;

import java.util.Map;

public interface ArtisteDashboardService {
    long getTotalEcoutes(Long artisteId);
    long getAuditeursUniques(Long artisteId);
    long getImpactCatalogue(Long artisteId);
    Map<String, Object> getStatistiquesFinancieres(Long artisteId);
}
