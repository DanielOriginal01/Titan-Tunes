package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.FavorisChanson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavorisChansonRepository extends JpaRepository<FavorisChanson, Long> {
    List<FavorisChanson> findByUtilisateurId(Long utilisateurId);
    Optional<FavorisChanson> findByUtilisateurIdAndChansonId(Long utilisateurId, Long idChanson);
    Boolean existsByUtilisateurIdAndChansonId(Long utilisateurId, Long idChanson);
}