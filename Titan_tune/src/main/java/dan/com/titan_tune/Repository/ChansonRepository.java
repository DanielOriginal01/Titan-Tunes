package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Chansons;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChansonRepository extends JpaRepository<Chansons, Long> {

    List<Chansons> findByArtisteId(Long artisteId);
    Page<Chansons> findByArtisteId(Long artisteId, Pageable pageable);

    List<Chansons> findByAlbumId(Long albumId);
    Page<Chansons> findByAlbumId(Long albumId, Pageable pageable);

    List<Chansons> findByCategorieId(Long categorieId);
    Page<Chansons> findByCategorieId(Long categorieId, Pageable pageable);

    List<Chansons> findByTitreContainingIgnoreCase(String titre);
    Page<Chansons> findByTitreContainingIgnoreCase(String titre, Pageable pageable);

    @Query("SELECT c FROM Chansons c WHERE LOWER(c.titre) LIKE LOWER(CONCAT('%', :q, '%')) OR LOWER(c.artiste.artistName) LIKE LOWER(CONCAT('%', :q, '%'))")
    List<Chansons> searchByTitreOrArtiste(@Param("q") String q);

    @Query("SELECT c FROM Chansons c WHERE (LOWER(c.titre) LIKE LOWER(CONCAT('%', :q, '%')) OR LOWER(c.artiste.artistName) LIKE LOWER(CONCAT('%', :q, '%'))) AND c.artiste.status = dan.com.titan_tune.enums.Statut.ACTIF")
    List<Chansons> searchByTitreOrArtisteActif(@Param("q") String q);

    @Query("SELECT c FROM Chansons c WHERE LOWER(c.titre) LIKE LOWER(CONCAT('%', :q, '%')) OR LOWER(c.artiste.artistName) LIKE LOWER(CONCAT('%', :q, '%'))")
    Page<Chansons> searchByTitreOrArtiste(@Param("q") String q, Pageable pageable);

    long countByArtisteId(Long artisteId);

    @Query("SELECT c FROM Chansons c ORDER BY c.nbEcoutes DESC")
    List<Chansons> findTopTendances();

    @Query("SELECT c FROM Chansons c ORDER BY c.nbEcoutes DESC")
    Page<Chansons> findTopTendances(Pageable pageable);

    /** Incrémente atomiquement le compteur d'écoutes d'une chanson. */
    @Modifying
    @Query("UPDATE Chansons c SET c.nbEcoutes = c.nbEcoutes + 1 WHERE c.id = :chansonId")
    void incrementNbEcoutes(@Param("chansonId") Long chansonId);
}