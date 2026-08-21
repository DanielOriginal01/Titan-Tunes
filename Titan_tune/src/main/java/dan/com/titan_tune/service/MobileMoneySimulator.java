package dan.com.titan_tune.service;

import dan.com.titan_tune.enums.ModePaiement;
import dan.com.titan_tune.enums.OffreAbonnement;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;
import java.util.UUID;

/**
 * Simulateur de passerelle Mobile Money pour Titan Tunes.
 *
 * Simule les comportements réels des opérateurs :
 *  - FLOOZ  (Moov Africa Togo)
 *  - TMONEY (Togocel)
 *  - WAVE   (Wave Mobile Money)
 *
 * En production, remplacer l'implémentation de {@code processer()}
 * par l'appel à l'API réelle de chaque opérateur.
 */
@Slf4j
@Component
public class MobileMoneySimulator {

    private static final Random RANDOM = new Random();

    // ─────────────────────────────────────────────────────────────────────────
    // Point d'entrée principal
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Simule un paiement mobile money.
     *
     * @param mode        opérateur choisi (FLOOZ, TMONEY, WAVE)
     * @param montant     montant en FCFA
     * @param offre       offre d'abonnement concernée
     * @param auditeurId  ID de l'auditeur pour les logs
     * @return résultat de la simulation
     */
    public SimulationResult processer(ModePaiement mode, double montant,
                                      OffreAbonnement offre, Long auditeurId) {
        log.info("[MobileMoneySimulator] Traitement {} — {} FCFA — offre {} — auditeur {}",
                mode, montant, offre.getCode(), auditeurId);

        // Simule un délai de traitement réseau (50-300 ms)
        simulerDelaiReseau();

        // Vérifie le montant minimum par opérateur
        String erreurMontant = verifierMontantMinimum(mode, montant);
        if (erreurMontant != null) {
            return SimulationResult.echec(genererRef(mode), erreurMontant, mode);
        }

        // Simule un taux de succès réaliste par opérateur :
        // FLOOZ : 96%, TMONEY : 94%, WAVE : 98%
        boolean succes = simulerSucces(mode);
        String ref = genererRef(mode);

        if (succes) {
            log.info("[MobileMoneySimulator] ✅ Succès {} — ref: {}", mode, ref);
            return SimulationResult.succes(ref, montant, mode, offre);
        } else {
            String motif = genererMotifEchec(mode);
            log.warn("[MobileMoneySimulator] ❌ Échec {} — ref: {} — motif: {}", mode, ref, motif);
            return SimulationResult.echec(ref, motif, mode);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers de simulation
    // ─────────────────────────────────────────────────────────────────────────

    private void simulerDelaiReseau() {
        try {
            Thread.sleep(50 + RANDOM.nextInt(250));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private boolean simulerSucces(ModePaiement mode) {
        double tauxSucces = switch (mode) {
            case FLOOZ  -> 0.96;
            case TMONEY -> 0.94;
            case WAVE   -> 0.98;
        };
        return RANDOM.nextDouble() < tauxSucces;
    }

    private String verifierMontantMinimum(ModePaiement mode, double montant) {
        double minimum = switch (mode) {
            case FLOOZ  -> 50.0;
            case TMONEY -> 100.0;
            case WAVE   -> 25.0;
        };
        if (montant < minimum) {
            return String.format("Montant insuffisant pour %s. Minimum : %.0f FCFA", mode, minimum);
        }
        return null;
    }

    private String genererRef(ModePaiement mode) {
        String prefixe = switch (mode) {
            case FLOOZ  -> "FLZ";
            case TMONEY -> "TMN";
            case WAVE   -> "WAV";
        };
        String date = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmm"));
        String uid  = UUID.randomUUID().toString().substring(0, 6).toUpperCase();
        return prefixe + "-" + date + "-" + uid;
    }

    private String genererMotifEchec(ModePaiement mode) {
        // Liste de motifs d'échec réalistes par opérateur
        String[][] motifs = {
            { "Solde insuffisant", "Transaction refusée par l'opérateur", "Délai d'attente dépassé" },
            { "Compte non activé", "Limite quotidienne atteinte", "Service temporairement indisponible" },
            { "PIN incorrect (trop de tentatives)", "Réseau indisponible", "Montant hors limites" }
        };
        int opIndex = switch (mode) { case FLOOZ -> 0; case TMONEY -> 1; case WAVE -> 2; };
        String[] motifsOp = motifs[opIndex];
        return motifsOp[RANDOM.nextInt(motifsOp.length)];
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Résultat de simulation
    // ─────────────────────────────────────────────────────────────────────────

    public record SimulationResult(
            boolean succes,
            String transactionRef,
            Double montant,
            String statut,
            String message,
            ModePaiement modePaiement,
            String operateur,
            LocalDateTime processedAt
    ) {
        static SimulationResult succes(String ref, double montant,
                                       ModePaiement mode, OffreAbonnement offre) {
            return new SimulationResult(
                    true, ref, montant, "SUCCES",
                    "Paiement de " + (int) montant + " FCFA accepté — " + offre.getLabel(),
                    mode, nomOperateur(mode), LocalDateTime.now()
            );
        }

        static SimulationResult echec(String ref, String motif, ModePaiement mode) {
            return new SimulationResult(
                    false, ref, null, "ECHEC",
                    motif, mode, nomOperateur(mode), LocalDateTime.now()
            );
        }

        private static String nomOperateur(ModePaiement mode) {
            return switch (mode) {
                case FLOOZ  -> "Moov Africa Togo (FLOOZ)";
                case TMONEY -> "Togocel (T-Money)";
                case WAVE   -> "Wave Mobile Money";
            };
        }
    }
}
