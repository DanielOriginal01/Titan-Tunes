package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.AlbumCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.AlbumResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface AlbumService {
    AlbumResponse creerAlbum(AlbumCreateRequest request);
    AlbumResponse creerAlbum(AlbumCreateRequest request, MultipartFile coverFile);
    AlbumResponse modifierAlbum(Long id, AlbumCreateRequest request);
    AlbumResponse modifierAlbum(Long id, AlbumCreateRequest request, MultipartFile coverFile);
    void supprimerAlbum(Long id);
    AlbumResponse getAlbumById(Long id);
    PageResponse<AlbumResponse> getAllAlbums(Pageable pageable);
    List<AlbumResponse> getAlbumsByArtiste(Long artisteId);
    ResponseEntity<Resource> getCoverResource(Long idAlbum);
}
