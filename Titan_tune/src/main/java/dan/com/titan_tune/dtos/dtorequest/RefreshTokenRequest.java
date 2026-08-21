package dan.com.titan_tune.dtos.dtorequest;

import jakarta.validation.constraints.NotBlank;

public record RefreshTokenRequest(
    @NotBlank(message = "Le refresh token est obligatoire.")
    String refreshToken
) {}
