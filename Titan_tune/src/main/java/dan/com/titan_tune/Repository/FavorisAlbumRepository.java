package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.FavorisAlbum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavorisAlbumRepository extends JpaRepository<FavorisAlbum, Long> {
    List<FavorisAlbum> findByUtilisateurId(Long utilisateurId);
    Optional<FavorisAlbum> findByUtilisateurIdAndAlbumId(Long utilisateurId, Long idAlbum);
}