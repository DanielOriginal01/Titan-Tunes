package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.PaiementRequest;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.dtos.dtoresponse.PaiementResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface PaiementService {
    PaiementResponse effectuerPaiement(PaiementRequest request);
    List<PaiementResponse> getHistoriqueAuditeur(Long auditeurId);
    PageResponse<PaiementResponse> getHistoriqueAuditeur(Long auditeurId, Pageable pageable);
}