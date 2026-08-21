package dan.com.titan_tune.entities;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idNot;

    private String titre;

    @Column(columnDefinition = "TEXT")
    private String message;

    private LocalDateTime dateEnvoie;
    private Boolean lu;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "auditeur_id", nullable = false)
    private Auditeur auditeur;

    @PrePersist
    protected void onCreate() {
        this.dateEnvoie = LocalDateTime.now();
        this.lu = false;
    }
}