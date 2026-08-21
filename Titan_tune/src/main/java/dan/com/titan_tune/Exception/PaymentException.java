package dan.com.titan_tune.exception;

/**
 * Exception métier pour erreurs de paiement Mobile Money.
 */
public class PaymentException extends RuntimeException {

    private final Long auditeurId;
    private final Reason reason;

    public enum Reason {
        INSUFFICIENT_FUNDS, NETWORK_ERROR, TIMEOUT, OTHER
    }

    public PaymentException(Long auditeurId, Reason reason, String message) {
        super(message);
        this.auditeurId = auditeurId;
        this.reason = reason;
    }

    public Long getAuditeurId() {
        return auditeurId;
    }

    public Reason getReason() {
        return reason;
    }
}
