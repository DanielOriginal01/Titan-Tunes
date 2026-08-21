package dan.com.titan_tune.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Configuration OpenAPI / Swagger UI pour Titan Tunes.
 *
 * ─ Déclare le schéma de sécurité JWT Bearer (cadenas 🔒 sur chaque endpoint)
 * ─ Pour utiliser Swagger UI :
 *   1. Appelez POST /api/v1/auth/login pour obtenir votre token JWT
 *   2. Cliquez sur le bouton "Authorize" en haut de Swagger UI
 *   3. Saisissez : Bearer <votre_token>
 *   4. Tous les endpoints protégés seront déverrouillés
 */
@Configuration
public class OpenApiConfig {

    private static final String SECURITY_SCHEME_NAME = "bearerAuth";

    @Bean
    public OpenAPI titanTunesOpenAPI() {
        return new OpenAPI()
                // ── Informations générales ───────────────────────────────────
                .info(new Info()
                        .title("Titan Tunes API")
                        .version("1.0.0")
                        .description("""
                                ## API REST — Plateforme de streaming musical togolaise et africaine

                                ### Authentification
                                Cette API utilise des tokens **JWT Bearer**.

                                1. Appelez `POST /api/v1/auth/login` avec vos identifiants
                                2. Copiez le champ `token` de la réponse
                                3. Cliquez sur le bouton **Authorize ** ci-dessus
                                4. Saisissez : `Bearer <votre_token>`

                                ### Rôles disponibles
                                | Rôle | Accès |
                                |------|-------|
                                | `ROLE_ADMIN` | Gestion complète de la plateforme |
                                | `ROLE_ARTISTE` | Publication musicale, bannières, dashboard |
                                | `ROLE_AUDITEUR` | Écoute, playlists, favoris, abonnements |

                                ### Comptes de test
                                - **Admin** : `admin@titan.com` / `titansupadmin@2005`
                                - **Artiste** : `kofi.mensah@music.tg` / `Artiste@2026!`
                                - **Auditeur** : `amina.koffi@gmail.com` / `Auditeur@2026!`
                                """)
                        .contact(new Contact()
                                .name("Équipe Titan Tunes")
                                .email("admin@titan.com"))
                        .license(new License()
                                .name("Propriétaire — Titan Holding")))

                // ── Serveurs ─────────────────────────────────────────────────
                .servers(List.of(
                        new Server()
                                .url("http://localhost:8080")
                                .description("Serveur de développement local"),
                        new Server()
                                .url("https://api.titan-tunes.com")
                                .description("Serveur de production")))

                // ── Schéma de sécurité JWT ───────────────────────────────────
                // Déclare le composant bearerAuth
                .components(new Components()
                        .addSecuritySchemes(SECURITY_SCHEME_NAME,
                                new SecurityScheme()
                                        .name(SECURITY_SCHEME_NAME)
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")
                                        .in(SecurityScheme.In.HEADER)
                                        .description("Token JWT obtenu via POST /api/v1/auth/login")))

                // ── Applique le cadenas sur TOUS les endpoints ───────────────
                // Les endpoints publics acceptent les requêtes sans token
                // mais le cadenas s'affiche quand même pour permettre les tests
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME_NAME));
    }
}
