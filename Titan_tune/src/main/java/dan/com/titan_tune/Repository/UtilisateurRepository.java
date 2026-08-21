package dan.com.titan_tune.repository;

import dan.com.titan_tune.entities.Utilisateur;
import dan.com.titan_tune.enums.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UtilisateurRepository extends JpaRepository<Utilisateur, Long> {
    Optional<Utilisateur> findByEmail(String email);
    Optional<Utilisateur> findByUsername(String username);
    Optional<Utilisateur> findByVerificationToken(String verificationToken);
    Optional<Utilisateur> findByPasswordResetToken(String passwordResetToken);
    Optional<Utilisateur> findByProviderId(String providerId);
    Boolean existsByEmail(String email);
    Boolean existsByUsername(String username);
    boolean existsByRole(Role role);
    long countByRole(Role role);
}