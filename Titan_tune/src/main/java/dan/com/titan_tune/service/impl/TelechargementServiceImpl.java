package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.dtos.dtorequest.TelechargementRequest;
import dan.com.titan_tune.dtos.dtoresponse.TelechargementResponse;
import dan.com.titan_tune.entities.Telechargement;
import dan.com.titan_tune.exception.ResourceNotFoundException;
import dan.com.titan_tune.repository.AuditeurRepository;
import dan.com.titan_tune.repository.ChansonRepository;
import dan.com.titan_tune.repository.TelechargementRepository;
import dan.com.titan_tune.service.TelechargementService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TelechargementServiceImpl implements TelechargementService {

    private final TelechargementRepository telechargementRepository;
    private final AuditeurRepository       auditeurRepository;
    private final ChansonRepository        chansonRepository;

    @Override
    @Transactional
    public TelechargementResponse enregistrerTelechargement(TelechargementRequest request) {
        var auditeur = auditeurRepository.findById(request.auditeurId())
                .orElseThrow(() -> new ResourceNotFoundException("Auditeur non trouvé id: " + request.auditeurId()));

        var chanson = chansonRepository.findById(request.chansonId())
                .orElseThrow(() -> new ResourceNotFoundException("Chanson non trouvée id: " + request.chansonId()));

        var tele = Telechargement.builder()
                .auditeur(auditeur)
                .chanson(chanson)
                .build();

        return TelechargementResponse.fromEntity(telechargementRepository.save(tele));
    }

    @Override
    @Transactional(readOnly = true)
    public List<TelechargementResponse> getByAuditeur(Long auditeurId) {
        return telechargementRepository.findByAuditeurId(auditeurId).stream()
                .map(TelechargementResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<TelechargementResponse> getByChanson(Long chansonId) {
        return telechargementRepository.findByChansonId(chansonId).stream()
                .map(TelechargementResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional
    public void supprimer(Long id) {
        if (!telechargementRepository.existsById(id)) {
            throw new ResourceNotFoundException("Téléchargement non trouvé id: " + id);
        }
        telechargementRepository.deleteById(id);
    }
}
