package dan.com.titan_tune.dtos.dtorequest;

import dan.com.titan_tune.enums.Role;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@Schema(description = "Données d'inscription d'un nouvel utilisateur")
public record RegisterRequest(

        @Schema(description = "Nom d'utilisateur unique", example = "kofi_beats", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank(message = "Le nom d'utilisateur est obligatoire")
        @Size(min = 3, max = 50, message = "Le nom d'utilisateur doit avoir entre 3 et 50 caractères")
        String username,

        @Schema(description = "Adresse email unique", example = "kofi@music.tg", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank(message = "L'email est obligatoire")
        @Email(message = "Format d'email invalide")
        String email,

        @Schema(description = "Mot de passe (min. 6 caractères)", example = "MonMotDePasse2026!", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotBlank(message = "Le mot de passe est obligatoire")
        @Size(min = 6, message = "Le mot de passe doit contenir au moins 6 caractères")
        String password,

        @Schema(description = "Numéro de téléphone — optionnel", example = "+22891000001", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        String telephone,

        @Schema(description = "Rôle : ROLE_AUDITEUR ou ROLE_ARTISTE", example = "ROLE_AUDITEUR", requiredMode = Schema.RequiredMode.REQUIRED)
        @NotNull(message = "Le rôle est obligatoire")
        Role role,

        @Schema(description = "Nom d'artiste — obligatoire uniquement si role = ROLE_ARTISTE", example = "Kofi Mensah", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
        String artistName
) {}
