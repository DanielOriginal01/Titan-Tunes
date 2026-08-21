package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Paiement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PaiementRepository extends JpaRepository<Paiement, Long> {
    List<Paiement> findByAuditeurId(Long auditeurId);
    Page<Paiement> findByAuditeurId(Long auditeurId, Pageable pageable);

    Optional<Paiement> findByIdempotencyKey(String idempotencyKey);
    List<Paiement> findByAuditeurIdAndStatut(Long auditeurId, String statut);
    Page<Paiement> findByAuditeurIdAndStatut(Long auditeurId, String statut, Pageable pageable);
}