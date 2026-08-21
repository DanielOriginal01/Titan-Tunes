package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.service.EmailService;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.from:no-reply@titan-tune.com}")
    private String fromAddress;

    @Value("${app.base-url:http://localhost:8080}")
    private String baseUrl;

    @Override
    @Async
    public void sendVerificationEmail(String to, String username, String verificationToken) {
        String verificationLink = baseUrl + "/api/v1/auth/verify?token=" + verificationToken;
        String subject = "Titan Tunes – Vérifiez votre adresse email";
        String htmlContent = buildVerificationEmailHtml(username, verificationLink);

        sendHtmlEmail(to, subject, htmlContent);
        log.info("Email de vérification envoyé à {}", to);
    }

    @Override
    @Async
    public void sendPasswordResetEmail(String to, String username, String resetToken) {
        // Le lien pointe vers le front-end qui présentera le formulaire de saisie du nouveau mot de passe.
        // Le front appellera ensuite POST /api/v1/auth/reset-password avec ce token.
        String resetLink = baseUrl + "/api/v1/auth/reset-password?token=" + resetToken;
        String subject = "Titan Tunes – Réinitialisation de votre mot de passe";
        String htmlContent = buildPasswordResetEmailHtml(username, resetLink);

        sendHtmlEmail(to, subject, htmlContent);
        log.info("Email de réinitialisation envoyé à {}", to);
    }

    // -------------------------------------------------------------------------
    // Méthode utilitaire d'envoi
    // -------------------------------------------------------------------------

    private void sendHtmlEmail(String to, String subject, String htmlContent) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(fromAddress);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true);
            mailSender.send(message);
        } catch (MessagingException e) {
            // On logue l'erreur sans la propager : l'inscription/reset ne doit pas
            // échouer à cause d'un problème SMTP. L'utilisateur peut redemander l'email.
            log.error("Échec de l'envoi de l'email à {} : {}", to, e.getMessage());
        } catch (Exception e) {
            log.error("Erreur inattendue lors de l'envoi de l'email à {} : {}", to, e.getMessage());
        }
    }

    // -------------------------------------------------------------------------
    // Templates HTML inline (pas de dépendance Thymeleaf requise)
    // -------------------------------------------------------------------------

    private String buildVerificationEmailHtml(String username, String verificationLink) {
        return """
                <!DOCTYPE html>
                <html lang="fr">
                <head>
                  <meta charset="UTF-8"/>
                  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                  <title>Vérification de votre email</title>
                </head>
                <body style="margin:0;padding:0;background-color:#0f0f0f;font-family:'Segoe UI',Arial,sans-serif;">
                  <table width="100%%" cellpadding="0" cellspacing="0" style="background-color:#0f0f0f;padding:40px 0;">
                    <tr>
                      <td align="center">
                        <table width="600" cellpadding="0" cellspacing="0"
                               style="background-color:#1a1a1a;border-radius:12px;overflow:hidden;max-width:600px;width:100%%;">
                          <!-- Header -->
                          <tr>
                            <td style="background:linear-gradient(135deg,#ff6b35,#f7c948);padding:36px 40px;text-align:center;">
                              <h1 style="margin:0;color:#ffffff;font-size:28px;font-weight:700;letter-spacing:1px;">
                                🎵 Titan Tunes
                              </h1>
                            </td>
                          </tr>
                          <!-- Body -->
                          <tr>
                            <td style="padding:40px 40px 20px;">
                              <h2 style="color:#ffffff;font-size:22px;margin:0 0 16px;">
                                Bonjour %s 👋
                              </h2>
                              <p style="color:#cccccc;font-size:15px;line-height:1.7;margin:0 0 24px;">
                                Merci de rejoindre <strong style="color:#f7c948;">Titan Tunes</strong> !
                                Pour activer votre compte, veuillez confirmer votre adresse email en cliquant sur le bouton ci-dessous.
                              </p>
                              <div style="text-align:center;margin:32px 0;">
                                <a href="%s"
                                   style="display:inline-block;background:linear-gradient(135deg,#ff6b35,#f7c948);
                                          color:#ffffff;text-decoration:none;font-weight:700;font-size:16px;
                                          padding:14px 36px;border-radius:8px;letter-spacing:0.5px;">
                                  Vérifier mon email
                                </a>
                              </div>
                              <p style="color:#888888;font-size:13px;line-height:1.6;margin:0 0 8px;">
                                Ce lien est valable pendant <strong>24 heures</strong>.
                                Si vous n'avez pas créé de compte sur Titan Tunes, ignorez simplement cet email.
                              </p>
                              <p style="color:#666666;font-size:12px;word-break:break-all;margin:0;">
                                Ou copiez ce lien dans votre navigateur :<br/>
                                <a href="%s" style="color:#f7c948;">%s</a>
                              </p>
                            </td>
                          </tr>
                          <!-- Footer -->
                          <tr>
                            <td style="padding:24px 40px;border-top:1px solid #2a2a2a;text-align:center;">
                              <p style="color:#555555;font-size:12px;margin:0;">
                                © 2026 Titan Tunes · Tous droits réservés
                              </p>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>
                </body>
                </html>
                """.formatted(username, verificationLink, verificationLink, verificationLink);
    }

    private String buildPasswordResetEmailHtml(String username, String resetLink) {
        return """
                <!DOCTYPE html>
                <html lang="fr">
                <head>
                  <meta charset="UTF-8"/>
                  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                  <title>Réinitialisation de mot de passe</title>
                </head>
                <body style="margin:0;padding:0;background-color:#0f0f0f;font-family:'Segoe UI',Arial,sans-serif;">
                  <table width="100%%" cellpadding="0" cellspacing="0" style="background-color:#0f0f0f;padding:40px 0;">
                    <tr>
                      <td align="center">
                        <table width="600" cellpadding="0" cellspacing="0"
                               style="background-color:#1a1a1a;border-radius:12px;overflow:hidden;max-width:600px;width:100%%;">
                          <!-- Header -->
                          <tr>
                            <td style="background:linear-gradient(135deg,#ff6b35,#f7c948);padding:36px 40px;text-align:center;">
                              <h1 style="margin:0;color:#ffffff;font-size:28px;font-weight:700;letter-spacing:1px;">
                                🎵 Titan Tunes
                              </h1>
                            </td>
                          </tr>
                          <!-- Body -->
                          <tr>
                            <td style="padding:40px 40px 20px;">
                              <h2 style="color:#ffffff;font-size:22px;margin:0 0 16px;">
                                Bonjour %s 👋
                              </h2>
                              <p style="color:#cccccc;font-size:15px;line-height:1.7;margin:0 0 24px;">
                                Vous avez demandé la réinitialisation de votre mot de passe
                                <strong style="color:#f7c948;">Titan Tunes</strong>.
                                Cliquez sur le bouton ci-dessous pour choisir un nouveau mot de passe.
                              </p>
                              <div style="text-align:center;margin:32px 0;">
                                <a href="%s"
                                   style="display:inline-block;background:linear-gradient(135deg,#ff6b35,#f7c948);
                                          color:#ffffff;text-decoration:none;font-weight:700;font-size:16px;
                                          padding:14px 36px;border-radius:8px;letter-spacing:0.5px;">
                                  Réinitialiser mon mot de passe
                                </a>
                              </div>
                              <p style="color:#888888;font-size:13px;line-height:1.6;margin:0 0 8px;">
                                Ce lien expire dans <strong>1 heure</strong>.
                                Si vous n'êtes pas à l'origine de cette demande, ignorez cet email
                                — votre mot de passe restera inchangé.
                              </p>
                              <p style="color:#666666;font-size:12px;word-break:break-all;margin:0;">
                                Ou copiez ce lien dans votre navigateur :<br/>
                                <a href="%s" style="color:#f7c948;">%s</a>
                              </p>
                            </td>
                          </tr>
                          <!-- Footer -->
                          <tr>
                            <td style="padding:24px 40px;border-top:1px solid #2a2a2a;text-align:center;">
                              <p style="color:#555555;font-size:12px;margin:0;">
                                © 2026 Titan Tunes · Tous droits réservés
                              </p>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>
                </body>
                </html>
                """.formatted(username, resetLink, resetLink, resetLink);
    }
}
