import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

// ─── Routes publiques — jamais interceptées ───────────────────────────────────

/**
 * Retourne true si la route ne nécessite aucune vérification d'auth.
 * On compare uniquement le pathname (sans query string).
 */
function isPublic(pathname: string): boolean {
  // Racine
  if (pathname === "/") return true;

  // Tout l'espace auth artiste : /auth/login, /auth/register, /auth/...
  if (pathname.startsWith("/auth")) return true;

  // Page de login admin — chemin exact ou avec trailing slash
  if (pathname === "/admin/login" || pathname.startsWith("/admin/login/")) return true;

  // Fichiers Next.js internes
  if (pathname.startsWith("/_next")) return true;
  if (pathname.startsWith("/favicon")) return true;

  return false;
}

// ─── Lecture du rôle depuis les cookies ──────────────────────────────────────

function getCookie(req: NextRequest, name: string): string | null {
  return req.cookies.get(name)?.value ?? null;
}

function getRoleFromJwt(token: string): string | null {
  try {
    const base64 = token.split(".")[1].replace(/-/g, "+").replace(/_/g, "/");
    const payload = JSON.parse(Buffer.from(base64, "base64").toString("utf-8"));
    const role =
      payload.role ??
      (Array.isArray(payload.roles) ? payload.roles[0] : undefined) ??
      (Array.isArray(payload.authorities)
        ? typeof payload.authorities[0] === "string"
          ? payload.authorities[0]
          : payload.authorities[0]?.authority
        : undefined);
    return typeof role === "string" ? role.toLowerCase() : null;
  } catch {
    return null;
  }
}

/**
 * Résout le rôle depuis les cookies.
 * - null  → aucun cookie présent (localStorage seul) → on laisse passer, AuthGuard gère
 * - ""    → cookie présent mais rôle illisible → traité comme non authentifié
 * - role  → rôle extrait
 */
function resolveRole(req: NextRequest): string | null {
  const roleCookie = getCookie(req, "titan_role");
  if (roleCookie) return decodeURIComponent(roleCookie).toLowerCase();

  const tokenCookie = getCookie(req, "titan_auth");
  if (tokenCookie) return getRoleFromJwt(decodeURIComponent(tokenCookie)) ?? "";

  return null;
}

// ─── Middleware ───────────────────────────────────────────────────────────────

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // 1. Routes publiques → toujours accessibles, aucune vérification
  if (isPublic(pathname)) return NextResponse.next();

  const role = resolveRole(req);

  // 2. Aucun cookie → AuthGuard côté client prend le relais
  //    (le token peut être uniquement dans localStorage, inaccessible côté Edge)
  if (role === null) return NextResponse.next();

  // 3. Zone artiste (/artist/*)
  if (pathname.startsWith("/artist")) {
    const ok =
      role.includes("role_artiste") ||
      role.includes("artiste") ||
      role.includes("artist");
    if (!ok) {
      return NextResponse.redirect(new URL("/auth/login", req.url));
    }
  }

  // 4. Zone admin (/admin/*) — /admin/login déjà sorti à l'étape 1
  if (pathname.startsWith("/admin")) {
    const ok = role.includes("role_admin") || role.includes("admin");
    if (!ok) {
      return NextResponse.redirect(new URL("/admin/login", req.url));
    }
  }

  return NextResponse.next();
}

// Intercepter toutes les routes sauf les assets statiques
export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon\\.ico|logos/|.*\\.(?:svg|png|jpg|jpeg|gif|webp|ico|woff2?)$).*)",
  ],
};
