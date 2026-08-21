package dan.com.titan_tune.entities;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "chansons")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Chansons {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String titre;

    private Integer duree;

    @Column(columnDefinition = "TEXT")
    private String parole;

    private String audioUrl;

    private String coverImage;

    @Builder.Default
    private Long nbEcoutes = 0L;

    private LocalDateTime addDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "artiste_id", nullable = false)
    private Artiste artiste;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "album_id")
    private Album album;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "categorie_id")
    private Categorie categorie;

    @PrePersist
    protected void onCreate() {
        this.addDate = LocalDateTime.now();
        if (this.nbEcoutes == null) {
            this.nbEcoutes = 0L;
        }
    }
}
