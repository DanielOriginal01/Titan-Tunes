package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Album;
import dan.com.titan_tune.entities.Artiste;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AlbumRepository extends JpaRepository<Album, Long> {
    Page<Album> findByArtiste(Artiste artiste, Pageable pageable);
    Page<Album> findByTitleContainingIgnoreCase(String title, Pageable pageable);
    List<Album> findByTitleContainingIgnoreCase(String title);
    List<Album> findByArtisteId(Long artisteId);
    Page<Album> findByArtisteId(Long artisteId, Pageable pageable);
}
