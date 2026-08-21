package dan.com.titan_tune.dtos.dtorequest;

import jakarta.validation.constraints.Size;

public record UpdateProfileRequest(
    @Size(min = 3, max = 50)
    String username,
    String telephone,
    String bio,
    String photoProfil
) {}