package dan.com.titan_tune.exception;

/**
 * Exception métier utilisée lorsqu'un upload ou un accès MinIO échoue.
 */
public class MinioUploadException extends RuntimeException {
    public MinioUploadException(String message) {
        super(message);
    }
}
