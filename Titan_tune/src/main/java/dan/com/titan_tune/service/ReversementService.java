package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.dtos.dtoresponse.ReversementResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface ReversementService {

    /**
     * Calcule et enregistre les reversements du mois courant pour tous les artistes.
     * Appelé par l'admin ou un scheduler.
     */
    List<ReversementResponse> calculerReversementsMensuels(String periode);

    /**
     * Calcule et enregistre le reversement pour un artiste spécifique sur une période.
     */
    ReversementResponse calculerPourArtiste(Long artisteId, String periode);

    /** Marque un reversement comme versé. */
    ReversementResponse marquerCommeVerse(Long reversementId);

    /** Historique des reversements d'un artiste. */
    List<ReversementResponse> getHistoriqueArtiste(Long artisteId);

    /** Historique paginé des reversements d'un artiste. */
    PageResponse<ReversementResponse> getHistoriqueArtiste(Long artisteId, Pageable pageable);

    /** Total cumulé versé à un artiste. */
    Double getTotalVerseArtiste(Long artisteId);
}
