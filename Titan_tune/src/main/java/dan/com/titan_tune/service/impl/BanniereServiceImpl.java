package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.BanniereRequest;
import dan.com.titan_tune.dtos.dtoresponse.BanniereResponse;
import dan.com.titan_tune.entities.Banniere;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.AlbumRepository;
import dan.com.titan_tune.repository.ArtisteRepository;
import dan.com.titan_tune.repository.BanniereRepository;
import dan.com.titan_tune.repository.ChansonRepository;
import dan.com.titan_tune.service.BanniereService;
import dan.com.titan_tune.service.MinioService;
import dan.com.titan_tune.service.NotificationPromoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class BanniereServiceImpl implements BanniereService {

    private static final String BUCKET_BANNIERES = "bannieres";

    private final BanniereRepository      banniereRepository;
    private final ArtisteRepository       artisteRepository;
    private final AlbumRepository         albumRepository;
    private final ChansonRepository       chansonRepository;
    private final MinioService            minioService;
    private final NotificationPromoService notificationPromoService;

    @Override
    @Transactional
    public BanniereResponse creer(BanniereRequest request, MultipartFile image) {
        var artiste = artisteRepository.findById(request.artisteId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Artiste non trouvé id: " + request.artisteId()));

        if (image == null || image.isEmpty()) {
            throw new BusinessException("L'image de la bannière est obligatoire.");
        }

        var imageUrl = minioService.uploadFile(image, BUCKET_BANNIERES);

        var builder = Banniere.builder()
                .titre(request.titre())
                .description(request.description())
                .imageUrl(imageUrl)
                .lienCible(request.lienCible())
                .typePromotion(request.typePromotion())
                .active(false)
                .dateDebut(request.dateDebut())
                .dateFin(request.dateFin())
                .artiste(artiste);

        if (request.albumId() != null) {
            var album = albumRepository.findById(request.albumId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Album non trouvé id: " + request.albumId()));
            builder.album(album);
        }

        if (request.chansonId() != null) {
            var chanson = chansonRepository.findById(request.chansonId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Chanson non trouvée id: " + request.chansonId()));
            builder.chanson(chanson);
        }

        return BanniereResponse.fromEntity(banniereRepository.save(builder.build()));
    }

    @Override
    @Transactional(readOnly = true)
    public BanniereResponse getById(Long id) {
        return BanniereResponse.fromEntity(findOrThrow(id));
    }

    @Override
    @Transactional(readOnly = true)
    public List<BanniereResponse> getByArtiste(Long artisteId) {
        return banniereRepository.findByArtisteId(artisteId).stream()
                .map(BanniereResponse::fromEntity).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<BanniereResponse> getActives() {
        return banniereRepository.findByActiveTrueAndDateFinAfter(LocalDateTime.now()).stream()
                .map(BanniereResponse::fromEntity).toList();
    }

    /**
     * Active la bannière et envoie une notification push à tous les auditeurs.
     */
    @Override
    @Transactional
    public BanniereResponse activer(Long id) {
        var banniere = findOrThrow(id);
        banniere.setActive(true);
        if (banniere.getDateDebut() == null) banniere.setDateDebut(LocalDateTime.now());
        var saved = banniereRepository.save(banniere);

        // Notification push asynchrone à tous les auditeurs
        String msg = String.format("🎵 %s présente : %s — Découvrez maintenant !",
                banniere.getArtiste().getArtistName(), banniere.getTitre());
        notificationPromoService.notifierSortiePourTousLesAuditeurs(
                banniere.getArtiste().getId(),
                "🔥 Nouveau " + banniere.getTypePromotion().name().toLowerCase() + " disponible !",
                msg,
                banniere.getTypePromotion()
        );

        return BanniereResponse.fromEntity(saved);
    }

    @Override
    @Transactional
    public BanniereResponse desactiver(Long id) {
        var banniere = findOrThrow(id);
        banniere.setActive(false);
        return BanniereResponse.fromEntity(banniereRepository.save(banniere));
    }

    @Override
    @Transactional
    public void supprimer(Long id) {
        if (!banniereRepository.existsById(id)) {
            throw new ResourceNotFoundException("Bannière non trouvée id: " + id);
        }
        banniereRepository.deleteById(id);
    }

    private Banniere findOrThrow(Long id) {
        return banniereRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Bannière non trouvée id: " + id));
    }
}
