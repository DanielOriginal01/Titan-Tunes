
package com.titantunes.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();

        // Origines autorisées (Flutter Web dev + production)
        config.addAllowedOriginPattern("http://localhost:*");
        config.addAllowedOriginPattern("https://titantunes.tg");
        config.addAllowedOriginPattern("https://*.titantunes.tg");

        // Méthodes HTTP autorisées
        config.addAllowedMethod("GET");
        config.addAllowedMethod("POST");
        config.addAllowedMethod("PUT");
        config.addAllowedMethod("DELETE");
        config.addAllowedMethod("OPTIONS");

        // Headers autorisés
        config.addAllowedHeader("*");

        // Expose le header Authorization dans les réponses
        config.addExposedHeader("Authorization");

        // Autorise l'envoi des cookies / credentials
        config.setAllowCredentials(true);

        // Cache le preflight pendant 1h
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", config);

        return new CorsFilter(source);
    }
}
```

### Option 2 — Annotation sur le Controller

Si vous ne voulez activer CORS que sur certains contrôleurs :

```java
@RestController
@RequestMapping("/api/v1")
@CrossOrigin(origins = {"http://localhost:*"}, allowCredentials = "true")
public class ChansonController { ... }
```

### Option 3 — application.properties

```properties
# CORS global (Spring Boot 3.x)
spring.mvc.cors.allowed-origins=http://localhost:3000,http://localhost:8888
spring.mvc.cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
spring.mvc.cors.allowed-headers=*
spring.mvc.cors.allow-credentials=true
```

## Vérification

Après redémarrage du backend, testez avec :
```powershell
curl -X OPTIONS http://localhost:8080/api/v1/chansons `
  -H "Origin: http://localhost:8888" `
  -H "Access-Control-Request-Method: GET" `
  -v
```

La réponse doit contenir :
```
< Access-Control-Allow-Origin: http://localhost:8888
< Access-Control-Allow-Methods: GET,POST,PUT,DELETE,OPTIONS
```

## En attendant (développement local)

Lancer l'app avec le script fourni :
```powershell
.\run_web_dev.ps1
```

Ou directement :
```powershell
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=/tmp/chrome_dev_titan"
```
