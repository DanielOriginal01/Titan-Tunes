package dan.com.titan_tune.entities;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "evenements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Evenement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idEvenement;

    @Column(nullable = false)
    private String nameConcert;

    private LocalDateTime dateEvenement;
    private LocalDateTime dateLimite;
    private String lieu;
    private Double prixTicket;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "artiste_id", nullable = false)
    private Artiste artiste;
}