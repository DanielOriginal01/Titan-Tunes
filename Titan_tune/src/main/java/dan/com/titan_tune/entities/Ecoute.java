package dan.com.titan_tune.entities;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "ecoutes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Ecoute {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chanson_id", nullable = false)
    private Chansons chanson;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "auditeur_id", nullable = false)
    private Auditeur auditeur;

    private Integer dureeEcoute;

    private LocalDateTime listenedAt;

    @PrePersist
    protected void onCreate() {
        if (this.listenedAt == null) {
            this.listenedAt = LocalDateTime.now();
        }
    }
}