package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.FavorisRequest;
import dan.com.titan_tune.dtos.dtoresponse.FavorisResponse;

import java.util.List;

public interface FavorisService {
    FavorisResponse ajouterFavori(FavorisRequest request);
    void retirerFavori(Long userId, Long targetId, String type);
    List<FavorisResponse> getFavorisByUser(Long userId);
}