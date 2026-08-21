import { apiClient } from "@/lib/http/client";
import type { LoginPayload, RegisterPayload, AuthResponse, RegisterResponse } from "./types";
import type { AuthLoginData } from "@/types/api";
import { persistTokenCookie } from "./token";

const TOKEN_KEY = "titan_token";
const USER_KEY  = "titan_user";

// ─── Session helpers ──────────────────────────────────────────────────────────

export function saveAuthSession(response: AuthResponse) {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(TOKEN_KEY, response.token);
  window.localStorage.setItem(USER_KEY, JSON.stringify(response.user));
}

export function clearAuthSession() {
  if (typeof window === "undefined") return;
  window.localStorage.removeItem(TOKEN_KEY);
  window.localStorage.removeItem(USER_KEY);
}

export function getStoredToken(): string | null {
  if (typeof window === "undefined") return null;
  return window.localStorage.getItem(TOKEN_KEY);
}

// ─── Normalisation de la réponse backend ─────────────────────────────────────
// Le backend renvoie { token, type, id, username, email, role } à plat.
// On le normalise en { token, user: { id, username, email, role } }.

function normalizeLoginResponse(raw: AuthLoginData): AuthResponse {
  return {
    token: raw.token,
    user: {
      id:       raw.id,
      username: raw.username,
      email:    raw.email,
      role:     raw.role,
    },
  };
}

// ─── Auth endpoints ───────────────────────────────────────────────────────────

/** Connexion — retourne un JWT normalisé */
export async function login(credentials: LoginPayload): Promise<AuthResponse> {
  const raw = await apiClient.post<AuthLoginData>("/auth/login", {
    emailOuUsername: credentials.emailOuUsername,
    password:        credentials.password,
  });
  const normalized = normalizeLoginResponse(raw);
  saveAuthSession(normalized);
  return normalized;
}

/**
 * Inscription — ne retourne PAS de JWT.
 * Le serveur crée le compte et répond avec un message de confirmation.
 */
export async function register(data: RegisterPayload): Promise<RegisterResponse> {
  return apiClient.post<RegisterResponse>("/auth/register", {
    username:   data.username,
    email:      data.email,
    password:   data.password,
    telephone:  data.telephone,
    role:       data.role,
    artistName: data.artistName ?? null,
  });
}

export async function logout(): Promise<void> {
  clearAuthSession();
}
