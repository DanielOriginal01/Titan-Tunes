package dan.com.titan_tune.entities;

import dan.com.titan_tune.enums.ModePaiement;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "paiements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Paiement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idPaiement;

    /** Montant payé en FCFA. */
    private Double montant;

    /** Date et heure du paiement. */
    private LocalDateTime datePaid;

    @Enumerated(EnumType.STRING)
    private ModePaiement modePaiement;

    /** Nom complet de l'opérateur (ex. "Moov Africa Togo (FLOOZ)"). */
    private String operateur;

    /** Statut : SUCCES | ECHEC. */
    private String statut;

    /** Référence unique générée par l'opérateur simulé (ex. FLZ-202608131045-A3B7C2). */
    @Column(unique = true)
    private String transactionRef;

    /** Message descriptif retourné par l'opérateur. */
    @Column(columnDefinition = "TEXT")
    private String message;

    /** Clé d'idempotence pour éviter les doubles paiements. */
    @Column(unique = true)
    private String idempotencyKey;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "auditeur_id", nullable = false)
    private Auditeur auditeur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "abonnement_id")
    private Abonnement abonnement;

    @PrePersist
    protected void onCreate() {
        this.datePaid = LocalDateTime.now();
    }
}
