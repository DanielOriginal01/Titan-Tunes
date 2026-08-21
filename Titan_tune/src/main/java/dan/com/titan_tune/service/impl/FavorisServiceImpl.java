package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.FavorisRequest;
import dan.com.titan_tune.dtos.dtoresponse.FavorisResponse;
import dan.com.titan_tune.entities.*;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.*;
import dan.com.titan_tune.service.FavorisService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FavorisServiceImpl implements FavorisService {

    private final FavorisRepository favorisRepository;
    private final FavorisChansonRepository favorisChansonRepository;
    private final FavorisAlbumRepository favorisAlbumRepository;
    private final FavorisArtisteRepository favorisArtisteRepository;
    private final FavorisPlaylistRepository favorisPlaylistRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final ChansonRepository chansonRepository;
    private final AlbumRepository albumRepository;
    private final ArtisteRepository artisteRepository;
    private final PlaylistRepository playlistRepository;

    @Override
    @Transactional
    public FavorisResponse ajouterFavori(FavorisRequest request) {
        var user = utilisateurRepository.findById(request.utilisateurId())
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur non trouvé id: " + request.utilisateurId()));

        return switch (request.type().toUpperCase()) {
            case "CHANSON" -> {
                if (favorisChansonRepository.existsByUtilisateurIdAndChansonId(user.getId(), request.targetId())) {
                    throw new BusinessException("Chanson déjà en favoris");
                }
                var chanson = chansonRepository.findById(request.targetId())
                        .orElseThrow(() -> new ResourceNotFoundException("Chanson non trouvée id: " + request.targetId()));
                var fav = FavorisChanson.builder().utilisateur(user).chanson(chanson).build();
                yield FavorisResponse.fromEntity(favorisChansonRepository.save(fav), "CHANSON");
            }
            case "ALBUM" -> {
                var album = albumRepository.findById(request.targetId())
                        .orElseThrow(() -> new ResourceNotFoundException("Album non trouvé id: " + request.targetId()));
                var fav = FavorisAlbum.builder().utilisateur(user).album(album).build();
                yield FavorisResponse.fromEntity(favorisAlbumRepository.save(fav), "ALBUM");
            }
            case "ARTISTE" -> {
                var artiste = artisteRepository.findById(request.targetId())
                        .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + request.targetId()));
                var fav = FavorisArtiste.builder().utilisateur(user).artiste(artiste).build();
                yield FavorisResponse.fromEntity(favorisArtisteRepository.save(fav), "ARTISTE");
            }
            case "PLAYLIST" -> {
                var playlist = playlistRepository.findById(request.targetId())
                        .orElseThrow(() -> new ResourceNotFoundException("Playlist non trouvée id: " + request.targetId()));
                var fav = FavorisPlaylist.builder().utilisateur(user).playlist(playlist).build();
                yield FavorisResponse.fromEntity(favorisPlaylistRepository.save(fav), "PLAYLIST");
            }
            default -> throw new BusinessException("Type de favori non supporté: " + request.type());
        };
    }

    @Override
    @Transactional
    public void retirerFavori(Long userId, Long targetId, String type) {
        switch (type.toUpperCase()) {
            case "CHANSON" -> favorisChansonRepository.findByUtilisateurIdAndChansonId(userId, targetId)
                    .ifPresent(favorisChansonRepository::delete);
            case "ALBUM" -> favorisAlbumRepository.findByUtilisateurIdAndAlbumId(userId, targetId)
                    .ifPresent(favorisAlbumRepository::delete);
            case "ARTISTE" -> favorisArtisteRepository.findByUtilisateurIdAndArtisteId(userId, targetId)
                    .ifPresent(favorisArtisteRepository::delete);
            case "PLAYLIST" -> favorisPlaylistRepository.findByUtilisateurIdAndPlaylistId(userId, targetId)
                    .ifPresent(favorisPlaylistRepository::delete);
            default -> throw new BusinessException("Type de favori non supporté: " + type);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<FavorisResponse> getFavorisByUser(Long userId) {
        return favorisRepository.findByUtilisateurId(userId)
                .stream()
                .map(f -> FavorisResponse.fromEntity(f, f.getClass().getSimpleName().replace("Favoris", "").toUpperCase()))
                .toList();
    }
}