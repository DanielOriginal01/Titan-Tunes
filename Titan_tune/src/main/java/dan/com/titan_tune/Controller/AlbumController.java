package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.AlbumCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.AlbumResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.AlbumService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/albums", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class AlbumController {

    private final AlbumService albumService;
    private final SecurityUtils securityUtils;

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<AlbumResponse>>> getAllAlbums(
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success(
                "Liste des albums récupérée avec succès.",
                albumService.getAllAlbums(pageable)
        ));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<AlbumResponse>> getAlbumById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(
                "Album récupéré avec succès.",
                albumService.getAlbumById(id)
        ));
    }

    @GetMapping("/artiste/{artisteId}")
    public ResponseEntity<ApiResponse<List<AlbumResponse>>> getAlbumsByArtiste(@PathVariable Long artisteId) {
        return ResponseEntity.ok(ApiResponse.success(
                "Albums de l'artiste récupérés avec succès.",
                albumService.getAlbumsByArtiste(artisteId)
        ));
    }

    /** Stream binaire direct de la couverture d'album. */
    @GetMapping(value = "/{id}/cover", produces = {MediaType.IMAGE_JPEG_VALUE, MediaType.IMAGE_PNG_VALUE, "image/webp"})
    public ResponseEntity<Resource> getCover(@PathVariable Long id) {
        return albumService.getCoverResource(id);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<AlbumResponse>> creerAlbumJson(@Valid @RequestBody AlbumCreateRequest request) {
        Long artisteId = request.artisteId() != null ? request.artisteId() : securityUtils.getCurrentUserId();
        securityUtils.assertOwnerOrAdmin(artisteId);

        AlbumCreateRequest finalRequest = request.artisteId() == null ?
                new AlbumCreateRequest(request.title(), request.dateSortie(), request.coverImage(), artisteId) : request;

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Album créé avec succès.", albumService.creerAlbum(finalRequest)));
    }

    @PostMapping(value = "/publier", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<AlbumResponse>> creerAlbumMultipart(
            @RequestPart("data") @Valid AlbumCreateRequest request,
            @RequestPart(value = "cover", required = false) MultipartFile coverFile) {

        Long artisteId = request.artisteId() != null ? request.artisteId() : securityUtils.getCurrentUserId();
        securityUtils.assertOwnerOrAdmin(artisteId);

        AlbumCreateRequest finalRequest = request.artisteId() == null ?
                new AlbumCreateRequest(request.title(), request.dateSortie(), request.coverImage(), artisteId) : request;

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Album créé avec succès.", albumService.creerAlbum(finalRequest, coverFile)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<AlbumResponse>> modifierAlbum(
            @PathVariable Long id,
            @Valid @RequestBody AlbumCreateRequest request) {
        return ResponseEntity.ok(ApiResponse.success(
                "Album modifié avec succès.",
                albumService.modifierAlbum(id, request)
        ));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> supprimerAlbum(@PathVariable Long id) {
        albumService.supprimerAlbum(id);
        return ResponseEntity.ok(ApiResponse.success("Album supprimé avec succès.", null));
    }
}
