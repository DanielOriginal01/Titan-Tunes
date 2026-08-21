package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Banniere;
import dan.com.titan_tune.enums.TypePromotion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface BanniereRepository extends JpaRepository<Banniere, Long> {

    List<Banniere> findByArtisteId(Long artisteId);

    List<Banniere> findByActiveTrue();

    List<Banniere> findByActiveTrueAndDateFinAfter(LocalDateTime now);

    List<Banniere> findByArtisteIdAndTypePromotion(Long artisteId, TypePromotion type);
}
