package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.repository.AlbumRepository;
import dan.com.titan_tune.repository.ChansonRepository;
import dan.com.titan_tune.repository.EcouteRepository;
import dan.com.titan_tune.repository.FavorisChansonRepository;
import dan.com.titan_tune.repository.PaiementRepository;
import dan.com.titan_tune.repository.ReversementRepository;
import dan.com.titan_tune.service.ArtisteDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class ArtisteDashboardServiceImpl implements ArtisteDashboardService {

    private final EcouteRepository         ecouteRepository;
    private final ChansonRepository        chansonRepository;
    private final AlbumRepository          albumRepository;
    private final FavorisChansonRepository favorisChansonRepository;
    private final PaiementRepository       paiementRepository;
    private final ReversementRepository    reversementRepository;

    @Override
    @Transactional(readOnly = true)
    public long getTotalEcoutes(Long artisteId) {
        Long count = ecouteRepository.countByChansonArtisteId(artisteId);
        return count != null ? count : 0L;
    }

    @Override
    @Transactional(readOnly = true)
    public long getAuditeursUniques(Long artisteId) {
        return ecouteRepository.countDistinctAuditeurByChansonArtisteId(artisteId);
    }

    /** Nombre total de chansons publiées par l'artiste (= impact catalogue). */
    @Override
    @Transactional(readOnly = true)
    public long getImpactCatalogue(Long artisteId) {
        return chansonRepository.countByArtisteId(artisteId);
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getStatistiquesFinancieres(Long artisteId) {
        long totalChansons  = chansonRepository.countByArtisteId(artisteId);
        long totalAlbums    = albumRepository.findByArtisteId(artisteId).size();
        long totalChansonsG = chansonRepository.count();

        double part = totalChansonsG > 0 ? (double) totalChansons / totalChansonsG : 0.0;

        double revenusPlateforme = paiementRepository.findAll().stream()
                .mapToDouble(p -> p.getMontant() != null ? p.getMontant() : 0.0)
                .sum();

        double royaltiesEstimees = revenusPlateforme * 0.70 * part;

        // Total déjà réellement versé
        Double totalVerse = reversementRepository.sumMontantVerseByArtisteId(artisteId);

        return Map.of(
                "totalChansons",     totalChansons,
                "totalAlbums",       totalAlbums,
                "royaltiesEstimees", royaltiesEstimees,
                "totalVerse",        totalVerse != null ? totalVerse : 0.0,
                "partCatalogue",     String.format("%.2f%%", part * 100)
        );
    }
}
