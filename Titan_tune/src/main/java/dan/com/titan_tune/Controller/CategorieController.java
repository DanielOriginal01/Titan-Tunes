package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.entities.Categorie;
import dan.com.titan_tune.repository.CategorieRepository;
import lombok.RequiredArgsConstructor;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/categories", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class CategorieController {

    private final CategorieRepository categorieRepository;

    // Tout le monde peut voir les catégories (public ou authentifié selon vos règles globales)
    @GetMapping
    public ResponseEntity<ApiResponse<List<Categorie>>> getAllCategories() {
        List<Categorie> categories = categorieRepository.findAll();
        return ResponseEntity.ok(ApiResponse.success("Liste des catégories récupérée avec succès.", categories));
    }

    // Tout le monde peut consulter une catégorie spécifique
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Categorie>> getCategorieById(@PathVariable Long id) {
        return categorieRepository.findById(id)
                .map(categorie -> ResponseEntity.ok(ApiResponse.success("Catégorie trouvée.", categorie)))
                .orElse(ResponseEntity.status(404).body(ApiResponse.error("Catégorie non trouvée.", HttpStatus.NOT_FOUND)));
    }

    // Créer une catégorie 
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Categorie>> createCategorie(@RequestBody Categorie categorie) {
        Categorie savedCategorie = categorieRepository.save(categorie);
        return ResponseEntity.status(201).body(ApiResponse.success("Catégorie créée avec succès.", savedCategorie, HttpStatus.CREATED));
    }

    // Supprimer une catégorie 
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteCategorie(@PathVariable Long id) {
        if (!categorieRepository.existsById(id)) {
            return ResponseEntity.status(404).body(ApiResponse.error("Catégorie non trouvée.", HttpStatus.NOT_FOUND));
        }
        
        categorieRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Catégorie supprimée avec succès.", null));
    }
}