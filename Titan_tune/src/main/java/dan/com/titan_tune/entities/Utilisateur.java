package dan.com.titan_tune.entities;

import dan.com.titan_tune.enums.OAuthProvider;
import dan.com.titan_tune.enums.Role;
import dan.com.titan_tune.enums.Statut;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@Entity
@Table(name = "utilisateurs")
@Inheritance(strategy = InheritanceType.JOINED)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public abstract class Utilisateur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    private String telephone;

    private String photoProfil;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Statut status;

    @Column(nullable = false, columnDefinition = "boolean default false")
    private boolean emailVerified = false;

    @Column(unique = true)
    private String verificationToken;

    private LocalDateTime emailVerifiedAt;

    @Column(unique = true)
    private String passwordResetToken;

    private LocalDateTime passwordResetExpiresAt;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // ── Champs OAuth2 ─────────────────────────────────────────────────────────

    /** Fournisseur d'identité : LOCAL, GOOGLE ou FACEBOOK. */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OAuthProvider provider = OAuthProvider.LOCAL;

    /** ID unique fourni par Google/Facebook (sub pour Google, id pour Facebook). */
    @Column(unique = true)
    private String providerId;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.status == null) {
            this.status = Statut.ACTIF;
        }
        if (this.provider == null) {
            this.provider = OAuthProvider.LOCAL;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}