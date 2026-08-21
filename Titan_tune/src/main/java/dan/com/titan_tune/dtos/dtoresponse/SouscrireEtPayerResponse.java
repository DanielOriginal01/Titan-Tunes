package dan.com.titan_tune.dtos.dtoresponse;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Résultat d'une souscription + paiement combinés")
public record SouscrireEtPayerResponse(

        @Schema(description = "Succès global de l'opération")
        boolean succes,

        @Schema(description = "Message résumant le résultat")
        String message,

        @Schema(description = "Détails du paiement effectué")
        PaiementResponse paiement,

        @Schema(description = "Abonnement créé (null si paiement échoué)")
        AbonnementResponse abonnement

) {}
