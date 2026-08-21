package dan.com.titan_tune.security;

import dan.com.titan_tune.entities.Utilisateur;
import dan.com.titan_tune.enums.Statut;
import dan.com.titan_tune.repository.UtilisateurRepository;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UtilisateurRepository utilisateurRepository;

    public UserDetailsServiceImpl(UtilisateurRepository utilisateurRepository) {
        this.utilisateurRepository = utilisateurRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String emailOrUsername) throws UsernameNotFoundException {
        Utilisateur utilisateur = utilisateurRepository.findByEmail(emailOrUsername)
                .orElseGet(() -> utilisateurRepository.findByUsername(emailOrUsername)
                        .orElseThrow(() -> new UsernameNotFoundException(
                                "Utilisateur non trouvé : " + emailOrUsername)));

        // Bloque la connexion si le compte est inactif ou supprimé
        boolean enabled = utilisateur.getStatus() == Statut.ACTIF;

        return new User(
                utilisateur.getEmail(),
                utilisateur.getPassword(),
                enabled,          // enabled
                true,             // accountNonExpired
                true,             // credentialsNonExpired
                true,             // accountNonLocked
                Collections.singletonList(
                        new SimpleGrantedAuthority(utilisateur.getRole().name()))
        );
    }
}
