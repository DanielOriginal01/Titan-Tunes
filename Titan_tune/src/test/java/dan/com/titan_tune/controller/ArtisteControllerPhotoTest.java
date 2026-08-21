package dan.com.titan_tune.controller;

import dan.com.titan_tune.entities.Artiste;
import dan.com.titan_tune.enums.Role;
import dan.com.titan_tune.enums.Statut;
import dan.com.titan_tune.repository.ArtisteRepository;
import dan.com.titan_tune.repository.UtilisateurRepository;
import dan.com.titan_tune.security.SecurityUtils;
import dan.com.titan_tune.service.ArtisteDashboardService;
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
class ArtisteControllerPhotoTest {

    @Mock
    private ArtisteRepository artisteRepository;

    @Mock
    private UtilisateurRepository utilisateurRepository;

    @Mock
    private ArtisteDashboardService dashboardService;

    @Mock
    private MinioService minioService;

    private SecurityUtils securityUtils;
    private ArtisteController artisteController;
    private Artiste artiste;

    @BeforeEach
    void setUp() {
        securityUtils = new SecurityUtils(utilisateurRepository);
        artisteController = new ArtisteController(artisteRepository, minioService, dashboardService, securityUtils);

        artiste = Artiste.builder()
                .id(20L)
                .username("artiste_test")
                .email("artiste@test.com")
                .role(Role.ROLE_ARTISTE)
                .status(Statut.ACTIF)
                .artistName("DJ Test")
                .photoProfil("old_avatar.png")
                .photoCouverture("old_cover.jpg")
                .verifie(true)
                .build();

        var auth = new UsernamePasswordAuthenticationToken(
                new User("artiste@test.com", "pass", List.of(new SimpleGrantedAuthority("ROLE_ARTISTE"))),
                null,
                List.of(new SimpleGrantedAuthority("ROLE_ARTISTE"))
        );
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    @DisplayName("Upload avatar artiste : remplace l'ancien avatar et sauvegarde")
    void uploadPhotoProfil_Success() {
        when(utilisateurRepository.findByEmail("artiste@test.com")).thenReturn(Optional.of(artiste));
        when(artisteRepository.findById(20L)).thenReturn(Optional.of(artiste));
        when(minioService.uploadFile(any(), eq("photos-profils"))).thenReturn("new_avatar_uuid.png");
        when(artisteRepository.save(any(Artiste.class))).thenAnswer(inv -> inv.getArgument(0));

        MockMultipartFile file = new MockMultipartFile(
                "photo", "avatar.png", "image/png", "avatar_bytes".getBytes()
        );

        var response = artisteController.uploadPhotoProfil(20L, file);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getData().photoProfil()).isEqualTo("new_avatar_uuid.png");

        verify(minioService).deleteFile("old_avatar.png", "photos-profils");
        verify(minioService).uploadFile(file, "photos-profils");
        verify(artisteRepository).save(artiste);
    }

    @Test
    @DisplayName("Récupération de l'URL de l'avatar artiste")
    void getPhotoProfilUrl_Success() {
        when(artisteRepository.findById(20L)).thenReturn(Optional.of(artiste));
        when(minioService.getPresignedUrl("old_avatar.png", "photos-profils")).thenReturn("http://localhost:9000/photos-profils/old_avatar.png?token=xyz");

        var response = artisteController.getPhotoProfilUrl(20L);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getData()).contains("http://localhost:9000");
    }

    @Test
    @DisplayName("Suppression de l'avatar artiste")
    void deletePhotoProfil_Success() {
        when(utilisateurRepository.findByEmail("artiste@test.com")).thenReturn(Optional.of(artiste));
        when(artisteRepository.findById(20L)).thenReturn(Optional.of(artiste));

        var response = artisteController.deletePhotoProfil(20L);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getData().photoProfil()).isNull();

        verify(minioService).deleteFile("old_avatar.png", "photos-profils");
        verify(artisteRepository).save(artiste);
    }
}
