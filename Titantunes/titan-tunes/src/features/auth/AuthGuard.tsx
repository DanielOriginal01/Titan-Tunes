"use client";

import { type ReactNode, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "./useAuth";

// ─── Types ────────────────────────────────────────────────────────────────────

interface AuthGuardProps {
  children: ReactNode;
  /**
   * Rôle requis pour accéder à la zone protégée.
   * Valeurs reconnues : "artist" | "administrateur" (ou toute variante contenant "admin" / "artist")
   * Si absent → vérifie seulement qu'un token existe (zone authentifiée générique).
   */
  role?: string;
}

// ─── Helpers de rôle ─────────────────────────────────────────────────────────

function normalizeRole(s: unknown): string {
  return String(s ?? "").toLowerCase().trim();
}

function isAdminRole(role: string): boolean {
  return role.includes("admin");
}

function isArtistRole(role: string): boolean {
  return role.includes("artiste") || role.includes("artist");
}

/**
 * Retourne true si l'utilisateur possède le rôle requis.
 * Si aucun rôle requis → true (zone authentifiée sans restriction de rôle).
 */
function isAllowed(userRole: string, requiredRole: string): boolean {
  if (!requiredRole) return true;
  if (isAdminRole(requiredRole))  return isAdminRole(userRole);
  if (isArtistRole(requiredRole)) return isArtistRole(userRole);
  return false;
}

/**
 * Détermine la page de login selon le rôle requis.
 */
function loginPageFor(requiredRole: string): string {
  return isAdminRole(requiredRole) ? "/admin/login" : "/auth/login";
}

/**
 * Détermine la page de redirection quand l'utilisateur a le mauvais rôle.
 */
function dashboardFor(userRole: string): string {
  if (isAdminRole(userRole))  return "/admin/dashboard";
  if (isArtistRole(userRole)) return "/artist/dashboard";
  return "/";
}

// ─── Spinner ─────────────────────────────────────────────────────────────────

function FullScreenSpinner({ color = "orange" }: { color?: "orange" | "blue" }) {
  const ring = color === "blue"
    ? "border-blue-500"
    : "border-orange-500";
  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-950">
      <div className={`h-10 w-10 animate-spin rounded-full border-4 ${ring} border-t-transparent`} />
    </div>
  );
}

// ─── AuthGuard ────────────────────────────────────────────────────────────────

/**
 * Composant de protection de zone.
 *
 * Comportement :
 *  1. Pendant l'initialisation (loading) → spinner plein écran (évite tout flash)
 *  2. Pas de token → redirect vers la page de login correspondante
 *  3. Token + rôle OK → render les enfants
 *  4. Token + mauvais rôle → redirect vers le bon dashboard
 *
 * Garanties :
 *  - La redirection n'est déclenchée qu'une seule fois (ref `redirected`)
 *    pour éviter les boucles dans StrictMode et les renders multiples.
 *  - Aucun render des enfants n'a lieu tant que l'état n'est pas résolu.
 */
export default function AuthGuard({ children, role }: AuthGuardProps) {
  const auth        = useAuth();
  const router      = useRouter();
  const reqRole     = normalizeRole(role);
  const redirected  = useRef(false);

  useEffect(() => {
    // Attend la fin de l'initialisation
    if (auth.loading) return;
    // Ne déclenche la redirection qu'une seule fois
    if (redirected.current) return;

    if (!auth.token) {
      // Pas authentifié → page de login
      redirected.current = true;
      router.replace(loginPageFor(reqRole));
      return;
    }

    if (reqRole) {
      const userRole = normalizeRole(auth.user?.role);
      if (!isAllowed(userRole, reqRole)) {
        // Authentifié mais mauvais rôle → bon dashboard
        redirected.current = true;
        router.replace(dashboardFor(userRole));
      }
    }
  }, [auth.loading, auth.token, auth.user?.role, reqRole, router]);

  // ── Rendu ─────────────────────────────────────────────────────────────────

  // Pendant l'init : spinner (jamais de flash de contenu protégé)
  if (auth.loading) {
    const spinnerColor = isAdminRole(reqRole) ? "blue" : "orange";
    return <FullScreenSpinner color={spinnerColor} />;
  }

  // Pas de token : on rend null (la redirection est en cours)
  if (!auth.token) return null;

  // Mauvais rôle : on rend null (la redirection est en cours)
  if (reqRole) {
    const userRole = normalizeRole(auth.user?.role);
    if (!isAllowed(userRole, reqRole)) return null;
  }

  return <>{children}</>;
}
