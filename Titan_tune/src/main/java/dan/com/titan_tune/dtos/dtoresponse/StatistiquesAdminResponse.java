package dan.com.titan_tune.dtos.dtoresponse;

public record StatistiquesAdminResponse(
    Long totalUtilisateurs,
    Long totalArtistes,
    Long totalAuditeurs,
    Double totalRevenus
) {}