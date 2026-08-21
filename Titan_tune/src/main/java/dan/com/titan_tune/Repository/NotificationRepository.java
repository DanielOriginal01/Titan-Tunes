package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByAuditeurId(Long auditeurId);
    Page<Notification> findByAuditeurId(Long auditeurId, Pageable pageable);

    List<Notification> findByLuFalse();
    Page<Notification> findByLuFalse(Pageable pageable);
}