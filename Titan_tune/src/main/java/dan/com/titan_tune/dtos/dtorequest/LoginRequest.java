package dan.com.titan_tune.dtos.dtorequest;

import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
    @NotBlank(message = "L'identifiant est obligatoire")
    String emailOuUsername,

    @NotBlank(message = "Le mot de passe est obligatoire")
    String password
) {}