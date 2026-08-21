package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.TelechargementRequest;
import dan.com.titan_tune.dtos.dtoresponse.TelechargementResponse;

import java.util.List;

public interface TelechargementService {
    TelechargementResponse enregistrerTelechargement(TelechargementRequest request);
    List<TelechargementResponse> getByAuditeur(Long auditeurId);
    List<TelechargementResponse> getByChanson(Long chansonId);
    void supprimer(Long id);
}
