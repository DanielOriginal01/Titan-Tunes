package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.EcouteRecordRequest;
import dan.com.titan_tune.dtos.dtoresponse.EcouteResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface EcouteService {
    void enregistrerEcouteAsync(EcouteRecordRequest request);
    EcouteResponse enregistrerEcoute(EcouteRecordRequest request);
    List<EcouteResponse> getHistoriqueAuditeur(Long auditeurId);
    PageResponse<EcouteResponse> getHistoriqueAuditeur(Long auditeurId, Pageable pageable);
}