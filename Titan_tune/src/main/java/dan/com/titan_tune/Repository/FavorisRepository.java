package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Favoris;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FavorisRepository extends JpaRepository<Favoris, Long> {
    List<Favoris> findByUtilisateurId(Long utilisateurId);
}