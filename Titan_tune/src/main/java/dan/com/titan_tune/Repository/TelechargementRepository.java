package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Telechargement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TelechargementRepository extends JpaRepository<Telechargement, Long> {
    List<Telechargement> findByAuditeurId(Long auditeurId);
    List<Telechargement> findByChansonId(Long chansonId);
}