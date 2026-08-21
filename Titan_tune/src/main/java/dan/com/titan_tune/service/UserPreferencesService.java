package dan.com.titan_tune.service;

/**
 * Service d'accès aux préférences utilisateur concernant les notifications.
 */
public interface UserPreferencesService {
    boolean allows(Long userId, NotificationCategory category);

    enum NotificationCategory { SUBSCRIPTION, PROMOTION, SYSTEM }
}
