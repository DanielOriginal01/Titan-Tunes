package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Reversement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReversementRepository extends JpaRepository<Reversement, Long> {

    List<Reversement> findByArtisteId(Long artisteId);
    Page<Reversement> findByArtisteId(Long artisteId, Pageable pageable);

    List<Reversement> findByArtisteIdAndStatut(Long artisteId, String statut);
    Page<Reversement> findByArtisteIdAndStatut(Long artisteId, String statut, Pageable pageable);

    List<Reversement> findByLabelIdLabel(Long labelId);
    Page<Reversement> findByLabelIdLabel(Long labelId, Pageable pageable);

    /** Total reversé à un artiste (tous statuts confondus). */
    @Query("SELECT COALESCE(SUM(r.montant), 0) FROM Reversement r WHERE r.artiste.id = :artisteId AND r.statut = 'VERSE'")
    Double sumMontantVerseByArtisteId(@Param("artisteId") Long artisteId);

    /** Vérifie si un reversement a déjà été calculé pour une période donnée. */
    boolean existsByArtisteIdAndPeriode(Long artisteId, String periode);
}
