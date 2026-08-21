package dan.com.titan_tune.dtos.dtorequest;

import jakarta.validation.constraints.NotNull;

public record TelechargementRequest(
    @NotNull(message = "L'identifiant de la chanson est obligatoire")
    Long chansonId,

    @NotNull(message = "L'identifiant de l'auditeur est obligatoire")
    Long auditeurId
) {}