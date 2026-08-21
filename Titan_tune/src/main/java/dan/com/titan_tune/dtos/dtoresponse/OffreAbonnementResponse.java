package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.enums.OffreAbonnement;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Arrays;
import java.util.List;

@Schema(description = "Détail d'une offre d'abonnement disponible")
public record OffreAbonnementResponse(

        @Schema(description = "Code de l'offre à utiliser lors de la souscription", example = "MONTHLY")
        String code,

        @Schema(description = "Nom commercial de l'offre", example = "Offre Mensuelle")
        String label,

        @Schema(description = "Prix en FCFA", example = "2000.0")
        double prixFcfa,

        @Schema(description = "Durée en jours", example = "30")
        int dureeDays,

        @Schema(description = "Description marketing de l'offre")
        String description,

        @Schema(description = "Liste des avantages inclus")
        List<String> avantages,

        @Schema(description = "Prix par jour en FCFA (indicatif)", example = "66.67")
        double prixParJour

) {
    public static OffreAbonnementResponse fromEnum(OffreAbonnement offre) {
        return new OffreAbonnementResponse(
                offre.getCode(),
                offre.getLabel(),
                offre.getPrixFcfa(),
                offre.getDureeDays(),
                offre.getDescription(),
                Arrays.asList(offre.getAvantages()),
                Math.round((offre.getPrixFcfa() / offre.getDureeDays()) * 100.0) / 100.0
        );
    }
}
