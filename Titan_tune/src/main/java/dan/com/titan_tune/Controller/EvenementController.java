package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.EvenementCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.EvenementResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.service.EvenementService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/api/v1/evenements", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class EvenementController {

    private final EvenementService evenementService;

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<EvenementResponse>>> getAll(
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success(
                "Liste des événements récupérée.", evenementService.getAll(pageable)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<EvenementResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success("Événement trouvé.", evenementService.getById(id)));
    }

    @GetMapping("/artiste/{artisteId}")
    public ResponseEntity<ApiResponse<PageResponse<EvenementResponse>>> getByArtiste(
            @PathVariable Long artisteId,
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success(
                "Événements de l'artiste récupérés.", evenementService.getByArtiste(artisteId, pageable)));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<EvenementResponse>> creer(
            @Valid @RequestBody EvenementCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(
                "Événement créé.", evenementService.creer(request)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> supprimer(@PathVariable Long id) {
        evenementService.supprimer(id);
        return ResponseEntity.ok(ApiResponse.success("Événement supprimé.", null));
    }
}
