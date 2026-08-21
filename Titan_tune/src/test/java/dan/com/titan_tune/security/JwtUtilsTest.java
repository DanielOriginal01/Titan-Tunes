package dan.com.titan_tune.security;

import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.User;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertFalse;

class JwtUtilsTest {

    @Test
    void generateJwtTokenShouldHonorConfiguredExpiration() throws InterruptedException {
        JwtUtils jwtUtils = new JwtUtils();
        ReflectionTestUtils.setField(jwtUtils, "jwtSecretValue", "change-me-please-very-long-secret-key-for-titan-tune");
        ReflectionTestUtils.setField(jwtUtils, "jwtExpirationMs", 1);

        var authentication = new UsernamePasswordAuthenticationToken(
                new User("auditeur@test.com", "password", List.of()),
                null
        );

        String token = jwtUtils.generateJwtToken(authentication);
        Thread.sleep(20);

        assertFalse(jwtUtils.validateJwtToken(token));
    }
}
