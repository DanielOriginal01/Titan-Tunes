package dan.com.titan_tune.dtos.dtorequest;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record EmailRequest(
    @NotBlank(message = "L'email est obligatoire")
    @Email(message = "Format d'email invalide")
    String email
) {}
