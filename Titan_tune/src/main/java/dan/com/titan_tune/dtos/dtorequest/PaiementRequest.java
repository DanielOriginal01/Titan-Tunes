package dan.com.titan_tune.dtos.dtorequest;

import dan.com.titan_tune.enums.ModePaiement;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

@Schema(description = "Données pour effectuer un paiement mobile money")
public record PaiementRequest(

        @Schema(description = "Montant en FCFA", example = "2000.0", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "Le montant est obligatoire")
        @Positive(message = "Le montant doit être positif")
        Double montant,

        @Schema(description = "Mode de paiement : FLOOZ, TMONEY ou WAVE", example = "FLOOZ", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "Le mode de paiement est obligatoire")
        ModePaiement modePaiement,

        @Schema(description = "ID de l'auditeur qui paie", example = "1", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "L'identifiant de l'auditeur est obligatoire")
        Long auditeurId,

        @Schema(description = "ID de l'abonnement associé — optionnel", example = "3", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        Long abonnementId,

        @Schema(description = "Clé d'idempotence — optionnel, évite les doubles paiements", example = "FLOOZ-2026-XYZ", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        String idempotencyKey
) {}
