package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.ChansonCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.ChansonResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface ChansonService {
    ChansonResponse publierChanson(ChansonCreateRequest request, MultipartFile audioFile);
    ChansonResponse publierChanson(ChansonCreateRequest request, MultipartFile audioFile, MultipartFile coverFile);
    ChansonResponse getChansonById(Long idChanson);
    String getStreamingUrl(Long idChanson);
    ResponseEntity<Resource> streamAudioResource(Long idChanson, String rangeHeader);
    ResponseEntity<Resource> getCoverResource(Long idChanson);
    List<ChansonResponse> rechercherChansons(String query);
    PageResponse<ChansonResponse> rechercherChansons(String query, Pageable pageable);
    List<ChansonResponse> getTopTendances();
    PageResponse<ChansonResponse> getTopTendances(Pageable pageable);
    PageResponse<ChansonResponse> getAllChansons(Pageable pageable);
    void supprimerChanson(Long idChanson);
}
