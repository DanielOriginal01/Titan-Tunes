package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Paiement;
import dan.com.titan_tune.enums.ModePaiement;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "Résultat d'un paiement mobile money")
public record PaiementResponse(

        @Schema(description = "ID interne du paiement")
        Long idPaiement,

        @Schema(description = "Montant payé en FCFA")
        Double montant,

        @Schema(description = "Date et heure du paiement")
        LocalDateTime datePaid,

        @Schema(description = "Opérateur mobile money utilisé")
        ModePaiement modePaiement,

        @Schema(description = "Nom complet de l'opérateur", example = "Moov Africa Togo (FLOOZ)")
        String operateur,

        @Schema(description = "Statut : SUCCES ou ECHEC")
        String statut,

        @Schema(description = "Référence unique de la transaction", example = "FLZ-202608131045-A3B7C2")
        String transactionRef,

        @Schema(description = "Message descriptif du résultat")
        String message,

        @Schema(description = "ID de l'abonnement lié — null si paiement standalone")
        Long abonnementId

) {
    public static PaiementResponse fromEntity(Paiement p) {
        return new PaiementResponse(
                p.getIdPaiement(),
                p.getMontant(),
                p.getDatePaid(),
                p.getModePaiement(),
                p.getOperateur(),
                p.getStatut(),
                p.getTransactionRef(),
                p.getMessage(),
                p.getAbonnement() != null ? p.getAbonnement().getId() : null
        );
    }
}
