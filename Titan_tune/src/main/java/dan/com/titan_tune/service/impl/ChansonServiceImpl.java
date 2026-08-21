package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.ChansonCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.ChansonResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.entities.Album;
import dan.com.titan_tune.entities.Chansons;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.AlbumRepository;
import dan.com.titan_tune.repository.ArtisteRepository;
import dan.com.titan_tune.repository.CategorieRepository;
import dan.com.titan_tune.repository.ChansonRepository;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.ChansonService;
import dan.com.titan_tune.service.MinioService;
import io.minio.StatObjectResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ByteArrayResource;
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
import java.net.URI;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChansonServiceImpl implements ChansonService {

    private final ChansonRepository chansonRepository;
    private final ArtisteRepository artisteRepository;
    private final CategorieRepository categorieRepository;
    private final AlbumRepository albumRepository;
    private final MinioService minioService;
    private final SecurityUtils securityUtils;

    private static final String BUCKET_CHANSONS = "chansons";
    private static final String BUCKET_COVERS = "covers";

    @Override
    @Transactional
    public ChansonResponse publierChanson(ChansonCreateRequest request, MultipartFile audioFile) {
        return publierChanson(request, audioFile, null);
    }

    @Override
    @Transactional
    public ChansonResponse publierChanson(ChansonCreateRequest request, MultipartFile audioFile, MultipartFile coverFile) {
        Long artisteId = request.artisteId() != null ? request.artisteId() : securityUtils.getCurrentUserId();

        var artiste = artisteRepository.findById(artisteId)
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + artisteId));

        var categorie = categorieRepository.findById(request.categorieId())
                .orElseThrow(() -> new ResourceNotFoundException("Catégorie non trouvée id: " + request.categorieId()));

        Album album = null;
        if (request.albumId() != null) {
            album = albumRepository.findById(request.albumId())
                    .orElseThrow(() -> new ResourceNotFoundException("Album non trouvé id: " + request.albumId()));
            if (!album.getArtiste().getId().equals(artiste.getId())) {
                throw new BusinessException("L'album spécifié n'appartient pas à cet artiste.");
            }
        }

        var audioFileName = minioService.uploadFile(audioFile, BUCKET_CHANSONS);

        String coverFileName = null;
        if (coverFile != null && !coverFile.isEmpty()) {
            coverFileName = minioService.uploadFile(coverFile, BUCKET_COVERS);
        } else if (request.coverImage() != null && !request.coverImage().isBlank()) {
            coverFileName = request.coverImage();
        }

        var chanson = Chansons.builder()
                .titre(request.titre())
                .duree(request.duree())
                .parole(request.parole())
                .audioUrl(audioFileName)
                .coverImage(coverFileName)
                .artiste(artiste)
                .categorie(categorie)
                .album(album)
                .build();

        var saved = chansonRepository.save(chanson);
        return ChansonResponse.fromEntity(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public ChansonResponse getChansonById(Long idChanson) {
        var chanson = chansonRepository.findById(idChanson)
                .orElseThrow(() -> new ResourceNotFoundException("Chanson non trouvée id: " + idChanson));
        return ChansonResponse.fromEntity(chanson);
    }

    @Override
    public String getStreamingUrl(Long idChanson) {
        var chanson = chansonRepository.findById(idChanson)
                .orElseThrow(() -> new ResourceNotFoundException("Chanson non trouvée id: " + idChanson));

        String audioUrl = chanson.getAudioUrl();
        if (audioUrl != null && (audioUrl.startsWith("http://") || audioUrl.startsWith("https://"))) {
            return audioUrl;
        }

        return minioService.getPresignedUrl(audioUrl, BUCKET_CHANSONS);
    }

    @Override
    @Transactional(readOnly = true)
    public ResponseEntity<Resource> streamAudioResource(Long idChanson, String rangeHeader) {
        var chanson = chansonRepository.findById(idChanson)
                .orElseThrow(() -> new ResourceNotFoundException("Chanson non trouvée id: " + idChanson));

        String audioUrl = chanson.getAudioUrl();
        if (audioUrl == null || audioUrl.isBlank()) {
            throw new ResourceNotFoundException("Aucun fichier audio associé à ce morceau.");
        }

        // Si c'est déjà une URL HTTP publique externe
        if (audioUrl.startsWith("http://") || audioUrl.startsWith("https://")) {
            return ResponseEntity.status(HttpStatus.FOUND)
                    .location(URI.create(audioUrl))
                    .build();
        }

        // Récupération des métadonnées de l'objet MinIO
        StatObjectResponse stat = minioService.statObject(audioUrl, BUCKET_CHANSONS);
        if (stat == null) {
            log.warn("Fichier audio non trouvé dans MinIO : {}", audioUrl);
            // Fallback audio démo pour éviter le blocage de l'UI
            int songIndex = (int) ((chanson.getId() % 12) + 1);
            String fallbackUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-" + songIndex + ".mp3";
            return ResponseEntity.status(HttpStatus.FOUND)
                    .location(URI.create(fallbackUrl))
                    .build();
        }

        long fileSize = stat.size();
        String contentType = detectAudioContentType(audioUrl, stat.contentType());

        // Gestion du Byte-Range HTTP 206 (Seeking / Scrubbing)
        if (rangeHeader != null && rangeHeader.startsWith("bytes=")) {
            String rangeValue = rangeHeader.substring(6).trim();
            String[] parts = rangeValue.split("-");
            long start = 0;
            long end = fileSize - 1;

            try {
                if (parts[0].length() > 0) {
                    start = Long.parseLong(parts[0]);
                }
                if (parts.length > 1 && parts[1].length() > 0) {
                    end = Long.parseLong(parts[1]);
                }
            } catch (NumberFormatException e) {
                log.warn("En-tête Range invalide : {}", rangeHeader);
            }

            if (start > end || start >= fileSize) {
                return ResponseEntity.status(HttpStatus.REQUESTED_RANGE_NOT_SATISFIABLE)
                        .header(HttpHeaders.CONTENT_RANGE, "bytes */" + fileSize)
                        .build();
            }

            end = Math.min(end, fileSize - 1);
            long contentLength = end - start + 1;

            InputStream is = minioService.getObjectRange(audioUrl, BUCKET_CHANSONS, start, contentLength);
            if (is == null) {
                throw new ResourceNotFoundException("Impossible de lire le segment audio.");
            }

            return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
                    .header(HttpHeaders.CONTENT_TYPE, contentType)
                    .header(HttpHeaders.ACCEPT_RANGES, "bytes")
                    .header(HttpHeaders.CONTENT_RANGE, "bytes " + start + "-" + end + "/" + fileSize)
                    .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(contentLength))
                    .header(HttpHeaders.CACHE_CONTROL, "public, max-age=86400")
                    .body(new InputStreamResource(is));
        }

        // Flux complet 200 OK
        InputStream is = minioService.getObject(audioUrl, BUCKET_CHANSONS);
        if (is == null) {
            throw new ResourceNotFoundException("Impossible de lire le fichier audio.");
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, contentType)
                .header(HttpHeaders.ACCEPT_RANGES, "bytes")
                .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(fileSize))
                .header(HttpHeaders.CACHE_CONTROL, "public, max-age=86400")
                .body(new InputStreamResource(is));
    }

    @Override
    @Transactional(readOnly = true)
    public ResponseEntity<Resource> getCoverResource(Long idChanson) {
        var chanson = chansonRepository.findById(idChanson)
                .orElseThrow(() -> new ResourceNotFoundException("Chanson non trouvée id: " + idChanson));

        String cover = chanson.getCoverImage();
        if ((cover == null || cover.isBlank()) && chanson.getAlbum() != null) {
            cover = chanson.getAlbum().getCoverImage();
        }

        if (cover == null || cover.isBlank()) {
            return ResponseEntity.status(HttpStatus.FOUND)
                    .location(URI.create("https://picsum.photos/seed/song-" + chanson.getId() + "/400/400"))
                    .build();
        }

        if (cover.startsWith("http://") || cover.startsWith("https://")) {
            return ResponseEntity.status(HttpStatus.FOUND)
                    .location(URI.create(cover))
                    .build();
        }

        StatObjectResponse stat = minioService.statObject(cover, BUCKET_COVERS);
        if (stat == null) {
            return ResponseEntity.status(HttpStatus.FOUND)
                    .location(URI.create("https://picsum.photos/seed/cover-" + chanson.getId() + "/400/400"))
                    .build();
        }

        InputStream is = minioService.getObject(cover, BUCKET_COVERS);
        if (is == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        String mediaType = cover.toLowerCase().endsWith(".png") ? MediaType.IMAGE_PNG_VALUE : MediaType.IMAGE_JPEG_VALUE;

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, mediaType)
                .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(stat.size()))
                .header(HttpHeaders.CACHE_CONTROL, "public, max-age=604800")
                .body(new InputStreamResource(is));
    }

    private String detectAudioContentType(String fileName, String minioContentType) {
        if (minioContentType != null && !minioContentType.isBlank() && !minioContentType.equals("application/octet-stream")) {
            return minioContentType;
        }
        String lower = fileName.toLowerCase();
        if (lower.endsWith(".wav")) return "audio/wav";
        if (lower.endsWith(".ogg")) return "audio/ogg";
        if (lower.endsWith(".m4a")) return "audio/mp4";
        if (lower.endsWith(".flac")) return "audio/flac";
        return "audio/mpeg";
    }

    @Override
    @Transactional(readOnly = true)
    public List<ChansonResponse> rechercherChansons(String query) {
        return chansonRepository.searchByTitreOrArtiste(query)
                .stream()
                .map(ChansonResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<ChansonResponse> rechercherChansons(String query, Pageable pageable) {
        Page<Chansons> page = chansonRepository.searchByTitreOrArtiste(query, pageable);
        return PageResponse.from(page, ChansonResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ChansonResponse> getTopTendances() {
        return chansonRepository.findAll(Pageable.ofSize(10)).stream()
                .map(ChansonResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<ChansonResponse> getTopTendances(Pageable pageable) {
        Page<Chansons> page = chansonRepository.findAll(pageable);
        return PageResponse.from(page, ChansonResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<ChansonResponse> getAllChansons(Pageable pageable) {
        Page<Chansons> page = chansonRepository.findAll(pageable);
        return PageResponse.from(page, ChansonResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<ChansonResponse> getChansonsByArtiste(Long artisteId, Pageable pageable) {
        Page<Chansons> page = chansonRepository.findByArtisteId(artisteId, pageable);
        return PageResponse.from(page, ChansonResponse::fromEntity);
    }

    @Override
    @Transactional
    public void supprimerChanson(Long idChanson) {
        var chanson = chansonRepository.findById(idChanson)
                .orElseThrow(() -> new ResourceNotFoundException("Chanson non trouvée id: " + idChanson));

        if (chanson.getAudioUrl() != null) {
            minioService.deleteFile(chanson.getAudioUrl(), BUCKET_CHANSONS);
        }
        if (chanson.getCoverImage() != null) {
            minioService.deleteFile(chanson.getCoverImage(), BUCKET_COVERS);
        }

        chansonRepository.delete(chanson);
    }
}
