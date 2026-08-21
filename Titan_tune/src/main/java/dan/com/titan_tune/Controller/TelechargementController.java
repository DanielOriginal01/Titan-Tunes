package dan.com.titan_tune.controller;

import dan.com.titan_tune.dto.ApiResponse;
import dan.com.titan_tune.dtos.dtorequest.TelechargementRequest;
import dan.com.titan_tune.dtos.dtoresponse.TelechargementResponse;
import dan.com.titan_tune.repository.TelechargementRepository;
import dan.com.titan_tune.service.TelechargementService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "/api/v1/telechargements", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class TelechargementController {

    private final TelechargementService    telechargementService;
    private final TelechargementRepository telechargementRepository;

    /** Liste tous les téléchargements — admin uniquement. */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<TelechargementResponse>>> getAll() {
        var list = telechargementRepository.findAll().stream()
                .map(TelechargementResponse::fromEntity).toList();
        return ResponseEntity.ok(ApiResponse.success("Liste des téléchargements récupérée.", list));
    }
    /** Téléchargements d'un auditeur. */
    @GetMapping("/auditeur/{auditeurId}")
    @PreAuthorize("hasAnyRole('AUDITEUR', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<TelechargementResponse>>> getByAuditeur(
            @PathVariable Long auditeurId) {
        return ResponseEntity.ok(ApiResponse.success(
                "Téléchargements de l'auditeur récupérés.",
                telechargementService.getByAuditeur(auditeurId)));
    }

    /** Téléchargements d'une chanson — admin uniquement. */
    @GetMapping("/chanson/{chansonId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<TelechargementResponse>>> getByChanson(
            @PathVariable Long chansonId) {
        return ResponseEntity.ok(ApiResponse.success(
                "Téléchargements de la chanson récupérés.",
                telechargementService.getByChanson(chansonId)));
    }

    /** Enregistre un téléchargement — auditeur authentifié. */
    @PostMapping
    @PreAuthorize("hasRole('AUDITEUR')")
    public ResponseEntity<ApiResponse<TelechargementResponse>> enregistrer(
            @Valid @RequestBody TelechargementRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(
                "Téléchargement enregistré.", telechargementService.enregistrerTelechargement(request)));
    }

    /** Supprime un enregistrement de téléchargement. */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('AUDITEUR', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> supprimer(@PathVariable Long id) {
        telechargementService.supprimer(id);
        return ResponseEntity.ok(ApiResponse.success("Téléchargement supprimé.", null));
    }
}
