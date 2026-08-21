package dan.com.titan_tune.dtos.dtorequest;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDate;

@Schema(description = "Données pour créer un album")
public record AlbumCreateRequest(

        @Schema(description = "Titre de l'album", example = "Racines du Golfe", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank(message = "Le titre est obligatoire")
        String title,

        @Schema(description = "Date de sortie — optionnel", example = "2024-03-15", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        LocalDate dateSortie,

        @Schema(description = "Nom du fichier de couverture — optionnel", example = "cover.jpg", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        String coverImage,

        @Schema(description = "ID de l'artiste propriétaire (déduit du token si omis)", example = "1", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        Long artisteId
) {}
