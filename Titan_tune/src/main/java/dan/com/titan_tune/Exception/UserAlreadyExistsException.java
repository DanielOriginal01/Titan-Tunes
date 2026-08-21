package dan.com.titan_tune.exception;

/**
 * Exception levée lorsqu'un utilisateur tente de s'enregistrer avec un email déjà utilisé.
 */
public class UserAlreadyExistsException extends RuntimeException {
    public UserAlreadyExistsException(String message) {
        super(message);
    }
}
