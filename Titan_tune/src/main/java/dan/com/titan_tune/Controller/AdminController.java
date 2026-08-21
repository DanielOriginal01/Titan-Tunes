package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtoresponse.ArtisteResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.dtos.dtoresponse.StatistiquesAdminResponse;
import dan.com.titan_tune.dtos.dtoresponse.UtilisateurResponse;
import dan.com.titan_tune.enums.Statut;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.ArtisteRepository;
import dan.com.titan_tune.repository.UtilisateurRepository;
import dan.com.titan_tune.service.AdminDashboardService;
import dan.com.titan_tune.service.RefreshTokenService;
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
@RequestMapping(value = "/api/v1/admin", produces = MediaType.APPLICATION_JSON_VALUE)
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminController {

    private final ArtisteRepository      artisteRepository;
    private final UtilisateurRepository  utilisateurRepository;
    private final AdminDashboardService  adminDashboardService;
    private final RefreshTokenService    refreshTokenService;

    // ── Utilisateurs ─────────────────────────────────────────────────────────

    @GetMapping("/utilisateurs")
    public ResponseEntity<ApiResponse<PageResponse<UtilisateurResponse>>> getAllUtilisateurs(
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        var page = utilisateurRepository.findAll(pageable);
        return ResponseEntity.ok(ApiResponse.success(
                "Liste des utilisateurs récupérée.",
                PageResponse.from(page, UtilisateurResponse::fromEntity)
        ));
    }

    @PutMapping("/utilisateurs/{id}/statut")
    public ResponseEntity<ApiResponse<Void>> changerStatut(
            @PathVariable Long id,
            @RequestParam String status) {
        var user = utilisateurRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur non trouvé id: " + id));
        try {
            Statut newStatus = Statut.valueOf(status.toUpperCase());
            user.setStatus(newStatus);
            utilisateurRepository.save(user);

            // Si le compte est désactivé ou supprimé, révoquer immédiatement ses tokens
            if (newStatus == Statut.INACTIF || newStatus == Statut.SUPPRIME) {
                refreshTokenService.revokeByUserId(id);
            }
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Statut invalide : " + status, HttpStatus.BAD_REQUEST));
        }
        return ResponseEntity.ok(ApiResponse.success("Statut mis à jour.", null));
    }

    // ── Artistes ──────────────────────────────────────────────────────────────

    @PutMapping("/artistes/{id}/verifier")
    public ResponseEntity<ApiResponse<Void>> verifierArtiste(@PathVariable Long id) {
        var artiste = artisteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + id));
        artiste.setVerifie(true);
        artisteRepository.save(artiste);
        return ResponseEntity.ok(ApiResponse.success("Artiste vérifié.", null));
    }

    @GetMapping("/artistes/en-attente")
    public ResponseEntity<ApiResponse<PageResponse<ArtisteResponse>>> getArtistesEnAttente(
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        var page = artisteRepository.findByVerifieFalse(pageable);
        return ResponseEntity.ok(ApiResponse.success(
                "Artistes en attente de vérification récupérés.",
                PageResponse.from(page, ArtisteResponse::fromEntity)
        ));
    }

    // ── Dashboard / Stats ─────────────────────────────────────────────────────

    @GetMapping("/dashboard/metriques")
    public ResponseEntity<ApiResponse<Object>> getMetriques() {
        return ResponseEntity.ok(ApiResponse.success(
                "Métriques globales récupérées.", adminDashboardService.getMetricsGlobales()));
    }

    @GetMapping("/dashboard/finances")
    public ResponseEntity<ApiResponse<Object>> getFinances() {
        return ResponseEntity.ok(ApiResponse.success(
                "Données financières récupérées.", adminDashboardService.getFinancesAndRoyalty()));
    }

    @GetMapping("/dashboard/stats")
    public ResponseEntity<ApiResponse<StatistiquesAdminResponse>> getStats() {
        var metrics  = adminDashboardService.getMetricsGlobales();
        var finances = adminDashboardService.getFinancesAndRoyalty();

        var stats = new StatistiquesAdminResponse(
                (Long) metrics.get("totalUtilisateurs"),
                (Long) metrics.get("totalArtistes"),
                (Long) metrics.get("totalAuditeurs"),
                (Double) finances.get("totalRevenus")
        );
        return ResponseEntity.ok(ApiResponse.success("Statistiques admin récupérées.", stats));
    }
}
