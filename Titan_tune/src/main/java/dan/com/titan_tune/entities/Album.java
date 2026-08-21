package dan.com.titan_tune.entities;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "albums")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Album {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    private LocalDate dateSortie;

    private String coverImage;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "artiste_id")
    private Artiste artiste;

    @OneToMany(mappedBy = "album", cascade = CascadeType.ALL)
    @Builder.Default
    private List<Chansons> chansons = new ArrayList<>();
}