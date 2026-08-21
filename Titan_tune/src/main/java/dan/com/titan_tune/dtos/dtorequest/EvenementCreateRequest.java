package dan.com.titan_tune.dtos.dtorequest;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.LocalDateTime;

public record EvenementCreateRequest(
    @NotBlank(message = "Le nom du concert est obligatoire")
    String nameConcert,

    @NotNull(message = "La date de l'événement est obligatoire")
    @Future(message = "La date doit être dans le futur")
    LocalDateTime dateEvenement,

    LocalDateTime dateLimite,

    @NotBlank(message = "Le lieu est obligatoire")
    String lieu,

    @NotNull(message = "Le prix du ticket est obligatoire")
    @Positive(message = "Le prix doit être positif")
    Double prixTicket,

    @NotNull(message = "L'identifiant de l'artiste est obligatoire")
    Long artisteId
) {}