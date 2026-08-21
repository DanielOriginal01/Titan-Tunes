package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.AbonnementRequest;
import dan.com.titan_tune.dtos.dtorequest.SouscrireEtPayerRequest;
import dan.com.titan_tune.dtos.dtoresponse.AbonnementResponse;
import dan.com.titan_tune.dtos.dtoresponse.OffreAbonnementResponse;
import dan.com.titan_tune.dtos.dtoresponse.SouscrireEtPayerResponse;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.AbonnementRepository;
import dan.com.titan_tune.repository.AuditeurRepository;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.AbonnementService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Abonnements", description = "Gestion des offres et abonnements Titan Tunes")
@RestController
@RequestMapping(value = "/api/v1/abonnements", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class AbonnementController {

    private final AbonnementService    abonnementService;
    private final AbonnementRepository abonnementRepository;
    private final AuditeurRepository   auditeurRepository;
    private final SecurityUtils        securityUtils;

    // ── Catalogue des offres (PUBLIC) ─────────────────────────────────────────

    @Operation(
        summary = "Consulter les offres disponibles",
        description = "Retourne le catalogue complet des offres d'abonnement avec tarifs, "
                    + "durées et avantages. **Accessible sans connexion.**"
    )
    @GetMapping("/offres")
    public ResponseEntity<ApiResponse<List<OffreAbonnementResponse>>> getOffres() {
        return ResponseEntity.ok(ApiResponse.success(
                "Offres disponibles récupérées.",
                abonnementService.getOffresDisponibles()));
    }

    // ── Liste (ADMIN) ─────────────────────────────────────────────────────────

    @Operation(summary = "Lister tous les abonnements", description = "Réservé à l'ADMIN.")
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<AbonnementResponse>>> getAll() {
        var list = abonnementRepository.findAll().stream()
                .map(AbonnementResponse::fromEntity).toList();
        return ResponseEntity.ok(ApiResponse.success("Liste des abonnements récupérée.", list));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'AUDITEUR')")
    public ResponseEntity<ApiResponse<AbonnementResponse>> getById(@PathVariable Long id) {
        var ab = abonnementRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Abonnement non trouvé id: " + id));
        securityUtils.assertAuditeurOwnerOrAdmin(ab.getAuditeur().getId());
        return ResponseEntity.ok(ApiResponse.success("Abonnement trouvé.", AbonnementResponse.fromEntity(ab)));
    }

    @GetMapping("/auditeur/{auditeurId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'AUDITEUR')")
    public ResponseEntity<ApiResponse<List<AbonnementResponse>>> getByAuditeur(
            @PathVariable Long auditeurId) {
        securityUtils.assertAuditeurOwnerOrAdmin(auditeurId);
        var list = abonnementRepository.findByAuditeurId(auditeurId).stream()
                .map(AbonnementResponse::fromEntity).toList();
        return ResponseEntity.ok(ApiResponse.success("Abonnements récupérés.", list));
    }

    // ── Souscription simple (sans paiement intégré) ───────────────────────────

    @Operation(
        summary = "Souscrire un abonnement (sans paiement)",
        description = "Crée l'abonnement sans déclencher de paiement. "
                    + "Utiliser **/souscrire-et-payer** pour le flux complet recommandé."
    )
    @PostMapping("/souscrire")
    @PreAuthorize("hasRole('AUDITEUR')")
    public ResponseEntity<ApiResponse<AbonnementResponse>> souscrire(
            @Valid @RequestBody AbonnementRequest request) {
        securityUtils.assertAuditeurOwnerOrAdmin(request.auditeurId());
        var auditeur = auditeurRepository.findById(request.auditeurId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Auditeur non trouvé id: " + request.auditeurId()));
        var ab = abonnementService.subscribe(auditeur, request.offre(), request.description());
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(
                "Abonnement souscrit.", AbonnementResponse.fromEntity(ab)));
    }

    // ── Flux principal : souscription + paiement ─────────────────────────────

    @Operation(
        summary = "🌟 Souscrire et payer en une seule opération",
        description = """
            **Flux recommandé pour l'application mobile/web.**

            Effectue en une seule requête :
            1. Calcule automatiquement le prix selon le code d'offre
            2. Simule le paiement via l'opérateur choisi (FLOOZ / TMONEY / WAVE)
            3. Si succès : crée l'abonnement + active le compte
            4. Si échec  : retourne le motif de refus (solde insuffisant, etc.)

            ### Codes d'offre disponibles
            | Code | Durée | Prix |
            |------|-------|------|
            | DAILY | 1 jour | 100 FCFA |
            | WEEKLY | 7 jours | 500 FCFA |
            | MONTHLY | 30 jours | 2 000 FCFA |
            | QUARTERLY | 90 jours | 5 000 FCFA |
            | YEARLY | 365 jours | 18 000 FCFA |
            """
    )
    @PostMapping("/souscrire-et-payer")
    @PreAuthorize("hasRole('AUDITEUR')")
    public ResponseEntity<ApiResponse<SouscrireEtPayerResponse>> souscrireEtPayer(
            @Valid @RequestBody SouscrireEtPayerRequest request) {
        securityUtils.assertAuditeurOwnerOrAdmin(request.auditeurId());

        SouscrireEtPayerResponse result = abonnementService.souscrireEtPayer(request);

        // 201 si succès, 402 si paiement refusé
        HttpStatus status = result.succes() ? HttpStatus.CREATED : HttpStatus.PAYMENT_REQUIRED;
        String message    = result.succes() ? "Abonnement activé avec succès !" : result.message();

        return ResponseEntity.status(status).body(ApiResponse.success(message, result));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> supprimer(@PathVariable Long id) {
        if (!abonnementRepository.existsById(id)) {
            throw new ResourceNotFoundException("Abonnement non trouvé id: " + id);
        }
        abonnementRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Abonnement supprimé.", null));
    }
}
