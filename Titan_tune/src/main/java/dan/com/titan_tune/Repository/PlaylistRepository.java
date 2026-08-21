package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Playlist;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlaylistRepository extends JpaRepository<Playlist, Long> {
    List<Playlist> findByAuditeurId(Long auditeurId);
    Page<Playlist> findByAuditeurId(Long auditeurId, Pageable pageable);

    List<Playlist> findByPriveeFalse();
    Page<Playlist> findByPriveeFalse(Pageable pageable);

    List<Playlist> findByPriveeFalseAndTitleContainingIgnoreCase(String titre);
    Page<Playlist> findByPriveeFalseAndTitleContainingIgnoreCase(String titre, Pageable pageable);
}