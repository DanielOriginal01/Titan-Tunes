package dan.com.titan_tune.dtos.dtorequest;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Données pour souscrire un abonnement")
public record AbonnementRequest(

        @Schema(description = "Code de l'offre : WEEKLY (7j), MONTHLY (30j) ou YEARLY (365j)", example = "MONTHLY", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank(message = "L'offre est obligatoire")
        String offre,

        @Schema(description = "Montant en FCFA — optionnel (calculé automatiquement selon l'offre)", example = "2000.0", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        Double montantAbonnement,

        @Schema(description = "Référence mobile money — optionnel", example = "FLOOZ-REF-001", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        String description,

        @Schema(description = "ID de l'auditeur qui souscrit", example = "1", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "L'identifiant de l'auditeur est obligatoire")
        Long auditeurId
) {}
