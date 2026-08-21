package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtoresponse.*;
import dan.com.titan_tune.enums.Statut;
import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.repository.*;
import dan.com.titan_tune.service.RechercheService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RechercheServiceImpl implements RechercheService {

    private final ChansonRepository  chansonRepository;
    private final ArtisteRepository  artisteRepository;
    private final AlbumRepository    albumRepository;
    private final PlaylistRepository playlistRepository;

    @Override
    @Transactional(readOnly = true)
    public SearchResponse rechercher(String query, int limit) {
        if (query == null || query.isBlank()) {
            throw new BusinessException("Le terme de recherche ne peut pas être vide.", HttpStatus.BAD_REQUEST);
        }

        String q = query.trim();

        // ── Chansons : recherche sur titre ET nom d'artiste (actifs uniquement) ─
        List<ChansonResponse> chansons = chansonRepository
                .searchByTitreOrArtisteActif(q)
                .stream()
                .limit(limit)
                .map(ChansonResponse::fromEntity)
                .toList();

        // ── Artistes : recherche sur artistName et username (actifs uniquement) ─
        List<ArtisteResponse> artistes = artisteRepository
                .findByArtistNameContainingIgnoreCaseOrUsernameContainingIgnoreCaseAndStatus(q, q, Statut.ACTIF)
                .stream()
                .limit(limit)
                .map(ArtisteResponse::fromEntity)
                .toList();

        // ── Albums : recherche sur le titre ───────────────────────────────────
        List<AlbumResponse> albums = albumRepository
                .findByTitleContainingIgnoreCase(q)
                .stream()
                .limit(limit)
                .map(AlbumResponse::fromEntity)
                .toList();

        // ── Playlists publiques : recherche sur le titre ──────────────────────
        List<PlaylistResponse> playlists = playlistRepository
                .findByPriveeFalseAndTitleContainingIgnoreCase(q)
                .stream()
                .limit(limit)
                .map(PlaylistResponse::fromEntity)
                .toList();

        int total = chansons.size() + artistes.size() + albums.size() + playlists.size();

        return new SearchResponse(q, total, chansons, artistes, albums, playlists);
    }
}
