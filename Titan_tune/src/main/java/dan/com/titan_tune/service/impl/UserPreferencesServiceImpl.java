package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.service.UserPreferencesService;
import org.springframework.stereotype.Service;

/**
 * Implémentation par défaut des préférences de notification.
 * Toutes les notifications sont autorisées par défaut.
 * À enrichir avec une table UserPreferences quand nécessaire.
 */
@Service
public class UserPreferencesServiceImpl implements UserPreferencesService {

    @Override
    public boolean allows(Long userId, UserPreferencesService.NotificationCategory category) {
        // Toutes catégories activées par défaut
        return true;
    }
}
