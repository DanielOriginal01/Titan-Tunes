package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.dtos.dtoresponse.ReversementResponse;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.ReversementService;
import dan.com.titan_tune.service.impl.ReversementServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping(value = "/api/v1/reversements", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class ReversementController {

    private final ReversementService reversementService;
    private final SecurityUtils      securityUtils;

    // ── Consultation artiste — seulement le sien ou ADMIN ────────────────────

    @GetMapping("/artiste/{artisteId}")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<PageResponse<ReversementResponse>>> getHistorique(
            @PathVariable Long artisteId,
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        securityUtils.assertOwnerOrAdmin(artisteId);  // 403 si artiste différent
        return ResponseEntity.ok(ApiResponse.success(
                "Historique des reversements récupéré.",
                reversementService.getHistoriqueArtiste(artisteId, pageable)));
    }

    @GetMapping("/artiste/{artisteId}/total")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getTotalVerse(
            @PathVariable Long artisteId) {
        securityUtils.assertOwnerOrAdmin(artisteId);
        Double total = reversementService.getTotalVerseArtiste(artisteId);
        return ResponseEntity.ok(ApiResponse.success(
                "Total reversé calculé.",
                Map.of("artisteId", artisteId, "totalVerse", total, "devise", "FCFA")));
    }

    // ── Administration (ADMIN uniquement) ────────────────────────────────────

    @PostMapping("/calculer/mensuel")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<ReversementResponse>>> calculerMensuel() {
        String periode = ReversementServiceImpl.periodeCourante();
        var result = reversementService.calculerReversementsMensuels(periode);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(
                "Reversements mensuels calculés pour la période " + periode + ".", result));
    }

    @PostMapping("/calculer/artiste/{artisteId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<ReversementResponse>> calculerPourArtiste(
            @PathVariable Long artisteId,
            @RequestParam(defaultValue = "") String periode) {
        if (periode.isBlank()) periode = ReversementServiceImpl.periodeCourante();
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(
                "Reversement calculé.", reversementService.calculerPourArtiste(artisteId, periode)));
    }

    @PutMapping("/{id}/verser")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<ReversementResponse>> marquerCommeVerse(
            @PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(
                "Reversement marqué comme versé.", reversementService.marquerCommeVerse(id)));
    }
}
