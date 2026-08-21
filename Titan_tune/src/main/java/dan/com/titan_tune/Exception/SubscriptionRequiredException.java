package dan.com.titan_tune.exception;

public class SubscriptionRequiredException extends RuntimeException {
    public SubscriptionRequiredException(String message) {
        super(message);
    }
}
