package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.RefreshToken;
import dan.com.titan_tune.entities.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.Optional;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {

    Optional<RefreshToken> findByToken(String token);

    Optional<RefreshToken> findByUtilisateur(Utilisateur utilisateur);

    Optional<RefreshToken> findByUtilisateurId(Long utilisateurId);

    @Modifying
    @Query("DELETE FROM RefreshToken r WHERE r.utilisateur = :utilisateur")
    void deleteByUtilisateur(@Param("utilisateur") Utilisateur utilisateur);

    @Modifying
    @Query("DELETE FROM RefreshToken r WHERE r.utilisateur.id = :utilisateurId")
    void deleteByUtilisateurId(@Param("utilisateurId") Long utilisateurId);

    @Modifying
    @Query("DELETE FROM RefreshToken r WHERE r.expiryDate < :now")
    void deleteByExpiryDateBefore(@Param("now") Instant now);
}
