package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.AlbumCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.AlbumResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.entities.Album;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.AlbumRepository;
import dan.com.titan_tune.repository.ArtisteRepository;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.AlbumService;
import dan.com.titan_tune.service.MinioService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.InputStreamResource;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AlbumServiceImpl implements AlbumService {

    private final AlbumRepository albumRepository;
    private final ArtisteRepository artisteRepository;
    private final MinioService minioService;
    private final SecurityUtils securityUtils;

    private static final String BUCKET_COVERS = "covers";

    @Override
    @Transactional
    public AlbumResponse creerAlbum(AlbumCreateRequest request) {
        return creerAlbum(request, null);
    }

    @Override
    @Transactional
    public AlbumResponse creerAlbum(AlbumCreateRequest request, MultipartFile coverFile) {
        Long artisteId = request.artisteId() != null ? request.artisteId() : securityUtils.getCurrentUserId();

        var artiste = artisteRepository.findById(artisteId)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + artisteId));

        String coverFileName = null;
        if (coverFile != null && !coverFile.isEmpty()) {
            coverFileName = minioService.uploadFile(coverFile, BUCKET_COVERS);
        } else if (request.coverImage() != null && !request.coverImage().isBlank()) {
            coverFileName = request.coverImage();
        }

        var album = Album.builder()
                .title(request.title())
                .dateSortie(request.dateSortie())
                .coverImage(coverFileName)
                .artiste(artiste)
                .build();

        return AlbumResponse.fromEntity(albumRepository.save(album));
    }

    @Override
    @Transactional
    public AlbumResponse modifierAlbum(Long id, AlbumCreateRequest request) {
        return modifierAlbum(id, request, null);
    }

    @Override
    @Transactional
    public AlbumResponse modifierAlbum(Long id, AlbumCreateRequest request, MultipartFile coverFile) {
        var album = albumRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Album non trouvé id: " + id));

        securityUtils.assertOwnerOrAdmin(album.getArtiste().getId());

        if (coverFile != null && !coverFile.isEmpty()) {
            if (album.getCoverImage() != null && !album.getCoverImage().isBlank()) {
                minioService.deleteFile(album.getCoverImage(), BUCKET_COVERS);
            }
            album.setCoverImage(minioService.uploadFile(coverFile, BUCKET_COVERS));
        } else if (request.coverImage() != null && !request.coverImage().isBlank()) {
            album.setCoverImage(request.coverImage());
        }

        if (request.title() != null && !request.title().isBlank()) {
            album.setTitle(request.title());
        }
        if (request.dateSortie() != null) {
            album.setDateSortie(request.dateSortie());
        }

        return AlbumResponse.fromEntity(albumRepository.save(album));
    }

    @Override
    @Transactional
    public void supprimerAlbum(Long id) {
        var album = albumRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Album non trouvé id: " + id));

        securityUtils.assertOwnerOrAdmin(album.getArtiste().getId());

        if (album.getCoverImage() != null && !album.getCoverImage().isBlank()) {
            minioService.deleteFile(album.getCoverImage(), BUCKET_COVERS);
        }

        albumRepository.delete(album);
    }

    @Override
    @Transactional(readOnly = true)
    public AlbumResponse getAlbumById(Long id) {
        var album = albumRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Album non trouvé id: " + id));
        return AlbumResponse.fromEntity(album);
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<AlbumResponse> getAllAlbums(Pageable pageable) {
        Page<Album> page = albumRepository.findAll(pageable);
        return PageResponse.from(page, AlbumResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AlbumResponse> getAlbumsByArtiste(Long artisteId) {
        return albumRepository.findByArtisteId(artisteId)
                .stream()
                .map(AlbumResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public ResponseEntity<Resource> getCoverResource(Long idAlbum) {
        var album = albumRepository.findById(idAlbum)
                .orElseThrow(() -> new ResourceNotFoundException("Album non trouvé id: " + idAlbum));

        String coverImage = album.getCoverImage();
        if (coverImage != null && !coverImage.isBlank()) {
            try {
                InputStream is = minioService.getObject(coverImage, BUCKET_COVERS);
                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(determineImageContentType(coverImage)))
                        .header(HttpHeaders.CACHE_CONTROL, "public, max-age=86400")
                        .body(new InputStreamResource(is));
            } catch (Exception ignored) {}
        }
        return ResponseEntity.status(HttpStatus.FOUND)
                .header(HttpHeaders.LOCATION, "https://picsum.photos/seed/album-" + idAlbum + "/400/400")
                .build();
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
}
