package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.EcouteRecordRequest;
import dan.com.titan_tune.dtos.dtoresponse.EcouteResponse;
import dan.com.titan_tune.dtos.dtoresponse.PageResponse;
import dan.com.titan_tune.entities.Ecoute;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.AuditeurRepository;
import dan.com.titan_tune.repository.ChansonRepository;
import dan.com.titan_tune.repository.EcouteRepository;
import dan.com.titan_tune.service.EcouteService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EcouteServiceImpl implements EcouteService {

    private final EcouteRepository ecouteRepository;
    private final AuditeurRepository auditeurRepository;
    private final ChansonRepository chansonRepository;

    @Async
    @Override
    @Transactional
    public void enregistrerEcouteAsync(EcouteRecordRequest request) {
        enregistrerEcoute(request);
    }

    @Override
    @Transactional
    public EcouteResponse enregistrerEcoute(EcouteRecordRequest request) {
        var auditeur = auditeurRepository.findById(request.auditeurId())
                .orElseThrow(() -> new ResourceNotFoundException("Auditeur non trouvé id: " + request.auditeurId()));

        var chanson = chansonRepository.findById(request.chansonId())
                .orElseThrow(() -> new ResourceNotFoundException("Chanson non trouvée id: " + request.chansonId()));

        // Enregistre l'écoute dans l'historique
        var ecoute = Ecoute.builder()
                .auditeur(auditeur)
                .chanson(chanson)
                .dureeEcoute(request.dureeEcoute())
                .build();

        var saved = ecouteRepository.save(ecoute);

        // Incrémente atomiquement le compteur (UPDATE direct, évite les race conditions)
        chansonRepository.incrementNbEcoutes(chanson.getId());

        return EcouteResponse.fromEntity(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EcouteResponse> getHistoriqueAuditeur(Long auditeurId) {
        return ecouteRepository.findByAuditeurId(auditeurId)
                .stream()
                .map(EcouteResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public PageResponse<EcouteResponse> getHistoriqueAuditeur(Long auditeurId, Pageable pageable) {
        Page<Ecoute> page = ecouteRepository.findByAuditeurId(auditeurId, pageable);
        return PageResponse.from(page, EcouteResponse::fromEntity);
    }
}
