package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.PaiementRequest;
import dan.com.titan_tune.dtos.dtoresponse.PaiementResponse;
import dan.com.titan_tune.entities.Abonnement;
import dan.com.titan_tune.entities.Paiement;
import dan.com.titan_tune.enums.OffreAbonnement;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.AbonnementRepository;
import dan.com.titan_tune.repository.AuditeurRepository;
import dan.com.titan_tune.repository.PaiementRepository;
import dan.com.titan_tune.service.MobileMoneySimulator;
import dan.com.titan_tune.service.PaiementService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaiementServiceImpl implements PaiementService {

    private final PaiementRepository   paiementRepository;
    private final AuditeurRepository   auditeurRepository;
    private final AbonnementRepository abonnementRepository;
    private final MobileMoneySimulator simulator;

    @Override
    @Transactional
    public PaiementResponse effectuerPaiement(PaiementRequest request) {
        // ── Vérification idempotence ────────────────────────────────────────
        if (request.idempotencyKey() != null && !request.idempotencyKey().isBlank()) {
            paiementRepository.findByIdempotencyKey(request.idempotencyKey())
                    .ifPresent(existing -> {
                        log.warn("[Paiement] Doublon détecté — clé: {}", request.idempotencyKey());
                        throw new BusinessException(
                            "Ce paiement a déjà été traité (clé: " + request.idempotencyKey() + "). "
                            + "Statut : " + existing.getStatut(),
                            HttpStatus.CONFLICT
                        );
                    });
        }

        // ── Chargement de l'auditeur ────────────────────────────────────────
        var auditeur = auditeurRepository.findById(request.auditeurId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Auditeur non trouvé id: " + request.auditeurId()));

        // ── Chargement de l'abonnement (optionnel) ──────────────────────────
        Abonnement abonnement = null;
        if (request.abonnementId() != null) {
            abonnement = abonnementRepository.findById(request.abonnementId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Abonnement non trouvé id: " + request.abonnementId()));
        }

        // ── Détermination de l'offre pour la simulation ─────────────────────
        // Si un abonnement est lié, on récupère son offre, sinon offre MONTHLY par défaut
        OffreAbonnement offre = OffreAbonnement.MONTHLY;
        if (abonnement != null) {
            try {
                offre = OffreAbonnement.fromCode(abonnement.getOfferCode());
            } catch (IllegalArgumentException e) {
                log.warn("[Paiement] Code offre inconnu '{}', utilisation MONTHLY par défaut",
                        abonnement.getOfferCode());
            }
        }

        // ── Simulation du paiement mobile money ─────────────────────────────
        MobileMoneySimulator.SimulationResult result = simulator.processer(
                request.modePaiement(),
                request.montant(),
                offre,
                request.auditeurId()
        );

        // ── Persistance du paiement (succès ET échec sont enregistrés) ──────
        var paiement = Paiement.builder()
                .montant(request.montant())
                .modePaiement(request.modePaiement())
                .operateur(result.operateur())
                .statut(result.statut())
                .transactionRef(result.transactionRef())
                .message(result.message())
                .idempotencyKey(request.idempotencyKey())
                .auditeur(auditeur)
                .abonnement(abonnement)
                .build();

        var saved = paiementRepository.save(paiement);

        // ── Si succès : active l'abonnement de l'auditeur ───────────────────
        if (result.succes()) {
            auditeur.setAbonnementActif(true);
            auditeurRepository.save(auditeur);
            log.info("[Paiement] ✅ Auditeur {} — abonnement activé via {}",
                    auditeur.getId(), result.transactionRef());
        } else {
            // Paiement échoué → lève une exception avec le motif
            // (le paiement ECHEC est déjà enregistré pour les logs)
            throw new BusinessException(
                "Paiement refusé par " + result.operateur() + " : " + result.message(),
                HttpStatus.PAYMENT_REQUIRED
            );
        }

        return PaiementResponse.fromEntity(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<PaiementResponse> getHistoriqueAuditeur(Long auditeurId) {
        return paiementRepository.findByAuditeurId(auditeurId)
                .stream()
                .map(PaiementResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public dan.com.titan_tune.dtos.dtoresponse.PageResponse<PaiementResponse> getHistoriqueAuditeur(
            Long auditeurId, org.springframework.data.domain.Pageable pageable) {
        var page = paiementRepository.findByAuditeurId(auditeurId, pageable);
        return dan.com.titan_tune.dtos.dtoresponse.PageResponse.from(page, PaiementResponse::fromEntity);
    }
}
