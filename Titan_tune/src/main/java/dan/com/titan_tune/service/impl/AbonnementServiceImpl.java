package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtoresponse.SouscrireEtPayerResponse;
import dan.com.titan_tune.dtos.dtorequest.SouscrireEtPayerRequest;
import dan.com.titan_tune.dtos.dtoresponse.OffreAbonnementResponse;
import dan.com.titan_tune.dtos.dtoresponse.PaiementResponse;
import dan.com.titan_tune.dtos.dtoresponse.AbonnementResponse;
import dan.com.titan_tune.entities.Abonnement;
import dan.com.titan_tune.entities.Auditeur;
import dan.com.titan_tune.entities.Paiement;
import dan.com.titan_tune.enums.OffreAbonnement;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.AbonnementRepository;
import dan.com.titan_tune.repository.AuditeurRepository;
import dan.com.titan_tune.repository.PaiementRepository;
import dan.com.titan_tune.service.AbonnementService;
import dan.com.titan_tune.service.MobileMoneySimulator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class AbonnementServiceImpl implements AbonnementService {

    private final AbonnementRepository abonnementRepository;
    private final AuditeurRepository   auditeurRepository;
    private final MobileMoneySimulator simulator;
    private final PaiementRepository   paiementRepository;

    @Override
    public Abonnement subscribe(Auditeur auditeur, String offerCode, String mobileMoneyRef) {
        // ── Résolution de l'offre (valide le code + récupère durée et prix) ─
        OffreAbonnement offre;
        try {
            offre = OffreAbonnement.fromCode(offerCode);
        } catch (IllegalArgumentException e) {
            throw new BusinessException(e.getMessage());
        }

        log.info("[Abonnement] Souscription — auditeur {} — offre {} ({} FCFA / {} jours)",
                auditeur.getId(), offre.getCode(), offre.getPrixFcfa(), offre.getDureeDays());

        // ── Désactivation des abonnements actifs précédents ─────────────────
        var anciens = abonnementRepository.findByAuditeurAndActiveTrue(auditeur);
        if (!anciens.isEmpty()) {
            anciens.forEach(a -> a.setActive(false));
            log.info("[Abonnement] {} ancien(s) abonnement(s) désactivé(s) pour auditeur {}",
                    anciens.size(), auditeur.getId());
        }

        // ── Création du nouvel abonnement ────────────────────────────────────
        LocalDateTime now = LocalDateTime.now();
        Abonnement abonnement = Abonnement.builder()
                .auditeur(auditeur)
                .offerCode(offre.getCode())
                .mobileMoneyRef(mobileMoneyRef)
                .startDate(now)
                .endDate(now.plusDays(offre.getDureeDays()))
                .active(true)
                .build();

        Abonnement saved = abonnementRepository.save(abonnement);

        // ── Met à jour le flag abonnementActif sur l'auditeur ───────────────
        auditeur.setAbonnementActif(true);
        auditeurRepository.save(auditeur);

        log.info("[Abonnement] ✅ Créé — id: {} — expire le: {}",
                saved.getId(), saved.getEndDate());

        return saved;
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isActive(Auditeur auditeur) {
        return abonnementRepository.existsByAuditeurAndActiveTrueAndEndDateAfter(
                auditeur, LocalDateTime.now());
    }

    @Override
    @Transactional(readOnly = true)
    public List<OffreAbonnementResponse> getOffresDisponibles() {
        return Arrays.stream(OffreAbonnement.values())
                .map(OffreAbonnementResponse::fromEnum)
                .toList();
    }

    /**
     * Flux principal de l'app mobile :
     * 1. Vérifie l'existence de l'auditeur
     * 2. Simule le paiement mobile money
     * 3. Si succès → crée l'abonnement + active le compte
     * 4. Si échec  → enregistre le paiement ECHEC et retourne l'erreur
     */
    @Override
    @Transactional
    public SouscrireEtPayerResponse souscrireEtPayer(SouscrireEtPayerRequest request) {
        // Résolution de l'offre
        OffreAbonnement offre;
        try {
            offre = OffreAbonnement.fromCode(request.offreCode());
        } catch (IllegalArgumentException e) {
            throw new BusinessException(e.getMessage());
        }

        var auditeur = auditeurRepository.findById(request.auditeurId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Auditeur non trouvé id: " + request.auditeurId()));

        // Simulation paiement
        MobileMoneySimulator.SimulationResult result = simulator.processer(
                request.modePaiement(), offre.getPrixFcfa(), offre, request.auditeurId());

        // Persistance paiement (succès ou échec)
        var paiement = Paiement.builder()
                .montant(offre.getPrixFcfa())
                .modePaiement(request.modePaiement())
                .operateur(result.operateur())
                .statut(result.statut())
                .transactionRef(result.transactionRef())
                .message(result.message())
                .auditeur(auditeur)
                .build();
        var savedPaiement = paiementRepository.save(paiement);

        if (!result.succes()) {
            log.warn("[SouscrireEtPayer] ❌ Paiement échoué — auditeur {} — motif: {}",
                    request.auditeurId(), result.message());
            return new SouscrireEtPayerResponse(
                    false,
                    "Paiement refusé par " + result.operateur() + " : " + result.message(),
                    PaiementResponse.fromEntity(savedPaiement),
                    null
            );
        }

        // Paiement réussi → créer l'abonnement
        Abonnement abonnement = subscribe(auditeur, offre.getCode(), result.transactionRef());

        // Lier le paiement à l'abonnement
        savedPaiement.setAbonnement(abonnement);
        paiementRepository.save(savedPaiement);

        log.info("[SouscrireEtPayer] ✅ Abonnement {} activé — auditeur {} — offre {} — ref {}",
                abonnement.getId(), request.auditeurId(), offre.getCode(), result.transactionRef());

        return new SouscrireEtPayerResponse(
                true,
                "Abonnement " + offre.getLabel() + " activé jusqu'au "
                    + abonnement.getEndDate().toLocalDate() + ". Merci !",
                PaiementResponse.fromEntity(savedPaiement),
                AbonnementResponse.fromEntity(abonnement)
        );
    }
}
