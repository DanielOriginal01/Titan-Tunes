package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.EvenementCreateRequest;
import dan.com.titan_tune.dtos.dtoresponse.EvenementResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.entities.Evenement;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.ArtisteRepository;
import dan.com.titan_tune.repository.EvenementRepository;
import dan.com.titan_tune.service.EvenementService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EvenementServiceImpl implements EvenementService {

    private final EvenementRepository evenementRepository;
    private final ArtisteRepository   artisteRepository;

    @Override
    @Transactional
    public EvenementResponse creer(EvenementCreateRequest request) {
        var artiste = artisteRepository.findById(request.artisteId())
                .orElseThrow(() -> new ResourceNotFoundException("Artiste non trouvé id: " + request.artisteId()));

        var evenement = Evenement.builder()
                .nameConcert(request.nameConcert())
                .dateEvenement(request.dateEvenement())
                .dateLimite(request.dateLimite())
                .lieu(request.lieu())
                .prixTicket(request.prixTicket())
                .artiste(artiste)
                .build();

        return EvenementResponse.fromEntity(evenementRepository.save(evenement));
    }

    @Override
    @Transactional(readOnly = true)
    public EvenementResponse getById(Long id) {
        var ev = evenementRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Événement non trouvé id: " + id));
        return EvenementResponse.fromEntity(ev);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EvenementResponse> getAll() {
        return evenementRepository.findAll().stream()
                .map(EvenementResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<EvenementResponse> getAll(Pageable pageable) {
        Page<Evenement> page = evenementRepository.findAll(pageable);
        return PageResponse.from(page, EvenementResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EvenementResponse> getByArtiste(Long artisteId) {
        return evenementRepository.findByArtisteId(artisteId).stream()
                .map(EvenementResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<EvenementResponse> getByArtiste(Long artisteId, Pageable pageable) {
        Page<Evenement> page = evenementRepository.findByArtisteId(artisteId, pageable);
        return PageResponse.from(page, EvenementResponse::fromEntity);
    }

    @Override
    @Transactional
    public void supprimer(Long id) {
        if (!evenementRepository.existsById(id)) {
            throw new ResourceNotFoundException("Événement non trouvé id: " + id);
        }
        evenementRepository.deleteById(id);
    }
}
