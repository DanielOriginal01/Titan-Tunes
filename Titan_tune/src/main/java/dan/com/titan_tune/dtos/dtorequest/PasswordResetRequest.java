package dan.com.titan_tune.dtos.dtorequest;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record PasswordResetRequest(
    @NotBlank(message = "Le token de récupération est obligatoire")
    String token,

    @NotBlank(message = "Le mot de passe est obligatoire")
    @Size(min = 6, message = "Le mot de passe doit contenir au moins 6 caractères")
    String password
) {}
