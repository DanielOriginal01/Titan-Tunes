package dan.com.titan_tune.dtos.dtorequest;

import dan.com.titan_tune.enums.TypePromotion;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

public record BanniereRequest(
        @NotBlank(message = "Le titre est obligatoire")
        String titre,

        String description,

        /** Lien de redirection vers l'album ou la chanson promue. */
        String lienCible,

        @NotNull(message = "Le type de promotion est obligatoire")
        TypePromotion typePromotion,

        @NotNull(message = "L'identifiant de l'artiste est obligatoire")
        Long artisteId,

        /** Album promu — optionnel. */
        Long albumId,

        /** Chanson promue — optionnel. */
        Long chansonId,

        LocalDateTime dateDebut,
        LocalDateTime dateFin
) {}
