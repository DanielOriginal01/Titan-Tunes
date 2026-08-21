package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.ChansonCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.ChansonResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.ChansonRepository;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.ChansonService;
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

@RestController
@RequestMapping(value = "/api/v1/chansons")
@RequiredArgsConstructor
public class ChansonController {

    private final ChansonRepository chansonRepository;
    private final ChansonService    chansonService;
    private final SecurityUtils     securityUtils;

    // ── Lecture publique ──────────────────────────────────────────────────────────

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiResponse<PageResponse<ChansonResponse>>> getAllChansons(
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success(
                "Liste des chansons récupérée.",
                chansonService.getAllChansons(pageable)
        ));
    }

    @GetMapping(value = "/tendances", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiResponse<PageResponse<ChansonResponse>>> getTopTendances(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success(
                "Chansons tendance récupérées.",
                chansonService.getTopTendances(pageable)
        ));
    }

    @GetMapping(value = "/artiste/{artisteId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiResponse<PageResponse<ChansonResponse>>> getChansonsByArtiste(
            @PathVariable Long artisteId,
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success(
                "Chansons de l'artiste récupérées.",
                chansonService.getChansonsByArtiste(artisteId, pageable)
        ));
    }

    @GetMapping(value = "/recherche", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiResponse<PageResponse<ChansonResponse>>> rechercherChansons(
            @RequestParam("query") String query,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success(
                "Résultats de recherche récupérés.",
                chansonService.rechercherChansons(query, pageable)
        ));
    }

    @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiResponse<ChansonResponse>> getChansonById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(
                "Détails de la chanson récupérés.", chansonService.getChansonById(id)));
    }

    /** URL de streaming présignée MinIO (1h) ou lien direct – accessible publiquement pour les players. */
    @GetMapping(value = "/{id}/stream", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiResponse<String>> getStreamingUrl(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(
                "URL de streaming générée.", chansonService.getStreamingUrl(id)));
    }

    /** Flux audio direct binaire avec support Byte-Range (Seeking HTTP 206 Partial Content). */
    @GetMapping(value = "/{id}/audio")
    public ResponseEntity<Resource> streamAudio(
            @PathVariable Long id,
            @RequestHeader(value = "Range", required = false) String rangeHeader) {
        return chansonService.streamAudioResource(id, rangeHeader);
    }

    /** Pochette de couverture de la chanson ou de son album. */
    @GetMapping(value = "/{id}/cover")
    public ResponseEntity<Resource> getCover(@PathVariable Long id) {
        return chansonService.getCoverResource(id);
    }

    // ── Actions ARTISTE ──────────────────────────────────────────────────────────

    @PostMapping(value = "/publier", consumes = MediaType.MULTIPART_FORM_DATA_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<ChansonResponse>> publierChanson(
            @RequestPart("data") @Valid ChansonCreateRequest request,
            @RequestPart("file") MultipartFile audioFile,
            @RequestPart(value = "cover", required = false) MultipartFile coverFile) {

        Long artisteId = request.artisteId() != null ? request.artisteId() : securityUtils.getCurrentUserId();
        securityUtils.assertOwnerOrAdmin(artisteId);

        ChansonCreateRequest finalRequest = request.artisteId() == null ?
                new ChansonCreateRequest(
                        request.titre(),
                        request.duree(),
                        request.parole(),
                        artisteId,
                        request.categorieId(),
                        request.albumId(),
                        request.coverImage()
                ) : request;

        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(
                "Chanson publiée avec succès.", chansonService.publierChanson(finalRequest, audioFile, coverFile)));
    }

    /** Un artiste ne peut supprimer que ses propres chansons. */
    @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> supprimerChanson(@PathVariable Long id) {
        var chanson = chansonRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Chanson non trouvée id: " + id));

        securityUtils.assertOwnerOrAdmin(chanson.getArtiste().getId());

        chansonService.supprimerChanson(id);
        return ResponseEntity.ok(ApiResponse.success("Chanson supprimée.", null));
    }
}
