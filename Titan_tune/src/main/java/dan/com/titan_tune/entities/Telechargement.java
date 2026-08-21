package dan.com.titan_tune.entities;

import dan.com.titan_tune.enums.Statut;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "telechargements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Telechargement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idTele;

    private LocalDateTime dateTelecharger;

    @Enumerated(EnumType.STRING)
    private Statut status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "auditeur_id", nullable = false)
    private Auditeur auditeur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chanson_id", nullable = false)
    private Chansons chanson;

    @PrePersist
    protected void onCreate() {
        this.dateTelecharger = LocalDateTime.now();
        if (this.status == null) this.status = Statut.TELECHARGE;
    }
}