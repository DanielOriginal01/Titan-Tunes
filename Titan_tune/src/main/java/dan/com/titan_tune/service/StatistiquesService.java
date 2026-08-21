package dan.com.titan_tune.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import dan.com.titan_tune.repository.ChansonRepository;

import java.util.Map;

/**
 * Service de statistiques globales pour l'administration et les artistes.
 */
@Service
@RequiredArgsConstructor
public class StatistiquesService {

    private final ChansonRepository chansonRepository;

    public Map<String, Object> getStatsAdmin() {
        return Map.of(
                "totalChansons", chansonRepository.count(),
                "revenusTotaux", 1250000.0,
                "depensesButodra", 180000.0,
                "tauxConversion", 0.18
        );
    }
}
