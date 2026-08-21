package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtoresponse.ArtisteResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.dtos.dtoresponse.StatistiquesArtisteResponse;
import dan.com.titan_tune.enums.Statut;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.ArtisteRepository;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.ArtisteDashboardService;
import dan.com.titan_tune.service.MinioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.InputStreamResource;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@RestController
@RequestMapping(value = "/api/v1/artistes", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class ArtisteController {

    private final ArtisteRepository       artisteRepository;
    private final MinioService             minioService;
    private final ArtisteDashboardService  dashboardService;
    private final SecurityUtils            securityUtils;

    private static final String BUCKET_PHOTOS_COUVERTURE = "photos-couverture";
    private static final String BUCKET_PHOTOS_PROFILS    = "photos-profils";

    // ── Lecture publique ───────────────────────────────────────────────────────

    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<ArtisteResponse>>> getAll(
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable) {
        var page = artisteRepository.findByStatus(Statut.ACTIF, pageable);
        return ResponseEntity.ok(ApiResponse.success(
                "Liste des artistes récupérée.",
                PageResponse.from(page, ArtisteResponse::fromEntity)
        ));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ArtisteResponse>> getById(@PathVariable Long id) {
        var artiste = artisteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + id));
        return ResponseEntity.ok(ApiResponse.success("Artiste trouvé.", ArtisteResponse.fromEntity(artiste)));
    }

    /** Stream binaire direct de la photo de couverture / bannière de l'artiste. */
    @GetMapping(value = "/{id}/photo", produces = {MediaType.IMAGE_JPEG_VALUE, MediaType.IMAGE_PNG_VALUE, "image/webp"})
    public ResponseEntity<Resource> getPhoto(@PathVariable Long id) {
        var artiste = artisteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + id));

        String photo = artiste.getPhotoCouverture();
        if (photo != null && !photo.isBlank()) {
            try {
                InputStream is = minioService.getObject(photo, BUCKET_PHOTOS_COUVERTURE);
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(determineImageContentType(photo)))
                        .header(HttpHeaders.CACHE_CONTROL, "public, max-age=86400")
                        .body(new InputStreamResource(is));
            } catch (Exception ignored) {}
        }
        return ResponseEntity.status(HttpStatus.FOUND)
                .header(HttpHeaders.LOCATION, "https://picsum.photos/seed/artist-banner-" + id + "/1200/400")
                .build();
    }

    /** Stream binaire direct de la photo de profil / avatar de l'artiste. */
    @GetMapping(value = "/{id}/photo-profil", produces = {MediaType.IMAGE_JPEG_VALUE, MediaType.IMAGE_PNG_VALUE, "image/webp"})
    public ResponseEntity<Resource> getPhotoProfil(@PathVariable Long id) {
        var artiste = artisteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + id));

        String photo = artiste.getPhotoProfil();
        if (photo != null && !photo.isBlank()) {
            try {
                InputStream is = minioService.getObject(photo, BUCKET_PHOTOS_PROFILS);
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(determineImageContentType(photo)))
                        .header(HttpHeaders.CACHE_CONTROL, "public, max-age=86400")
                        .body(new InputStreamResource(is));
            } catch (Exception ignored) {}
        }

        String displayName = artiste.getArtistName() != null ? artiste.getArtistName() : artiste.getUsername();
        String safeName = (displayName != null && !displayName.isBlank()) ? displayName : "Artiste";
        String fallbackUrl = "https://ui-avatars.com/api/?name=" + URLEncoder.encode(safeName, StandardCharsets.UTF_8) + "&background=f97316&color=fff&size=256";

        return ResponseEntity.status(HttpStatus.FOUND)
                .header(HttpHeaders.LOCATION, fallbackUrl)
                .build();
    }

    @GetMapping("/{id}/photo/url")
    public ResponseEntity<ApiResponse<String>> getPhotoUrl(@PathVariable Long id) {
        var artiste = artisteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + id));
        if (artiste.getPhotoCouverture() == null || artiste.getPhotoCouverture().isBlank()) {
            return ResponseEntity.ok(ApiResponse.success("Aucune photo enregistrée.", null));
        }
        String url = minioService.getPresignedUrl(artiste.getPhotoCouverture(), BUCKET_PHOTOS_COUVERTURE);
        return ResponseEntity.ok(ApiResponse.success("URL de la photo générée.", url));
    }

    @GetMapping("/{id}/photo-profil/url")
    public ResponseEntity<ApiResponse<String>> getPhotoProfilUrl(@PathVariable Long id) {
        var artiste = artisteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + id));
        if (artiste.getPhotoProfil() == null || artiste.getPhotoProfil().isBlank()) {
            return ResponseEntity.ok(ApiResponse.success("Aucune photo de profil enregistrée.", null));
        }
        String url = minioService.getPresignedUrl(artiste.getPhotoProfil(), BUCKET_PHOTOS_PROFILS);
        return ResponseEntity.ok(ApiResponse.success("URL de la photo de profil générée.", url));
    }

    // ── Mise à jour profil — seulement le propriétaire ou ADMIN ──────────────

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<ArtisteResponse>> update(
            @PathVariable Long id,
            @RequestBody @Valid ArtisteUpdateRequest request) {
        securityUtils.assertOwnerOrAdmin(id);

        var artiste = artisteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + id));

        if (request.artistName()      != null) artiste.setArtistName(request.artistName());
        if (request.bio()             != null) artiste.setBio(request.bio());
        if (request.photoProfil()     != null) artiste.setPhotoProfil(request.photoProfil());
        if (request.photoCouverture() != null) artiste.setPhotoCouverture(request.photoCouverture());

        return ResponseEntity.ok(ApiResponse.success(
                "Profil mis à jour.", ArtisteResponse.fromEntity(artisteRepository.save(artiste))));
    }

    @PostMapping(value = "/{id}/photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<ArtisteResponse>> uploadPhoto(
            @PathVariable Long id,
            @RequestPart("photo") MultipartFile photo) {
        securityUtils.assertOwnerOrAdmin(id);

        var artiste = artisteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + id));

        if (artiste.getPhotoCouverture() != null && !artiste.getPhotoCouverture().isBlank()) {
            minioService.deleteFile(artiste.getPhotoCouverture(), BUCKET_PHOTOS_COUVERTURE);
        }

        String fileName = minioService.uploadFile(photo, BUCKET_PHOTOS_COUVERTURE);
        artiste.setPhotoCouverture(fileName);

        return ResponseEntity.ok(ApiResponse.success(
                "Photo de couverture mise à jour.",
                ArtisteResponse.fromEntity(artisteRepository.save(artiste))));
    }

    @PostMapping(value = "/{id}/photo-profil", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<ArtisteResponse>> uploadPhotoProfil(
            @PathVariable Long id,
            @RequestPart("photo") MultipartFile photo) {
        securityUtils.assertOwnerOrAdmin(id);

        var artiste = artisteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + id));

        if (artiste.getPhotoProfil() != null && !artiste.getPhotoProfil().isBlank()) {
            minioService.deleteFile(artiste.getPhotoProfil(), BUCKET_PHOTOS_PROFILS);
        }

        String fileName = minioService.uploadFile(photo, BUCKET_PHOTOS_PROFILS);
        artiste.setPhotoProfil(fileName);

        return ResponseEntity.ok(ApiResponse.success(
                "Photo de profil mise à jour.",
                ArtisteResponse.fromEntity(artisteRepository.save(artiste))));
    }

    @DeleteMapping("/{id}/photo-profil")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<ArtisteResponse>> deletePhotoProfil(@PathVariable Long id) {
        securityUtils.assertOwnerOrAdmin(id);

        var artiste = artisteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + id));

        if (artiste.getPhotoProfil() != null && !artiste.getPhotoProfil().isBlank()) {
            minioService.deleteFile(artiste.getPhotoProfil(), BUCKET_PHOTOS_PROFILS);
            artiste.setPhotoProfil(null);
            artisteRepository.save(artiste);
        }

        return ResponseEntity.ok(ApiResponse.success(
                "Photo de profil supprimée.",
                ArtisteResponse.fromEntity(artiste)));
    }

    @GetMapping("/{id}/dashboard")
    @PreAuthorize("hasAnyRole('ARTISTE', 'ADMIN')")
    public ResponseEntity<ApiResponse<StatistiquesArtisteResponse>> getDashboard(@PathVariable Long id) {
        securityUtils.assertOwnerOrAdmin(id);

        artisteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + id));

        Map<String, Object> finances = dashboardService.getStatistiquesFinancieres(id);

        var stats = new StatistiquesArtisteResponse(
                dashboardService.getTotalEcoutes(id),
                dashboardService.getAuditeursUniques(id),
                dashboardService.getImpactCatalogue(id),
                (Long) finances.get("totalAlbums"),
                0L,
                (Double) finances.get("royaltiesEstimees"),
                (String) finances.get("partCatalogue")
        );
        return ResponseEntity.ok(ApiResponse.success("Dashboard artiste récupéré.", stats));
    }

    private String determineImageContentType(String filename) {
        if (filename == null) return MediaType.IMAGE_JPEG_VALUE;
        String lower = filename.toLowerCase();
        if (lower.endsWith(".png")) return MediaType.IMAGE_PNG_VALUE;
        if (lower.endsWith(".webp")) return "image/webp";
        if (lower.endsWith(".gif")) return MediaType.IMAGE_GIF_VALUE;
        if (lower.endsWith(".svg")) return "image/svg+xml";
        return MediaType.IMAGE_JPEG_VALUE;
    }

    record ArtisteUpdateRequest(String artistName, String bio, String photoProfil, String photoCouverture) {
        public ArtisteUpdateRequest(String artistName, String bio, String photoCouverture) {
            this(artistName, bio, null, photoCouverture);
        }
    }
}
