package dan.com.titan_tune.controller;

import dan.com.titan_tune.entities.Auditeur;
import dan.com.titan_tune.enums.Role;
import dan.com.titan_tune.enums.Statut;
import dan.com.titan_tune.repository.AuditeurRepository;
import dan.com.titan_tune.repository.UtilisateurRepository;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.MinioService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.User;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuditeurControllerPhotoTest {

    @Mock
    private AuditeurRepository auditeurRepository;

    @Mock
    private UtilisateurRepository utilisateurRepository;

    @Mock
    private MinioService minioService;

    private SecurityUtils securityUtils;
    private AuditeurController auditeurController;
    private Auditeur auditeur;

    @BeforeEach
    void setUp() {
        securityUtils = new SecurityUtils(utilisateurRepository);
        auditeurController = new AuditeurController(auditeurRepository, minioService, securityUtils);

        auditeur = Auditeur.builder()
                .id(10L)
                .username("auditeur_test")
                .email("auditeur@test.com")
                .role(Role.ROLE_AUDITEUR)
                .status(Statut.ACTIF)
                .photoProfil("old_photo.jpg")
                .build();

        var auth = new UsernamePasswordAuthenticationToken(
                new User("auditeur@test.com", "pass", List.of(new SimpleGrantedAuthority("ROLE_AUDITEUR"))),
                null,
                List.of(new SimpleGrantedAuthority("ROLE_AUDITEUR"))
        );
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    @DisplayName("Upload photo de profil : remplace l'ancienne et sauvegarde la nouvelle")
    void uploadPhoto_Success() {
        when(utilisateurRepository.findByEmail("auditeur@test.com")).thenReturn(Optional.of(auditeur));
        when(auditeurRepository.findById(10L)).thenReturn(Optional.of(auditeur));
        when(minioService.uploadFile(any(), eq("photos-profils"))).thenReturn("new_photo_uuid.png");
        when(auditeurRepository.save(any(Auditeur.class))).thenAnswer(inv -> inv.getArgument(0));

        MockMultipartFile file = new MockMultipartFile(
                "photo", "avatar.png", "image/png", "image_content".getBytes()
        );

        var response = auditeurController.uploadPhoto(10L, file);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getData().photoProfil()).isEqualTo("new_photo_uuid.png");

        verify(minioService).deleteFile("old_photo.jpg", "photos-profils");
        verify(minioService).uploadFile(file, "photos-profils");
        verify(auditeurRepository).save(auditeur);
    }

    @Test
    @DisplayName("Récupération de l'URL présignée de la photo de profil")
    void getPhotoUrl_Success() {
        when(auditeurRepository.findById(10L)).thenReturn(Optional.of(auditeur));
        when(minioService.getPresignedUrl("old_photo.jpg", "photos-profils")).thenReturn("http://localhost:9000/photos-profils/old_photo.jpg?token=123");

        var response = auditeurController.getPhotoUrl(10L);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getData()).contains("http://localhost:9000");
    }

    @Test
    @DisplayName("Récupération de l'URL quand aucune photo n'est enregistrée")
    void getPhotoUrl_NullWhenNoPhoto() {
        auditeur.setPhotoProfil(null);
        when(auditeurRepository.findById(10L)).thenReturn(Optional.of(auditeur));

        var response = auditeurController.getPhotoUrl(10L);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getData()).isNull();
    }

    @Test
    @DisplayName("Suppression de la photo de profil")
    void deletePhoto_Success() {
        when(utilisateurRepository.findByEmail("auditeur@test.com")).thenReturn(Optional.of(auditeur));
        when(auditeurRepository.findById(10L)).thenReturn(Optional.of(auditeur));

        var response = auditeurController.deletePhoto(10L);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getData().photoProfil()).isNull();

        verify(minioService).deleteFile("old_photo.jpg", "photos-profils");
        verify(auditeurRepository).save(auditeur);
    }
}
