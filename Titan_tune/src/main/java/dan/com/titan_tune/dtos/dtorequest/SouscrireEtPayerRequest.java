package dan.com.titan_tune.dtos.dtorequest;

import dan.com.titan_tune.enums.ModePaiement;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * Requête unifiée : souscrire un abonnement ET payer en une seule opération.
 * C'est le flux principal pour l'application mobile/web.
 */
@Schema(description = "Souscrire un abonnement et payer en une seule opération")
public record SouscrireEtPayerRequest(

        @Schema(description = "Code de l'offre", example = "MONTHLY",
                allowableValues = {"DAILY", "WEEKLY", "MONTHLY", "QUARTERLY", "YEARLY"},
                requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank(message = "Le code de l'offre est obligatoire")
        String offreCode,

        @Schema(description = "Mode de paiement mobile money", example = "FLOOZ",
                requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "Le mode de paiement est obligatoire")
        ModePaiement modePaiement,

        @Schema(description = "ID de l'auditeur", example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "L'ID de l'auditeur est obligatoire")
        Long auditeurId,

        @Schema(description = "Numéro de téléphone mobile money (optionnel, pour les logs)",
                example = "+22891234567", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        String numeroPaiement
) {}
