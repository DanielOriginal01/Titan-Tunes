package dan.com.titan_tune.service;

import dan.com.titan_tune.dtos.dtoresponse.SouscrireEtPayerResponse;
import dan.com.titan_tune.dtos.dtorequest.SouscrireEtPayerRequest;
import dan.com.titan_tune.dtos.dtoresponse.OffreAbonnementResponse;
import dan.com.titan_tune.entities.Abonnement;
import dan.com.titan_tune.entities.Auditeur;

import java.util.List;

public interface AbonnementService {

    /** Crée un abonnement pour un auditeur (sans paiement — utilisé en interne). */
    Abonnement subscribe(Auditeur auditeur, String offerCode, String mobileMoneyRef);

    /** Vérifie si un auditeur a un abonnement actif. */
    boolean isActive(Auditeur auditeur);

    /** Retourne les offres disponibles avec tarifs et avantages. */
    List<OffreAbonnementResponse> getOffresDisponibles();

    /**
     * Flux unifié : crée l'abonnement ET effectue le paiement mobile money
     * en une seule transaction atomique.
     */
    SouscrireEtPayerResponse souscrireEtPayer(SouscrireEtPayerRequest request);
}
