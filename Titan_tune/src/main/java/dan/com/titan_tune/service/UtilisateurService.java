package dan.com.titan_tune.service;

import dan.com.titan_tune.entities.Admin;
import dan.com.titan_tune.entities.Artiste;
import dan.com.titan_tune.entities.Auditeur;
import dan.com.titan_tune.entities.Utilisateur;
import dan.com.titan_tune.enums.Role;
import dan.com.titan_tune.enums.Statut;
import dan.com.titan_tune.exception.UserAlreadyExistsException;
import dan.com.titan_tune.repository.UtilisateurRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class UtilisateurService {

    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;

    public Utilisateur enregistrerUtilisateur(String email, String password, String username, Role role) {
        if (utilisateurRepository.findByEmail(email).isPresent()) {
            throw new UserAlreadyExistsException("Un compte existe déjà pour cet email.");
        }

        Utilisateur utilisateur = creerUtilisateurConcret(email, password, username, role);
        utilisateur.setCreatedAt(LocalDateTime.now());
        utilisateur.setUpdatedAt(LocalDateTime.now());

        return utilisateurRepository.save(utilisateur);
    }

    private Utilisateur creerUtilisateurConcret(String email, String password, String username, Role role) {
        String encodedPassword = passwordEncoder.encode(password);

        return switch (role) {
            case ROLE_ARTISTE -> Artiste.builder()
                    .username(username)
                    .email(email)
                    .password(encodedPassword)
                    .role(Role.ROLE_ARTISTE)
                    .status(Statut.TELECHARGE)
                    .artistName(username)
                    .bio(null)
                    .photoProfil(null)
                    .photoCouverture(null)
                    .verifie(false)
                    .build();
            case ROLE_AUDITEUR -> Auditeur.builder()
                    .username(username)
                    .email(email)
                    .password(encodedPassword)
                    .role(Role.ROLE_AUDITEUR)
                    .status(Statut.TELECHARGE)
                    .photoProfil(null)
                    .abonnementActif(false)
                    .build();
            case ROLE_ADMIN -> Admin.builder()
                    .username(username)
                    .email(email)
                    .password(encodedPassword)
                    .role(Role.ROLE_ADMIN)
                    .status(Statut.TELECHARGE)
                    .photoProfil(null)
                    .niveauAcces("SUPER_ADMIN")
                    .build();
            default -> throw new IllegalArgumentException("Rôle utilisateur inconnu : " + role);
        };
    }
}
