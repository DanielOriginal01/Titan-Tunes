package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.entities.Notification;
import dan.com.titan_tune.enums.TypePromotion;
import dan.com.titan_tune.repository.AuditeurRepository;
import dan.com.titan_tune.repository.NotificationRepository;
import dan.com.titan_tune.service.NotificationPromoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationPromoServiceImpl implements NotificationPromoService {

    private final NotificationRepository notificationRepository;
    private final AuditeurRepository     auditeurRepository;

    /**
     * Crée une notification en base pour CHAQUE auditeur de la plateforme.
     * Exécuté en mode @Async pour ne pas bloquer la réponse HTTP.
     */
    @Async
    @Override
    @Transactional
    public void notifierSortiePourTousLesAuditeurs(Long artisteId, String titre,
                                                    String message, TypePromotion type) {
        var auditeurs = auditeurRepository.findAll();
        if (auditeurs.isEmpty()) {
            log.info("Aucun auditeur à notifier pour la promotion artiste {}", artisteId);
            return;
        }

        var notifications = auditeurs.stream()
                .map(auditeur -> Notification.builder()
                        .titre(titre)
                        .message(message)
                        .auditeur(auditeur)
                        .build())
                .toList();

        notificationRepository.saveAll(notifications);
        log.info("Notification promo '{}' envoyée à {} auditeurs (artiste id={})",
                titre, notifications.size(), artisteId);
    }

    @Async
    @Override
    @Transactional
    public void notifierAuditeur(Long auditeurId, String titre, String message) {
        auditeurRepository.findById(auditeurId).ifPresentOrElse(
                auditeur -> {
                    var notif = Notification.builder()
                            .titre(titre)
                            .message(message)
                            .auditeur(auditeur)
                            .build();
                    notificationRepository.save(notif);
                    log.info("Notification '{}' envoyée à l'auditeur {}", titre, auditeurId);
                },
                () -> log.warn("Auditeur {} introuvable — notification ignorée", auditeurId)
        );
    }
}
