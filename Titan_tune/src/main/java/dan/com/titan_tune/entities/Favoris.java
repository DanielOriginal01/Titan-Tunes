package dan.com.titan_tune.entities;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@Entity
@Table(name = "favoris")
@Inheritance(strategy = InheritanceType.JOINED)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public abstract class Favoris {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idFav;

    private LocalDateTime dateAjout;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    @PrePersist
    protected void onCreate() {
        this.dateAjout = LocalDateTime.now();
    }
}