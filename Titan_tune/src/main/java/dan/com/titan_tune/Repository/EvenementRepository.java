package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Evenement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EvenementRepository extends JpaRepository<Evenement, Long> {
    List<Evenement> findByArtisteId(Long artisteId);
    Page<Evenement> findByArtisteId(Long artisteId, Pageable pageable);
}