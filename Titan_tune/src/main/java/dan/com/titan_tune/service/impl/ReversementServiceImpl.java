package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtoresponse.ReversementResponse;
import dan.com.titan_tune.entities.Reversement;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.ArtisteRepository;
import dan.com.titan_tune.repository.ChansonRepository;
import dan.com.titan_tune.repository.PaiementRepository;
import dan.com.titan_tune.repository.ReversementRepository;
import dan.com.titan_tune.service.ReversementService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReversementServiceImpl implements ReversementService {

    /** Taux de reversement aux artistes : 70 % des revenus bruts. */
    private static final double TAUX_ROYALTIES = 0.70;

    private final ReversementRepository reversementRepository;
    private final ArtisteRepository     artisteRepository;
    private final ChansonRepository     chansonRepository;
    private final PaiementRepository    paiementRepository;

    // ─────────────────────────────────────────────────────────────────────────
    // Calcul mensuel global (tous les artistes)
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    @Transactional
    public List<ReversementResponse> calculerReversementsMensuels(String periode) {
        var artistes = artisteRepository.findAll();
        return artistes.stream()
                .map(a -> calculerPourArtiste(a.getId(), periode))
                .toList();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Calcul pour un artiste spécifique
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    @Transactional
    public ReversementResponse calculerPourArtiste(Long artisteId, String periode) {
        var artiste = artisteRepository.findById(artisteId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Artiste non trouvé id: " + artisteId));

        if (reversementRepository.existsByArtisteIdAndPeriode(artisteId, periode)) {
            throw new BusinessException(
                    "Un reversement a déjà été calculé pour l'artiste "
                    + artisteId + " sur la période " + periode);
        }

        // Revenus totaux de la plateforme sur la période
        double revenusTotaux = paiementRepository.findAll().stream()
                .mapToDouble(p -> p.getMontant() != null ? p.getMontant() : 0.0)
                .sum();

        // Part du catalogue de l'artiste par rapport au catalogue global
        long chansonsArtiste = chansonRepository.findByArtisteId(artisteId).size();
        long chansonsGlobal  = chansonRepository.count();
        double partCatalogue = chansonsGlobal > 0
                ? (double) chansonsArtiste / chansonsGlobal
                : 0.0;

        double montant = revenusTotaux * TAUX_ROYALTIES * partCatalogue;

        var reversement = Reversement.builder()
                .artiste(artiste)
                .montant(montant)
                .periode(periode)
                .dateVersement(LocalDate.now())
                .statut("EN_ATTENTE")
                .reference("REV-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase())
                .build();

        var saved = reversementRepository.save(reversement);
        log.info("Reversement calculé : artiste={} période={} montant={:.2f} FCFA",
                artisteId, periode, montant);
        return ReversementResponse.fromEntity(saved);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Marquage comme versé
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    @Transactional
    public ReversementResponse marquerCommeVerse(Long reversementId) {
        var rev = reversementRepository.findById(reversementId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Reversement non trouvé id: " + reversementId));

        if ("VERSE".equals(rev.getStatut())) {
            throw new BusinessException("Ce reversement a déjà été versé.");
        }

        rev.setStatut("VERSE");
        rev.setDateVersement(LocalDate.now());
        return ReversementResponse.fromEntity(reversementRepository.save(rev));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Consultation
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    @Transactional(readOnly = true)
    public List<ReversementResponse> getHistoriqueArtiste(Long artisteId) {
        return reversementRepository.findByArtisteId(artisteId).stream()
                .map(ReversementResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public dan.com.titan_tune.dtos.dtoresponse.PageResponse<ReversementResponse> getHistoriqueArtiste(
            Long artisteId, org.springframework.data.domain.Pageable pageable) {
        var page = reversementRepository.findByArtisteId(artisteId, pageable);
        return dan.com.titan_tune.dtos.dtoresponse.PageResponse.from(page, ReversementResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public Double getTotalVerseArtiste(Long artisteId) {
        Double total = reversementRepository.sumMontantVerseByArtisteId(artisteId);
        return total != null ? total : 0.0;
    }

    /** Retourne la période courante au format "YYYY-MM". */
    public static String periodeCourante() {
        return YearMonth.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
    }
}
