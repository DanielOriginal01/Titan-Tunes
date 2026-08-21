package dan.com.titan_tune.dtos.dtorequest;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * DTO pour créer une notification système (ADMIN uniquement).
 * Remplace l'injection directe de l'entité Notification pour éviter
 * la manipulation de champs internes (dateEnvoie, lu, etc.).
 */
public record NotificationCreateRequest(
        @NotBlank(message = "Le titre est obligatoire")
        String titre,

        @NotBlank(message = "Le message est obligatoire")
        String message,

        @NotNull(message = "L'ID de l'auditeur destinataire est obligatoire")
        Long auditeurId
) {}
