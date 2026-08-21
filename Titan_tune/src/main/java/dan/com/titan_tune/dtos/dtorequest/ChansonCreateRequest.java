package dan.com.titan_tune.dtos.dtorequest;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Données pour publier une chanson (multipart/form-data)")
public record ChansonCreateRequest(

        @Schema(description = "Titre de la chanson", example = "Lomé la Nuit", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank(message = "Le titre est obligatoire")
        String titre,

        @Schema(description = "Durée en secondes — optionnel", example = "214", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        Integer duree,

        @Schema(description = "Paroles de la chanson — optionnel", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        String parole,

        @Schema(description = "ID de l'artiste propriétaire (déduit du token si omis)", example = "1", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        Long artisteId,

        @Schema(description = "ID de la catégorie musicale", example = "1", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "L'ID de la catégorie est obligatoire")
        Long categorieId,

        @Schema(description = "ID de l'album — optionnel (single si absent)", example = "2", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        Long albumId,

        @Schema(description = "Nom du fichier de couverture — optionnel", example = "cover.jpg", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        String coverImage
) {}
