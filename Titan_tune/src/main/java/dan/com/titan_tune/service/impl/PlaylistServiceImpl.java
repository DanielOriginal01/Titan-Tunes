package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.PlaylistCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.dtos.dtoresponse.PlaylistResponse;
import dan.com.titan_tune.entities.Playlist;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.AuditeurRepository;
import dan.com.titan_tune.repository.ChansonRepository;
import dan.com.titan_tune.repository.PlaylistRepository;
import dan.com.titan_tune.service.PlaylistService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PlaylistServiceImpl implements PlaylistService {

    private final PlaylistRepository playlistRepository;
    private final AuditeurRepository auditeurRepository;
    private final ChansonRepository chansonRepository;

    @Override
    @Transactional
    public PlaylistResponse creerPlaylist(PlaylistCreateRequest request) {
        var auditeur = auditeurRepository.findById(request.auditeurId())
                .orElseThrow(() -> new ResourceNotFoundException("Auditeur non trouvé id: " + request.auditeurId()));

        var playlist = Playlist.builder()
                .title(request.title())
                .description(request.description())
                .privee(request.privee())
                .auditeur(auditeur)
                .build();

        var saved = playlistRepository.save(playlist);
        return PlaylistResponse.fromEntity(saved);
    }

    @Override
    @Transactional
    public PlaylistResponse ajouterChanson(Long playlistId, Long chansonId) {
        var playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new ResourceNotFoundException("Playlist non trouvée id: " + playlistId));
        var chanson = chansonRepository.findById(chansonId)
                .orElseThrow(() -> new ResourceNotFoundException("Chanson non trouvée id: " + chansonId));

        playlist.getChansons().add(chanson);
        return PlaylistResponse.fromEntity(playlistRepository.save(playlist));
    }

    @Override
    @Transactional
    public PlaylistResponse retirerChanson(Long playlistId, Long chansonId) {
        var playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new ResourceNotFoundException("Playlist non trouvée id: " + playlistId));
        var chanson = chansonRepository.findById(chansonId)
                .orElseThrow(() -> new ResourceNotFoundException("Chanson non trouvée id: " + chansonId));

        playlist.getChansons().remove(chanson);
        return PlaylistResponse.fromEntity(playlistRepository.save(playlist));
    }

    @Override
    @Transactional(readOnly = true)
    public PlaylistResponse getPlaylistById(Long id) {
        var playlist = playlistRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Playlist non trouvée id: " + id));
        return PlaylistResponse.fromEntity(playlist);
    }

    @Override
    @Transactional(readOnly = true)
    public List<PlaylistResponse> getPlaylistsByAuditeur(Long auditeurId) {
        return playlistRepository.findByAuditeurId(auditeurId)
                .stream()
                .map(PlaylistResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<PlaylistResponse> getPlaylistsByAuditeur(Long auditeurId, Pageable pageable) {
        Page<Playlist> page = playlistRepository.findByAuditeurId(auditeurId, pageable);
        return PageResponse.from(page, PlaylistResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<PlaylistResponse> getAllPlaylists(Pageable pageable) {
        Page<Playlist> page = playlistRepository.findByPriveeFalse(pageable);
        return PageResponse.from(page, PlaylistResponse::fromEntity);
    }

    @Override
    @Transactional
    public void supprimerPlaylist(Long playlistId) {
        if (!playlistRepository.existsById(playlistId)) {
            throw new ResourceNotFoundException("Playlist non trouvée id: " + playlistId);
        }
        playlistRepository.deleteById(playlistId);
    }
}