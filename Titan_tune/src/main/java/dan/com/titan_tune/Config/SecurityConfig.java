package dan.com.titan_tune.config;

import dan.com.titan_tune.security.JwtAuthenticationFilter;
import dan.com.titan_tune.security.UserDetailsServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final UserDetailsServiceImpl userDetailsService;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        var authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth

                // ── Routes entièrement publiques ──────────────────────────────────────────
                .requestMatchers("/api/v1/auth/**").permitAll()
                .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()

                // Routes publiques en lecture GET & HEAD (découverte, accueil, streaming et audio direct)
                .requestMatchers(HttpMethod.GET, "/api/v1/chansons/**").permitAll()
                .requestMatchers(HttpMethod.HEAD, "/api/v1/chansons/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/albums/**").permitAll()
                .requestMatchers(HttpMethod.HEAD, "/api/v1/albums/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/artistes/**").permitAll()
                .requestMatchers(HttpMethod.HEAD, "/api/v1/artistes/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/bannieres/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/evenements/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/categories/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/labels/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/abonnements/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/media/**").permitAll()
                .requestMatchers(HttpMethod.HEAD, "/api/v1/media/**").permitAll()

                // ── Routes réservées ADMIN ──────────────────────────────────────────────
                .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/v1/auth/admin/create").hasRole("ADMIN")

                // ── Routes réservées ARTISTE (ou ADMIN) ──────────────────────────────────
                .requestMatchers(HttpMethod.POST, "/api/v1/artistes/**").hasAnyRole("ARTISTE", "ADMIN")
                .requestMatchers(HttpMethod.PUT,  "/api/v1/artistes/**").hasAnyRole("ARTISTE", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/v1/albums/**").hasAnyRole("ARTISTE", "ADMIN")
                .requestMatchers(HttpMethod.PUT,  "/api/v1/albums/**").hasAnyRole("ARTISTE", "ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/v1/albums/**").hasAnyRole("ARTISTE", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/v1/chansons/publier").hasAnyRole("ARTISTE", "ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/v1/chansons/**").hasAnyRole("ARTISTE", "ADMIN")

                // ── Tout le reste nécessite d'être connecté ───────────────────────────────
                .anyRequest().authenticated()
            );

        http.authenticationProvider(authenticationProvider());
        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        var configuration = new CorsConfiguration();
        
        configuration.setAllowedOriginPatterns(List.of(
                "http://localhost:*",
                "http://127.0.0.1:*",
                "http://10.0.2.2:*"
        ));
        
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setExposedHeaders(List.of("Authorization", "Link", "X-Total-Count", "Content-Range", "Accept-Ranges"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        var source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
