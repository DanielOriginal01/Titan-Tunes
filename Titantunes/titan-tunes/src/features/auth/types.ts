export type UserRole = "ROLE_ARTISTE" | "ROLE_AUDITEUR" | "ROLE_ADMIN";

export interface LoginPayload {
  /** Email ou nom d'utilisateur — le backend accepte les deux */
  emailOuUsername: string;
  password: string;
}

export interface RegisterPayload {
  username: string;
  email: string;
  password: string;
  telephone: string;
  role: UserRole;
  /** Optionnel — artistes seulement. Défaut = username si absent. */
  artistName?: string | null;
}

export interface AuthUser {
  id: number;
  username: string;
  email: string;
  role?: string;
}

/** Réponse au login : contient un JWT */
export interface AuthResponse {
  token: string;
  refreshToken?: string;
  user: AuthUser;
}

/**
 * Réponse à l'inscription : pas de JWT.
 * Le backend renvoie un message de confirmation uniquement.
 */
export interface RegisterResponse {
  success: boolean;
  message: string;
}
