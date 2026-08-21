package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.EvenementCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.EvenementResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface EvenementService {
    EvenementResponse creer(EvenementCreateRequest request);
    EvenementResponse getById(Long id);
    List<EvenementResponse> getAll();
    PageResponse<EvenementResponse> getAll(Pageable pageable);
    List<EvenementResponse> getByArtiste(Long artisteId);
    PageResponse<EvenementResponse> getByArtiste(Long artisteId, Pageable pageable);
    void supprimer(Long id);
}
