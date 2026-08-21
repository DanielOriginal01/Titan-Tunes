package dan.com.titan_tune.dtos.dtorequest;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Données pour créer une playlist")
public record PlaylistCreateRequest(

        @Schema(description = "Titre de la playlist", example = "Mes Afrobeats Préférés", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank(message = "Le titre est obligatoire")
        String title,

        @Schema(description = "Description — optionnel", example = "Les meilleurs sons afro du moment", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        String description,

        @Schema(description = "Playlist privée (true) ou publique (false) — défaut : false", example = "false", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        boolean privee,

        @Schema(description = "ID de l'auditeur propriétaire", example = "1", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "L'ID de l'auditeur est obligatoire")
        Long auditeurId
) {}
