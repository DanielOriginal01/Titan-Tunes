package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtorequest.EmailRequest;
import dan.com.titan_tune.dtos.dtorequest.PasswordResetRequest;
import dan.com.titan_tune.dtos.dtoresponse.AccountRecoveryResponse;

public interface EmailVerificationService {
    AccountRecoveryResponse requestEmailVerification(String email);
    AccountRecoveryResponse verifyEmail(String token);
    AccountRecoveryResponse requestPasswordReset(EmailRequest request);
    AccountRecoveryResponse resetPassword(PasswordResetRequest request);
}
