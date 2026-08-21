package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.FavorisArtiste;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavorisArtisteRepository extends JpaRepository<FavorisArtiste, Long> {
    List<FavorisArtiste> findByUtilisateurId(Long utilisateurId);
    Optional<FavorisArtiste> findByUtilisateurIdAndArtisteId(Long utilisateurId, Long artisteId);
}