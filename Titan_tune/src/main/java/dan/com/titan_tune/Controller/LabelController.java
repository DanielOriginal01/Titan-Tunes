package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.entities.Label;
import dan.com.titan_tune.repository.LabelRepository;
import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/labels", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class LabelController {

    private final LabelRepository labelRepository;

    // Lister tous les labels -> Public ou connecté
    @GetMapping
    public ResponseEntity<ApiResponse<List<Label>>> getAllLabels() {
        List<Label> labels = labelRepository.findAll();
        return ResponseEntity.ok(ApiResponse.success("Liste des labels récupérée avec succès.", labels));
    }

    // Récupérer un label par son ID -> Public ou connecté
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Label>> getLabelById(@PathVariable Long id) {
        return labelRepository.findById(id)
                .map(label -> ResponseEntity.ok(ApiResponse.success("Label trouvé.", label)))
                .orElse(ResponseEntity.status(404).body(ApiResponse.error("Label non trouvé.", HttpStatus.NOT_FOUND)));
    }

    // Créer un label -> Réservé aux Administrateurs
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Label>> createLabel(@RequestBody Label label) {
        Label savedLabel = labelRepository.save(label);
        return ResponseEntity.status(201).body(ApiResponse.success("Label créé avec succès.", savedLabel, HttpStatus.CREATED));
    }

    // Supprimer un label -> Réservé aux Administrateurs
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteLabel(@PathVariable Long id) {
        if (!labelRepository.existsById(id)) {
            return ResponseEntity.status(404).body(ApiResponse.error("Label non trouvé.", HttpStatus.NOT_FOUND));
        }
        
        labelRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Label supprimé avec succès.", null));
    }
}