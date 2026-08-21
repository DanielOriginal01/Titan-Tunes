package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Ecoute;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EcouteRepository extends JpaRepository<Ecoute, Long> {
    List<Ecoute> findByAuditeurId(Long auditeurId);
    Page<Ecoute> findByAuditeurId(Long auditeurId, Pageable pageable);

    Long countByChansonId(Long idChanson);

    /** Total des écoutes de toutes les chansons d'un artiste. */
    Long countByChansonArtisteId(Long artisteId);

    /** Nombre d'auditeurs distincts ayant écouté les chansons d'un artiste. */
    long countDistinctAuditeurByChansonArtisteId(Long artisteId);
}