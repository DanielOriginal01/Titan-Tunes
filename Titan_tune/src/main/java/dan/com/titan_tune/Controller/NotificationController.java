package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.NotificationCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.entities.Notification;
import dan.com.titan_tune.enums.TypePromotion;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.AuditeurRepository;
import dan.com.titan_tune.repository.NotificationRepository;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.NotificationPromoService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
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
@RequestMapping(value = "/api/v1/notifications", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationRepository  notificationRepository;
    private final AuditeurRepository      auditeurRepository;
    private final NotificationPromoService notificationPromoService;
    private final SecurityUtils           securityUtils;

    // ── Consultation ──────────────────────────────────────────────────────────

    /** Liste toutes les notifications (paginée) — ADMIN uniquement. */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<PageResponse<Notification>>> getAll(
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        var page = notificationRepository.findAll(pageable);
        return ResponseEntity.ok(ApiResponse.success(
                "Liste des notifications récupérée.", PageResponse.from(page)));
    }

    /**
     * Notifications d'un auditeur (paginée).
     * Un auditeur ne peut consulter que ses propres notifications.
     */
    @GetMapping("/auditeur/{auditeurId}")
    @PreAuthorize("hasAnyRole('AUDITEUR', 'ADMIN')")
    public ResponseEntity<ApiResponse<PageResponse<Notification>>> getByAuditeur(
            @PathVariable Long auditeurId,
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        securityUtils.assertAuditeurOwnerOrAdmin(auditeurId);
        var page = notificationRepository.findByAuditeurId(auditeurId, pageable);
        return ResponseEntity.ok(ApiResponse.success(
                "Notifications récupérées.",
                PageResponse.from(page)));
    }

    /** Notifications non lues (paginée) — ADMIN uniquement. */
    @GetMapping("/non-lues")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<PageResponse<Notification>>> getNonLues(
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        var page = notificationRepository.findByLuFalse(pageable);
        return ResponseEntity.ok(ApiResponse.success(
                "Notifications non lues récupérées.", PageResponse.from(page)));
    }

    // ── Actions ───────────────────────────────────────────────────────────────

    /**
     * Crée une notification (système) — ADMIN uniquement.
     * Utilise un DTO pour éviter l'injection d'entité brute.
     */
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Notification>> create(
            @Valid @RequestBody NotificationCreateRequest request) {
        var auditeur = auditeurRepository.findById(request.auditeurId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Auditeur non trouvé id: " + request.auditeurId()));

        var notification = Notification.builder()
                .titre(request.titre())
                .message(request.message())
                .auditeur(auditeur)
                .build();

        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(
                "Notification créée.", notificationRepository.save(notification)));
    }

    /**
     * Marque une notification comme lue.
     * Un auditeur ne peut marquer que ses propres notifications.
     */
    @PutMapping("/{id}/lire")
    @PreAuthorize("hasAnyRole('AUDITEUR', 'ADMIN')")
    public ResponseEntity<ApiResponse<Notification>> marquerLue(@PathVariable Long id) {
        var notif = notificationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Notification non trouvée id: " + id));

        // Ownership : vérifier que la notification appartient à l'auditeur connecté
        securityUtils.assertAuditeurOwnerOrAdmin(notif.getAuditeur().getId());

        notif.setLu(true);
        return ResponseEntity.ok(ApiResponse.success(
                "Notification marquée comme lue.", notificationRepository.save(notif)));
    }

    /**
     * Supprime une notification.
     * Un auditeur ne peut supprimer que ses propres notifications.
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('AUDITEUR', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> supprimer(@PathVariable Long id) {
        var notif = notificationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Notification non trouvée id: " + id));

        securityUtils.assertAuditeurOwnerOrAdmin(notif.getAuditeur().getId());

        notificationRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Notification supprimée.", null));
    }

    // ── Notifications promotionnelles ─────────────────────────────────────────

    /**
     * Notifie tous les auditeurs pour une sortie.
     * Un artiste ne peut envoyer des notifications promotionnelles qu'en son propre nom.
     */
    @PostMapping("/promo/artiste/{artisteId}")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> notifierSortie(
            @PathVariable Long artisteId,
            @Valid @RequestBody NotifPromoRequest request) {
        // Un artiste ne peut pas usurper l'identité d'un autre artiste
        securityUtils.assertArtisteOwnerOrAdmin(artisteId);

        notificationPromoService.notifierSortiePourTousLesAuditeurs(
                artisteId, request.titre(), request.message(), request.typePromotion());
        return ResponseEntity.accepted().body(ApiResponse.success(
                "Notification promotionnelle envoyée.", null));
    }

    /** Notifie un auditeur ciblé — artiste ou admin uniquement. */
    @PostMapping("/promo/auditeur/{auditeurId}")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> notifierAuditeur(
            @PathVariable Long auditeurId,
            @Valid @RequestBody NotifCibleeRequest request) {
        notificationPromoService.notifierAuditeur(auditeurId, request.titre(), request.message());
        return ResponseEntity.accepted().body(ApiResponse.success(
                "Notification envoyée à l'auditeur " + auditeurId + ".", null));
    }

    // ── DTOs internes ─────────────────────────────────────────────────────────

    record NotifPromoRequest(
            @NotBlank String titre,
            @NotBlank String message,
            @NotNull TypePromotion typePromotion) {}

    record NotifCibleeRequest(
            @NotBlank String titre,
            @NotBlank String message) {}
}
