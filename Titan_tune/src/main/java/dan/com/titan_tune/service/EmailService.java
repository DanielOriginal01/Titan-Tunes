package dan.com.titan_tune.service;

/**
 * Service responsable de l'envoi physique des emails (vérification et reset de mot de passe).
 */
public interface EmailService {

    /**
     * Envoie un email de vérification d'adresse email.
     *
     * @param to               adresse du destinataire
     * @param username         nom d'utilisateur (pour personnaliser le message)
     * @param verificationToken token à inclure dans le lien de vérification
     */
    void sendVerificationEmail(String to, String username, String verificationToken);

    /**
     * Envoie un email de réinitialisation de mot de passe.
     *
     * @param to               adresse du destinataire
     * @param username         nom d'utilisateur
     * @param resetToken       token à inclure dans le lien de reset
     */
    void sendPasswordResetEmail(String to, String username, String resetToken);
}
