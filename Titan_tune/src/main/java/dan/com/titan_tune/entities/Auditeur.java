package dan.com.titan_tune.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
// cspell:disable-next-line
@Table(name = "auditeurs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@EqualsAndHashCode(callSuper = true)
public class Auditeur extends Utilisateur {
    private Boolean abonnementActif;
}