package dan.com.titan_tune.entities;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Reversement de revenus à un artiste ou un label.
 * Calculé à partir des paiements d'abonnements, au prorata du catalogue.
 */
@Entity
@Table(name = "reversements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Reversement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Double montant;

    /** Période couverte : mois/année (ex. 2026-08). */
    private String periode;

    @Column(nullable = false)
    private LocalDate dateVersement;

    /** Statut : EN_ATTENTE, VERSE, ECHEC */
    @Column(nullable = false)
    private String statut;

    private String reference;
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "artiste_id", nullable = false)
    private Artiste artiste;

    /** Label associé à l'artiste (peut être null si artiste indépendant). */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "label_id")
    private Label label;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.statut == null) this.statut = "EN_ATTENTE";
        if (this.dateVersement == null) this.dateVersement = LocalDate.now();
    }
}
