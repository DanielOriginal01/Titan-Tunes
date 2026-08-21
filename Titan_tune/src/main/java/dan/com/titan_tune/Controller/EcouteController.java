package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.EcouteRecordRequest;
import dan.com.titan_tune.dtos.dtoresponse.EcouteResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.EcouteService;
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
@RequestMapping(value = "/api/v1/ecoutes", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class EcouteController {

    private final EcouteService  ecouteService;
    private final SecurityUtils  securityUtils;

    /**
     * Enregistre une écoute.
     * Un auditeur ne peut enregistrer une écoute qu'en son propre nom.
     * L'ADMIN ne peut pas enregistrer d'écoutes (action métier réservée aux auditeurs).
     */
    @PostMapping
    @PreAuthorize("hasRole('AUDITEUR')")
    public ResponseEntity<ApiResponse<EcouteResponse>> enregistrerEcoute(
            @Valid @RequestBody EcouteRecordRequest request) {
        securityUtils.assertAuditeurOwnerOrAdmin(request.auditeurId());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Écoute enregistrée.", ecouteService.enregistrerEcoute(request)));
    }

    /**
     * Enregistre une écoute de façon asynchrone (fire-and-forget).
     * Même règle d'ownership : l'auditeur enregistre uniquement pour lui-même.
     */
    @PostMapping("/async")
    @PreAuthorize("hasRole('AUDITEUR')")
    public ResponseEntity<ApiResponse<Void>> enregistrerEcouteAsync(
            @Valid @RequestBody EcouteRecordRequest request) {
        securityUtils.assertAuditeurOwnerOrAdmin(request.auditeurId());
        ecouteService.enregistrerEcouteAsync(request);
        return ResponseEntity.accepted().body(ApiResponse.success("Écoute async enregistrée.", null));
    }

    /**
     * Récupère l'historique d'écoute (paginé).
     * Un auditeur ne peut consulter que son propre historique.
     * Un ADMIN peut consulter n'importe quel historique.
     */
    @GetMapping("/historique/{auditeurId}")
    @PreAuthorize("hasAnyRole('AUDITEUR', 'ADMIN')")
    public ResponseEntity<ApiResponse<PageResponse<EcouteResponse>>> getHistoriqueAuditeur(
            @PathVariable Long auditeurId,
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        securityUtils.assertAuditeurOwnerOrAdmin(auditeurId);
        return ResponseEntity.ok(ApiResponse.success(
                "Historique d'écoute récupéré.", ecouteService.getHistoriqueAuditeur(auditeurId, pageable)));
    }
}
