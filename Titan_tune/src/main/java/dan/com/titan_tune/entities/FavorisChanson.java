package dan.com.titan_tune.entities;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "favoris_chanson")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@EqualsAndHashCode(callSuper = true)
public class FavorisChanson extends Favoris {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chanson_id", nullable = false)
    private Chansons chanson;
}