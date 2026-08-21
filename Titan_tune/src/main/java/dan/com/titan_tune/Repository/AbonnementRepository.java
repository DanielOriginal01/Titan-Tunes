package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Abonnement;
import dan.com.titan_tune.entities.Auditeur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AbonnementRepository extends JpaRepository<Abonnement, Long> {
    List<Abonnement> findByAuditeurId(Long auditeurId);
    List<Abonnement> findByAuditeurAndActiveTrue(Auditeur auditeur);
    boolean existsByAuditeurAndActiveTrueAndEndDateAfter(Auditeur auditeur, LocalDateTime now);
}