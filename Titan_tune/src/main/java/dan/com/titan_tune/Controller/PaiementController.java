package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.PaiementRequest;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.dtos.dtoresponse.PaiementResponse;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.PaiementService;
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
@RequestMapping(value = "/api/v1/paiements", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class PaiementController {

    private final PaiementService paiementService;
    private final SecurityUtils   securityUtils;

    /**
     * Effectue un paiement.
     * Un auditeur ne peut payer que pour lui-même — prévient les fraudes
     * où un utilisateur activerait un abonnement sur le compte d'un autre.
     */
    @PostMapping
    @PreAuthorize("hasRole('AUDITEUR')")
    public ResponseEntity<ApiResponse<PaiementResponse>> effectuerPaiement(
            @Valid @RequestBody PaiementRequest request) {
        securityUtils.assertAuditeurOwnerOrAdmin(request.auditeurId());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Paiement effectué.", paiementService.effectuerPaiement(request)));
    }

    /**
     * Consulte l'historique des paiements d'un auditeur (paginé).
     * Un auditeur ne peut consulter que son propre historique financier.
     * Un ADMIN peut consulter n'importe quel historique.
     */
    @GetMapping("/auditeur/{auditeurId}")
    @PreAuthorize("hasAnyRole('AUDITEUR', 'ADMIN')")
    public ResponseEntity<ApiResponse<PageResponse<PaiementResponse>>> getHistoriqueAuditeur(
            @PathVariable Long auditeurId,
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        securityUtils.assertAuditeurOwnerOrAdmin(auditeurId);
        return ResponseEntity.ok(ApiResponse.success(
                "Historique de paiement récupéré.", paiementService.getHistoriqueAuditeur(auditeurId, pageable)));
    }
}
