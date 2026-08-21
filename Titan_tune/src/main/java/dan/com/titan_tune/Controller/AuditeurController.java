package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.UpdateProfileRequest;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.dtos.dtoresponse.UtilisateurResponse;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.AuditeurRepository;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.MinioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping(value = "/api/v1/auditeurs", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class AuditeurController {

    private static final String BUCKET_PHOTOS_PROFILS = "photos-profils";

    private final AuditeurRepository auditeurRepository;
    private final MinioService       minioService;
    private final SecurityUtils      securityUtils;

    /** Liste réservée à l'ADMIN — paginée. */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<PageResponse<UtilisateurResponse>>> getAll(
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        var page = auditeurRepository.findAll(pageable);
        return ResponseEntity.ok(ApiResponse.success(
                "Liste des auditeurs récupérée.",
                PageResponse.from(page, UtilisateurResponse::fromEntity)
        ));
    }

    /** Un auditeur peut consulter son propre profil, un admin peut voir n'importe lequel. */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'AUDITEUR')")
    public ResponseEntity<ApiResponse<UtilisateurResponse>> getById(@PathVariable Long id) {
        securityUtils.assertOwnerOrAdmin(id);  // 403 si ce n'est pas son profil

        var auditeur = auditeurRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Auditeur non trouvé id: " + id));
        return ResponseEntity.ok(ApiResponse.success("Auditeur trouvé.", UtilisateurResponse.fromEntity(auditeur)));
    }

    /** Un auditeur ne peut modifier que son propre profil. */
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('AUDITEUR', 'ADMIN')")
    public ResponseEntity<ApiResponse<UtilisateurResponse>> update(
            @PathVariable Long id,
            @Valid @RequestBody UpdateProfileRequest request) {
        securityUtils.assertOwnerOrAdmin(id);  // 403 si ce n'est pas son profil

        var auditeur = auditeurRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Auditeur non trouvé id: " + id));

        if (request.username()    != null) auditeur.setUsername(request.username());
        if (request.telephone()   != null) auditeur.setTelephone(request.telephone());
        if (request.photoProfil() != null) auditeur.setPhotoProfil(request.photoProfil());

        return ResponseEntity.ok(ApiResponse.success(
                "Profil mis à jour.", UtilisateurResponse.fromEntity(auditeurRepository.save(auditeur))));
    }

    /** Upload de photo de profil pour l'auditeur. */
    @PostMapping(value = "/{id}/photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAnyRole('AUDITEUR', 'ADMIN')")
    public ResponseEntity<ApiResponse<UtilisateurResponse>> uploadPhoto(
            @PathVariable Long id,
            @RequestPart("photo") MultipartFile photo) {
        securityUtils.assertOwnerOrAdmin(id);  // 403 si ce n'est pas son profil

        var auditeur = auditeurRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Auditeur non trouvé id: " + id));

        // Supprimer l'ancienne photo MinIO si elle existait
        if (auditeur.getPhotoProfil() != null && !auditeur.getPhotoProfil().isBlank()) {
            minioService.deleteFile(auditeur.getPhotoProfil(), BUCKET_PHOTOS_PROFILS);
        }

        String fileName = minioService.uploadFile(photo, BUCKET_PHOTOS_PROFILS);
        auditeur.setPhotoProfil(fileName);

        return ResponseEntity.ok(ApiResponse.success(
                "Photo de profil mise à jour.",
                UtilisateurResponse.fromEntity(auditeurRepository.save(auditeur))));
    }

    /** Récupération de l'URL d'accès ou présignée pour la photo de profil. */
    @GetMapping("/{id}/photo/url")
    @PreAuthorize("hasAnyRole('ADMIN', 'AUDITEUR', 'ARTISTE')")
    public ResponseEntity<ApiResponse<String>> getPhotoUrl(@PathVariable Long id) {
        var auditeur = auditeurRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Auditeur non trouvé id: " + id));

        if (auditeur.getPhotoProfil() == null || auditeur.getPhotoProfil().isBlank()) {
            return ResponseEntity.ok(ApiResponse.success("Aucune photo de profil enregistrée.", null));
        }

        String url = minioService.getPresignedUrl(auditeur.getPhotoProfil(), BUCKET_PHOTOS_PROFILS);
        return ResponseEntity.ok(ApiResponse.success("URL de la photo de profil générée.", url));
    }

    /** Suppression de la photo de profil. */
    @DeleteMapping("/{id}/photo")
    @PreAuthorize("hasAnyRole('AUDITEUR', 'ADMIN')")
    public ResponseEntity<ApiResponse<UtilisateurResponse>> deletePhoto(@PathVariable Long id) {
        securityUtils.assertOwnerOrAdmin(id);  // 403 si ce n'est pas son profil

        var auditeur = auditeurRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Auditeur non trouvé id: " + id));

        if (auditeur.getPhotoProfil() != null && !auditeur.getPhotoProfil().isBlank()) {
            minioService.deleteFile(auditeur.getPhotoProfil(), BUCKET_PHOTOS_PROFILS);
            auditeur.setPhotoProfil(null);
            auditeurRepository.save(auditeur);
        }

        return ResponseEntity.ok(ApiResponse.success(
                "Photo de profil supprimée.",
                UtilisateurResponse.fromEntity(auditeur)));
    }
}
