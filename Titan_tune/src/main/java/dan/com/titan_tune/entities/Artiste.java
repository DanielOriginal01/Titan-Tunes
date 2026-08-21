package dan.com.titan_tune.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "artistes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@EqualsAndHashCode(callSuper = true)
public class Artiste extends Utilisateur {

    @Column(nullable = false)
    private String artistName;

    @Column(length = 1000)
    private String bio;

    private String photoCouverture;
    private Boolean verifie;
}