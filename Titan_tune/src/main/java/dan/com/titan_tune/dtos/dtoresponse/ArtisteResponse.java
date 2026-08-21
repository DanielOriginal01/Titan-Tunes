package dan.com.titan_tune.dtos.dtoresponse;

import dan.com.titan_tune.entities.Artiste;

public record ArtisteResponse(
    Long id,
    String username,
    String email,
    String artistName,
    String bio,
    String photoProfil,
    String photoCouverture,
    Boolean verifie
) {
    public ArtisteResponse(Long id, String username, String email, String artistName, String bio, String photoCouverture, Boolean verifie) {
        this(id, username, email, artistName, bio, null, photoCouverture, verifie);
    }

    public static ArtisteResponse fromEntity(Artiste a) {
        return new ArtisteResponse(
            a.getId(),
            a.getUsername(),
            a.getEmail(),
            a.getArtistName(),
            a.getBio(),
            a.getPhotoProfil(),
            a.getPhotoCouverture(),
            a.getVerifie()
        );
    }
}