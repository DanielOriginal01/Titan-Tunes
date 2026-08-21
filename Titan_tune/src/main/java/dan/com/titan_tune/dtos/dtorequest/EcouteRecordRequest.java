package dan.com.titan_tune.dtos.dtorequest;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

@Schema(description = "Données pour enregistrer une écoute")
public record EcouteRecordRequest(

        @Schema(description = "ID de la chanson écoutée", example = "1", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "L'identifiant de la chanson est obligatoire")
        Long chansonId,

        @Schema(description = "ID de l'auditeur", example = "1", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "L'identifiant de l'auditeur est obligatoire")
        Long auditeurId,

        @Schema(description = "Durée écoutée en secondes — optionnel", example = "180", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        @Positive(message = "La durée doit être positive")
        Integer dureeEcoute
) {}
