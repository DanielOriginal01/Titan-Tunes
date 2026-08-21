package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.BanniereRequest;
import dan.com.titan_tune.dtos.dtoresponse.BanniereResponse;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.BanniereRepository;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.BanniereService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/bannieres", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class BanniereController {

    private final BanniereService    banniereService;
    private final BanniereRepository banniereRepository;
    private final SecurityUtils      securityUtils;

    // ── Lecture publique (page d'accueil, carrousel) ──────────────────────────

    @GetMapping("/actives")
    public ResponseEntity<ApiResponse<List<BanniereResponse>>> getActives() {
        return ResponseEntity.ok(ApiResponse.success(
                "Bannières actives récupérées.", banniereService.getActives()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<BanniereResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(
                "Bannière trouvée.", banniereService.getById(id)));
    }

    /** Bannières d'un artiste — l'artiste ne voit que les siennes, l'admin voit tout. */
    @GetMapping("/artiste/{artisteId}")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<BanniereResponse>>> getByArtiste(
            @PathVariable Long artisteId) {
        securityUtils.assertOwnerOrAdmin(artisteId);
        return ResponseEntity.ok(ApiResponse.success(
                "Bannières de l'artiste récupérées.", banniereService.getByArtiste(artisteId)));
    }

    // ── Gestion (seulement le propriétaire ou ADMIN) ──────────────────────────

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<BanniereResponse>> creer(
            @RequestPart("data") @Valid BanniereRequest request,
            @RequestPart("image") MultipartFile image) {
        // Un artiste ne peut créer une bannière que pour lui-même
        securityUtils.assertOwnerOrAdmin(request.artisteId());
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(
                "Bannière créée.", banniereService.creer(request, image)));
    }

    /** Active la bannière → notifications push à tous les auditeurs. */
    @PutMapping("/{id}/activer")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<BanniereResponse>> activer(@PathVariable Long id) {
        assertBanniereOwner(id);
        return ResponseEntity.ok(ApiResponse.success(
                "Bannière activée. Notifications envoyées aux auditeurs.",
                banniereService.activer(id)));
    }

    @PutMapping("/{id}/desactiver")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<BanniereResponse>> desactiver(@PathVariable Long id) {
        assertBanniereOwner(id);
        return ResponseEntity.ok(ApiResponse.success(
                "Bannière désactivée.", banniereService.desactiver(id)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> supprimer(@PathVariable Long id) {
        assertBanniereOwner(id);
        banniereService.supprimer(id);
        return ResponseEntity.ok(ApiResponse.success("Bannière supprimée.", null));
    }

    // ── Helper ownership ─────────────────────────────────────────────────────

    private void assertBanniereOwner(Long banniereId) {
        var banniere = banniereRepository.findById(banniereId)
                .orElseThrow(() -> new ResourceNotFoundException("Bannière non trouvée id: " + banniereId));
        securityUtils.assertOwnerOrAdmin(banniere.getArtiste().getId());
    }
}
