package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.FavorisRequest;
import dan.com.titan_tune.dtos.dtoresponse.FavorisResponse;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.FavorisService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/favoris", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class FavorisController {

    private final FavorisService favorisService;
    private final SecurityUtils  securityUtils;

    /** Ajoute un favori / s'abonne à un artiste — accessible à tout utilisateur connecté (Auditeur, Artiste, Admin). */
    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<FavorisResponse>> ajouterFavori(
            @Valid @RequestBody FavorisRequest request) {
        securityUtils.assertOwnerOrAdmin(request.utilisateurId());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Favori ajouté.", favorisService.ajouterFavori(request)));
    }

    /** Retire un favori / se désabonne — seulement le propriétaire du favori ou un ADMIN. */
    @DeleteMapping("/user/{userId}/target/{targetId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<Void>> retirerFavori(
            @PathVariable Long userId,
            @PathVariable Long targetId,
            @RequestParam String type) {
        securityUtils.assertOwnerOrAdmin(userId);
        favorisService.retirerFavori(userId, targetId, type);
        return ResponseEntity.ok(ApiResponse.success("Favori retiré.", null));
    }

    /**
     * Liste les favoris d'un utilisateur (Morceaux, Albums, Artistes suivis, Playlists).
     * Accessible au propriétaire ou à un ADMIN.
     */
    @GetMapping("/user/{userId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<List<FavorisResponse>>> getFavorisByUser(
            @PathVariable Long userId) {
        securityUtils.assertOwnerOrAdmin(userId);
        return ResponseEntity.ok(ApiResponse.success(
                "Favoris récupérés.", favorisService.getFavorisByUser(userId)));
    }
}
