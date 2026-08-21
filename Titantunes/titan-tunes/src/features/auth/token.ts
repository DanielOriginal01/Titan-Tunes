import type { AuthUser } from "./types";

const TOKEN_STORAGE_KEY = "titan_token";

/**
 * Parse un JWT et extrait les informations utilisateur.
 * Gère tous les formats de rôle retournés par Spring Boot :
 *   - string :  { role: "ROLE_ADMIN" }
 *   - tableau de strings : { roles: ["ROLE_ADMIN"] }
 *   - tableau d'objets Spring Security : { authorities: [{ authority: "ROLE_ADMIN" }] }
 */
export function parseJwtToken(token: string): AuthUser | null {
  try {
    // Padding base64 optionnel
    const base64 = token.split(".")[1].replace(/-/g, "+").replace(/_/g, "/");
    const payload = JSON.parse(atob(base64));

    // Extraction du rôle selon tous les formats possibles
    let role: string | undefined;

    if (typeof payload.role === "string") {
      role = payload.role;
    } else if (Array.isArray(payload.roles) && payload.roles.length > 0) {
      const first = payload.roles[0];
      role = typeof first === "string" ? first : (first as { authority?: string })?.authority;
    } else if (Array.isArray(payload.authorities) && payload.authorities.length > 0) {
      const first = payload.authorities[0];
      role = typeof first === "string" ? first : (first as { authority?: string })?.authority;
    } else if (typeof payload.scope === "string") {
      // JWT OAuth2 : scope contient les rôles séparés par espace
      role = payload.scope.split(" ").find((s: string) => s.startsWith("ROLE_"));
    }

    return {
      id:       Number(payload.sub ?? payload.userId ?? payload.id ?? 0),
      username: payload.username ?? payload.preferred_username ?? payload.sub ?? "",
      email:    payload.email ?? "",
      role,
    };
  } catch {
    return null;
  }
}

export function getStoredToken(): string | null {
  if (typeof window === "undefined") return null;
  return window.localStorage.getItem(TOKEN_STORAGE_KEY);
}

export function setStoredToken(token: string) {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(TOKEN_STORAGE_KEY, token);
}

export function clearStoredToken() {
  if (typeof window === "undefined") return;
  window.localStorage.removeItem(TOKEN_STORAGE_KEY);
}

// ─── Cookies (lus par le middleware Edge) ─────────────────────────────────────

export const ROLE_COOKIE_KEY  = "titan_role";
// On utilise un nom différent pour le cookie du token afin d'éviter
// tout conflit avec la clé localStorage "titan_token"
export const TOKEN_COOKIE_KEY = "titan_auth";

export function setRoleCookie(name: string, value: string, days = 7) {
  if (typeof window === "undefined") return;
  const maxAge = days * 24 * 60 * 60;
  document.cookie = `${name}=${encodeURIComponent(value)}; Path=/; Max-Age=${maxAge}; SameSite=Lax`;
}

export function clearCookie(name: string) {
  if (typeof window === "undefined") return;
  document.cookie = `${name}=; Path=/; Max-Age=0; SameSite=Lax`;
}

/** Persiste le rôle dans le cookie lu par le middleware */
export function persistRoleCookie(role: string) {
  setRoleCookie(ROLE_COOKIE_KEY, role);
}

/**
 * Persiste le JWT dans un cookie lu par le middleware comme fallback.
 * Utilise la clé "titan_auth" (distincte de la clé localStorage "titan_token").
 */
export function persistTokenCookie(token: string, days = 7) {
  setRoleCookie(TOKEN_COOKIE_KEY, token, days);
}

/** Efface tous les cookies d'auth au logout */
export function clearRoleCookie() {
  clearCookie(ROLE_COOKIE_KEY);
  clearCookie(TOKEN_COOKIE_KEY);
}

export { TOKEN_STORAGE_KEY };
