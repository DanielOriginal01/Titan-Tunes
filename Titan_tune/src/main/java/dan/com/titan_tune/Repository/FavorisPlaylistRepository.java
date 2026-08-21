package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.FavorisPlaylist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavorisPlaylistRepository extends JpaRepository<FavorisPlaylist, Long> {
    List<FavorisPlaylist> findByUtilisateurId(Long utilisateurId);
    Optional<FavorisPlaylist> findByUtilisateurIdAndPlaylistId(Long utilisateurId, Long idPlaylist);
}