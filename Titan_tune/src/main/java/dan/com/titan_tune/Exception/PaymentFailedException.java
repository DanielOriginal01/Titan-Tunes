package dan.com.titan_tune.exception;

/**
 * Exception levée lorsqu'un paiement ne peut pas être traité.
 */
public class PaymentFailedException extends RuntimeException {
    public PaymentFailedException(String message) {
        super(message);
    }
}
