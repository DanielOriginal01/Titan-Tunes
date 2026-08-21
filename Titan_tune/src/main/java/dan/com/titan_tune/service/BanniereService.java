package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.BanniereRequest;
import dan.com.titan_tune.dtos.dtoresponse.BanniereResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface BanniereService {
    BanniereResponse creer(BanniereRequest request, MultipartFile image);
    BanniereResponse getById(Long id);
    List<BanniereResponse> getByArtiste(Long artisteId);
    List<BanniereResponse> getActives();
    BanniereResponse activer(Long id);
    BanniereResponse desactiver(Long id);
    void supprimer(Long id);
}
