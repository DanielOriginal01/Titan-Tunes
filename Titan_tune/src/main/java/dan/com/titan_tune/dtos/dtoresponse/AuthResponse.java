package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.enums.Role;

public record AuthResponse(
    String token,
    String refreshToken,
    String type,
    Long id,
    String username,
    String email,
    Role role,
    String photoProfil
) {
    public AuthResponse(String token, String refreshToken, String type, Long id, String username, String email, Role role) {
        this(token, refreshToken, type, id, username, email, role, null);
    }

    public AuthResponse(String token, String refreshToken, Long id, String username, String email, Role role) {
        this(token, refreshToken, "Bearer", id, username, email, role, null);
    }

    public AuthResponse(String token, String refreshToken, Long id, String username, String email, Role role, String photoProfil) {
        this(token, refreshToken, "Bearer", id, username, email, role, photoProfil);
    }

    public AuthResponse(String token, Long id, String username, String email, Role role) {
        this(token, null, "Bearer", id, username, email, role, null);
    }

    public AuthResponse(String token, Long id, String username, String email, Role role, String photoProfil) {
        this(token, null, "Bearer", id, username, email, role, photoProfil);
    }
}