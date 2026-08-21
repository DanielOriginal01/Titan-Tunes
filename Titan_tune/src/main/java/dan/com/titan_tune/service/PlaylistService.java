package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.PlaylistCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.dtos.dtoresponse.PlaylistResponse;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface PlaylistService {
    PlaylistResponse creerPlaylist(PlaylistCreateRequest request);
    PlaylistResponse ajouterChanson(Long playlistId, Long chansonId);
    PlaylistResponse retirerChanson(Long playlistId, Long chansonId);
    PlaylistResponse getPlaylistById(Long id);
    List<PlaylistResponse> getPlaylistsByAuditeur(Long auditeurId);
    PageResponse<PlaylistResponse> getPlaylistsByAuditeur(Long auditeurId, Pageable pageable);
    PageResponse<PlaylistResponse> getAllPlaylists(Pageable pageable);
    void supprimerPlaylist(Long playlistId);
}