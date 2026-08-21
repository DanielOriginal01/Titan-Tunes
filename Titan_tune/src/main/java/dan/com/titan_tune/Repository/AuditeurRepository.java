package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Auditeur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AuditeurRepository extends JpaRepository<Auditeur, Long> {
}