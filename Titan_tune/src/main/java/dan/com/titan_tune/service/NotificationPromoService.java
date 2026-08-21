package dan.com.titan_tune.service;

import dan.com.titan_tune.enums.TypePromotion;

public interface NotificationPromoService {

    /**
     * Envoie une notification à tous les auditeurs pour annoncer
     * une nouvelle sortie (album, single…) d'un artiste.
     */
    void notifierSortiePourTousLesAuditeurs(Long artisteId, String titre,
                                             String message, TypePromotion type);

    /**
     * Envoie une notification ciblée à un auditeur spécifique.
     */
    void notifierAuditeur(Long auditeurId, String titre, String message);
}
