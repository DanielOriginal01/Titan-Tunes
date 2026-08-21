package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.OAuth2Request;
import dan.com.titan_tune.dtos.dtoresponse.AuthResponse;

public interface OAuth2Service {

    /**
     * Vérifie le token OAuth2 auprès du provider (Google ou Facebook),
     * crée le compte si c'est la première connexion, puis retourne un JWT Titan Tunes.
     *
     * @param request contient l'accessToken, le provider et le rôle souhaité
     * @return JWT Titan Tunes + infos utilisateur
     */
    AuthResponse loginOrRegister(OAuth2Request request);
}
