package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.PlaylistCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.dtos.dtoresponse.PlaylistResponse;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.PlaylistRepository;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.PlaylistService;
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
@RequestMapping(value = "/api/v1/playlists", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class PlaylistController {

    private final PlaylistService    playlistService;
    private final PlaylistRepository playlistRepository;
    private final SecurityUtils      securityUtils;

    /** Liste toutes les playlists publiques — accessible à tout utilisateur connecté. */
    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<PageResponse<PlaylistResponse>>> getAllPlaylists(
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.success(
                "Liste des playlists publiques récupérée.",
                playlistService.getAllPlaylists(pageable)
        ));
    }

    /** Crée une playlist — l'auditeur ne peut créer que pour lui-même. */
    @PostMapping
    @PreAuthorize("hasRole('AUDITEUR')")
    public ResponseEntity<ApiResponse<PlaylistResponse>> creerPlaylist(
            @Valid @RequestBody PlaylistCreateRequest request) {
        securityUtils.assertAuditeurOwnerOrAdmin(request.auditeurId());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Playlist créée.", playlistService.creerPlaylist(request)));
    }

    /** Ajoute une chanson — seulement le propriétaire de la playlist. */
    @PostMapping("/{id}/chansons/{chansonId}")
    @PreAuthorize("hasRole('AUDITEUR')")
    public ResponseEntity<ApiResponse<PlaylistResponse>> ajouterChanson(
            @PathVariable Long id, @PathVariable Long chansonId) {
        assertPlaylistOwner(id);
        return ResponseEntity.ok(ApiResponse.success(
                "Chanson ajoutée à la playlist.", playlistService.ajouterChanson(id, chansonId)));
    }

    /** Retire une chanson — seulement le propriétaire de la playlist. */
    @DeleteMapping("/{id}/chansons/{chansonId}")
    @PreAuthorize("hasRole('AUDITEUR')")
    public ResponseEntity<ApiResponse<PlaylistResponse>> retirerChanson(
            @PathVariable Long id, @PathVariable Long chansonId) {
        assertPlaylistOwner(id);
        return ResponseEntity.ok(ApiResponse.success(
                "Chanson retirée de la playlist.", playlistService.retirerChanson(id, chansonId)));
    }

    /**
     * Récupère une playlist par ID.
     * - Playlist publique : accessible à tout utilisateur connecté.
     * - Playlist privée : accessible seulement au propriétaire ou à un ADMIN.
     */
    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<PlaylistResponse>> getPlaylistById(@PathVariable Long id) {
        var playlist = playlistRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Playlist non trouvée id: " + id));

        // Vérification accès playlist privée
        if (playlist.isPrivee()) {
            securityUtils.assertOwnerOrAdmin(playlist.getAuditeur().getId());
        }

        return ResponseEntity.ok(ApiResponse.success(
                "Playlist récupérée.", playlistService.getPlaylistById(id)));
    }

    /**
     * Liste les playlists d'un auditeur.
     * - Propriétaire / ADMIN : voit toutes les playlists (publiques + privées).
     * - Autre utilisateur connecté : voit seulement les playlists publiques.
     */
    @GetMapping("/auditeur/{auditeurId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<PageResponse<PlaylistResponse>>> getPlaylistsByAuditeur(
            @PathVariable Long auditeurId,
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        boolean isOwnerOrAdmin = securityUtils.isAdmin() || securityUtils.isCurrentUser(auditeurId);
        PageResponse<PlaylistResponse> page;
        if (isOwnerOrAdmin) {
            page = playlistService.getPlaylistsByAuditeur(auditeurId, pageable);
        } else {
            var p = playlistRepository.findByPriveeFalse(pageable);
            page = PageResponse.from(p, PlaylistResponse::fromEntity);
        }
        return ResponseEntity.ok(ApiResponse.success("Playlists récupérées.", page));
    }

    /** Supprime une playlist — seulement le propriétaire ou un ADMIN. */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('AUDITEUR', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> supprimerPlaylist(@PathVariable Long id) {
        assertPlaylistOwner(id);
        playlistService.supprimerPlaylist(id);
        return ResponseEntity.ok(ApiResponse.success("Playlist supprimée.", null));
    }

    // ── Helper ownership ─────────────────────────────────────────────────────

    private void assertPlaylistOwner(Long playlistId) {
        var playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new ResourceNotFoundException("Playlist non trouvée id: " + playlistId));
        securityUtils.assertOwnerOrAdmin(playlist.getAuditeur().getId());
    }
}
