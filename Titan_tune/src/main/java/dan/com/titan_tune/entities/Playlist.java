package dan.com.titan_tune.entities;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "playlists")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Playlist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    private String description;

    private boolean privee;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "auditeur_id")
    private Auditeur auditeur;

    @ManyToMany
    @JoinTable(
        name = "playlist_chansons",
        joinColumns = @JoinColumn(name = "playlist_id"),
        inverseJoinColumns = @JoinColumn(name = "chanson_id")
    )
    @Builder.Default
    private List<Chansons> chansons = new ArrayList<>();
}