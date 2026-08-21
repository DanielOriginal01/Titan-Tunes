package dan.com.titan_tune.exception;

public class TrackNotFoundException extends RuntimeException {
    public TrackNotFoundException(String message) {
        super(message);
    }
}
