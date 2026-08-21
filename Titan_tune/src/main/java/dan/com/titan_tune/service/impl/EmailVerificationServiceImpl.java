package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.EmailRequest;
import dan.com.titan_tune.dtos.dtorequest.PasswordResetRequest;
import dan.com.titan_tune.dtos.dtoresponse.AccountRecoveryResponse;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.repository.UtilisateurRepository;
import dan.com.titan_tune.service.EmailService;
import dan.com.titan_tune.service.EmailVerificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EmailVerificationServiceImpl implements EmailVerificationService {

    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final dan.com.titan_tune.service.RefreshTokenService refreshTokenService;

    /**
     * Demande un (re)envoi de l'email de vérification.
     * Génère un nouveau token et envoie l'email même si le précédent a expiré ou été perdu.
     */
    @Override
    @Transactional
    public AccountRecoveryResponse requestEmailVerification(String email) {
        var user = utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new BusinessException("Aucun compte trouvé pour cet email"));

        if (user.isEmailVerified()) {
            return new AccountRecoveryResponse("Votre email est déjà vérifié.", true);
        }

        // Génère un nouveau token et le persiste
        String token = UUID.randomUUID().toString();
        user.setVerificationToken(token);
        utilisateurRepository.save(user);

        // Envoie l'email de vérification (async)
        emailService.sendVerificationEmail(user.getEmail(), user.getUsername(), token);

        return new AccountRecoveryResponse(
                "Un email de vérification a été envoyé à " + email,
                true
        );
    }

    /**
     * Valide le token de vérification reçu par email et active le compte.
     */
    @Override
    @Transactional
    public AccountRecoveryResponse verifyEmail(String token) {
        var user = utilisateurRepository.findByVerificationToken(token)
                .orElseThrow(() -> new BusinessException("Token de vérification invalide ou déjà utilisé."));

        user.setEmailVerified(true);
        user.setVerificationToken(null);
        user.setEmailVerifiedAt(LocalDateTime.now());
        utilisateurRepository.save(user);

        return new AccountRecoveryResponse("Votre email a été vérifié avec succès.", true);
    }

    /**
     * Génère un token de reset, le persiste, et envoie l'email de réinitialisation.
     */
    @Override
    @Transactional
    public AccountRecoveryResponse requestPasswordReset(EmailRequest request) {
        var user = utilisateurRepository.findByEmail(request.email())
                .orElseThrow(() -> new BusinessException("Aucun compte trouvé pour cet email"));

        String token = UUID.randomUUID().toString();
        user.setPasswordResetToken(token);
        user.setPasswordResetExpiresAt(LocalDateTime.now().plusHours(1));
        utilisateurRepository.save(user);

        // Envoie l'email avec le lien de reset (async)
        emailService.sendPasswordResetEmail(user.getEmail(), user.getUsername(), token);

        return new AccountRecoveryResponse(
                "Un email de réinitialisation a été envoyé à " + request.email() + ". Le lien expire dans 1 heure.",
                true
        );
    }

    /**
     * Valide le token de reset et applique le nouveau mot de passe.
     */
    @Override
    @Transactional
    public AccountRecoveryResponse resetPassword(PasswordResetRequest request) {
        var user = utilisateurRepository.findByPasswordResetToken(request.token())
                .orElseThrow(() -> new BusinessException("Token de récupération invalide ou déjà utilisé."));

        if (user.getPasswordResetExpiresAt() == null
                || user.getPasswordResetExpiresAt().isBefore(LocalDateTime.now())) {
            throw new BusinessException("Le lien de réinitialisation a expiré. Veuillez en demander un nouveau.");
        }

        user.setPassword(passwordEncoder.encode(request.password()));
        user.setPasswordResetToken(null);
        user.setPasswordResetExpiresAt(null);
        utilisateurRepository.save(user);

        // Révoquer les refresh tokens existants pour forcer une nouvelle authentification
        refreshTokenService.revokeByUserId(user.getId());

        return new AccountRecoveryResponse("Votre mot de passe a été réinitialisé avec succès.", true);
    }
}
