package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.entities.Chansons;
import dan.com.titan_tune.repository.ChansonRepository;
import dan.com.titan_tune.service.CatalogueService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class CatalogueServiceImpl implements CatalogueService {

    private final ChansonRepository chansonRepository;

    @Override
    public Chansons publishChanson(Chansons chanson) {
        // Ensure relationships (album, categorie, artiste) must already exist; save the chanson
        return chansonRepository.save(chanson);
    }
}
