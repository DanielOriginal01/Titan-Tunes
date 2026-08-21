package dan.com.titan_tune.dtos.dtoresponse;

public record TokenRefreshResponse(
    String accessToken,
    String refreshToken,
    String tokenType
) {
    public TokenRefreshResponse(String accessToken, String refreshToken) {
        this(accessToken, refreshToken, "Bearer");
    }
}
