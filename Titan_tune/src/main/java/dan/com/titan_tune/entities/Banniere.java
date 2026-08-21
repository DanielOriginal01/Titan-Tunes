package dan.com.titan_tune.entities;

import dan.com.titan_tune.enums.TypePromotion;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * Bannière promotionnelle liée à un artiste.
 * Permet de mettre en avant une sortie d'album ou de single.
 */
@Entity
@Table(name = "bannieres")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Banniere {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String titre;

    @Column(columnDefinition = "TEXT")
    private String description;

    /** URL de l'image de la bannière stockée dans MinIO. */
    private String imageUrl;

    /** Lien de redirection (vers l'album ou la chanson concernée). */
    private String lienCible;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TypePromotion typePromotion;

    @Column(nullable = false)
    private boolean active;

    private LocalDateTime dateDebut;
    private LocalDateTime dateFin;
    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "artiste_id", nullable = false)
    private Artiste artiste;

    /** Album promu (optionnel). */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "album_id")
    private Album album;

    /** Single/chanson promu(e) (optionnel). */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chanson_id")
    private Chansons chanson;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.active) return;
        this.active = false;
    }
}
