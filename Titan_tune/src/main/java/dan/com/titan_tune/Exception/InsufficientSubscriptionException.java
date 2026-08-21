package dan.com.titan_tune.exception;

/**
 * Exception levée lorsqu'un auditeur n'a pas l'abonnement nécessaire.
 */
public class InsufficientSubscriptionException extends RuntimeException {
    public InsufficientSubscriptionException(String message) {
        super(message);
    }
}
