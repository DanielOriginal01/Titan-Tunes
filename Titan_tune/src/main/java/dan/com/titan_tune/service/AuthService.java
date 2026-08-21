package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.LoginRequest;
import dan.com.titan_tune.dtos.dtorequest.RegisterRequest;
import dan.com.titan_tune.dtos.dtoresponse.AccountRecoveryResponse;
import dan.com.titan_tune.dtos.dtoresponse.AuthResponse;

public interface AuthService {
    AccountRecoveryResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);

    /**
     * Crée un nouveau compte administrateur.
     * Réservé aux admins existants — l'appelant doit avoir le rôle ROLE_ADMIN.
     * Lève une exception si un admin existe déjà en base.
     */
    AccountRecoveryResponse createAdmin(RegisterRequest request);

    /**
     * Déconnexion sécurisée : révoque le token d'accès JWT courant et le refresh token de l'utilisateur.
     */
    void logout(String bearerToken, Long currentUserId);
}