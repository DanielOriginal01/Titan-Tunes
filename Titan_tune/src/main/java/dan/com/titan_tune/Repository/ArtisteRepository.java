package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Artiste;
import dan.com.titan_tune.enums.Statut;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ArtisteRepository extends JpaRepository<Artiste, Long> {
    List<Artiste> findByVerifieFalse();
    Page<Artiste> findByVerifieFalse(Pageable pageable);

    List<Artiste> findByArtistNameContainingIgnoreCaseOrUsernameContainingIgnoreCase(String artistName, String username);
    Page<Artiste> findByArtistNameContainingIgnoreCaseOrUsernameContainingIgnoreCase(String artistName, String username, Pageable pageable);

    List<Artiste> findByArtistNameContainingIgnoreCaseOrUsernameContainingIgnoreCaseAndStatus(String artistName, String username, Statut status);
    Page<Artiste> findByArtistNameContainingIgnoreCaseOrUsernameContainingIgnoreCaseAndStatus(String artistName, String username, Statut status, Pageable pageable);

    Page<Artiste> findByStatus(Statut status, Pageable pageable);
}