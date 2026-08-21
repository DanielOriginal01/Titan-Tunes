package dan.com.titan_tune.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * Catalogue des offres d'abonnement Titan Tunes.
 * Chaque offre définit : code, label, prix en FCFA, durée en jours,
 * description marketing et avantages inclus.
 */
@Getter
@RequiredArgsConstructor
public enum OffreAbonnement {

    DAILY(
        "DAILY",
        "Offre Journalière",
        100.0,
        1,
        "Accès illimité pendant 24h — idéal pour tester la plateforme",
        new String[]{
            "Écoute illimitée 24h",
            "Sans publicité",
            "Streaming haute qualité"
        }
    ),

    WEEKLY(
        "WEEKLY",
        "Offre Hebdomadaire",
        500.0,
        7,
        "7 jours d'accès complet — flexibilité maximale",
        new String[]{
            "Écoute illimitée 7 jours",
            "Sans publicité",
            "Téléchargement hors ligne (10 chansons)",
            "Streaming haute qualité"
        }
    ),

    MONTHLY(
        "MONTHLY",
        "Offre Mensuelle",
        2000.0,
        30,
        "Le meilleur rapport qualité-prix — 30 jours d'expérience complète",
        new String[]{
            "Écoute illimitée 30 jours",
            "Sans publicité",
            "Téléchargement hors ligne (50 chansons)",
            "Streaming haute qualité",
            "Accès aux avant-premières exclusives"
        }
    ),

    QUARTERLY(
        "QUARTERLY",
        "Offre Trimestrielle",
        5000.0,
        90,
        "3 mois au prix de 2,5 — économisez 1000 FCFA",
        new String[]{
            "Écoute illimitée 90 jours",
            "Sans publicité",
            "Téléchargement hors ligne (100 chansons)",
            "Streaming haute qualité",
            "Accès aux avant-premières exclusives",
            "Contenu exclusif artistes"
        }
    ),

    YEARLY(
        "YEARLY",
        "Offre Annuelle",
        18000.0,
        365,
        "12 mois au prix de 9 — la meilleure économie (économisez 6000 FCFA)",
        new String[]{
            "Écoute illimitée 365 jours",
            "Sans publicité",
            "Téléchargement hors ligne illimité",
            "Streaming haute qualité",
            "Accès aux avant-premières exclusives",
            "Contenu exclusif artistes",
            "Badge abonné annuel",
            "Support prioritaire"
        }
    );

    private final String code;
    private final String label;
    private final double prixFcfa;
    private final int dureeDays;
    private final String description;
    private final String[] avantages;

    /** Résout un code d'offre (insensible à la casse) vers l'enum. */
    public static OffreAbonnement fromCode(String code) {
        if (code == null || code.isBlank()) {
            throw new IllegalArgumentException("Le code d'offre ne peut pas être vide.");
        }
        for (OffreAbonnement offre : values()) {
            if (offre.code.equalsIgnoreCase(code.trim())) {
                return offre;
            }
        }
        throw new IllegalArgumentException(
            "Code d'offre invalide : '" + code + "'. "
            + "Valeurs acceptées : DAILY, WEEKLY, MONTHLY, QUARTERLY, YEARLY."
        );
    }
}
