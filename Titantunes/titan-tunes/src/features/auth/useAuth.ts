"use client";

import { useAuthContext } from "@/providers/AuthProvider";
import type { AuthState } from "@/providers/AuthProvider";

export type { AuthState };

/** Détermine la route de redirection après connexion selon le rôle JWT */
export function resolveRedirect(rawRole: string): string {
  const role = String(rawRole || "").toLowerCase();
  if (role.includes("role_admin") || role.includes("admin") || role.includes("administr")) {
    return "/admin/dashboard";
  }
  return "/artist/dashboard";
}

export function useAuth() {
  return useAuthContext();
}

export default useAuth;

