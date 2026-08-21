package dan.com.titan_tune.dtos.dtorequest;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Données pour ajouter un élément aux favoris")
public record FavorisRequest(

        @Schema(description = "ID de l'élément à mettre en favori", example = "1", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "L'identifiant de la cible est obligatoire")
        Long targetId,

        @Schema(description = "Type de favori : CHANSON, ALBUM, ARTISTE ou PLAYLIST", example = "CHANSON", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank(message = "Le type de favori est obligatoire")
        String type,

        @Schema(description = "ID de l'auditeur qui ajoute le favori", example = "1", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "L'identifiant de l'utilisateur est obligatoire")
        Long utilisateurId
) {}
