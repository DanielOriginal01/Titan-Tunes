package dan.com.titan_tune.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Standard API payload used for both successful and unsuccessful API outcomes.
 * The payload is intentionally simple so all controllers can return the same envelope.
 */
@Data
@NoArgsConstructor
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    private boolean success;
    private String message;
    private T data;
    private List<String> errors;
    private LocalDateTime timestamp;
    private int status;

    public ApiResponse(boolean success, String message, T data, List<String> errors, LocalDateTime timestamp) {
        this(success, message, data, errors, timestamp, HttpStatus.OK.value());
    }

    public ApiResponse(boolean success, String message, T data, List<String> errors, LocalDateTime timestamp, int status) {
        this.success = success;
        this.message = message;
        this.data = data;
        this.errors = errors;
        this.timestamp = timestamp;
        this.status = status;
    }

    public ApiResponse(boolean success, String message, T data) {
        this(success, message, data, null, LocalDateTime.now(), HttpStatus.OK.value());
    }

    public static <T> ApiResponse<T> success(String message, T data) {
        return success(message, data, HttpStatus.OK);
    }

    public static <T> ApiResponse<T> success(String message, T data, HttpStatus status) {
        return new ApiResponse<>(true, message, data, null, LocalDateTime.now(), status.value());
    }

    public static <T> ApiResponse<T> error(String message) {
        return error(message, HttpStatus.BAD_REQUEST);
    }

    public static <T> ApiResponse<T> error(String message, HttpStatus status) {
        return new ApiResponse<>(false, message, null, null, LocalDateTime.now(), status.value());
    }

    public static <T> ApiResponse<T> error(String message, T data) {
        return new ApiResponse<>(false, message, data, null, LocalDateTime.now(), HttpStatus.BAD_REQUEST.value());
    }

    public static <T> ApiResponse<T> error(String message, List<String> errors) {
        return error(message, errors, HttpStatus.BAD_REQUEST);
    }

    public static <T> ApiResponse<T> error(String message, List<String> errors, HttpStatus status) {
        return new ApiResponse<>(false, message, null, errors, LocalDateTime.now(), status.value());
    }
}

