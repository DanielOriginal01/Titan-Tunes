"use client";

import { createContext, ReactNode, useContext, useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import {
  getStoredToken,
  parseJwtToken,
  persistRoleCookie,
  persistTokenCookie,
  clearRoleCookie,
} from "@/features/auth/token";
import { login, logout, register } from "@/features/auth/service";
import { resolveRedirect } from "@/features/auth/useAuth";
import type { RegisterPayload, AuthResponse } from "@/features/auth/types";

export type AuthState = {
  user: AuthResponse["user"] | null;
  token: string | null;
  loading: boolean;
  error: string | null;
  registered: boolean;
};

export type AuthContextValue = AuthState & {
  signIn: (username: string, password: string) => Promise<void>;
  signUp: (payload: RegisterPayload) => Promise<void>;
  signOut: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

const initialState: AuthState = {
  user: null,
  token: null,
  loading: true,
  error: null,
  registered: false,
};

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>(initialState);
  const router = useRouter();

  useEffect(() => {
    if (typeof window === "undefined") return;

    const token = getStoredToken();
    if (!token) {
      setState((s) => ({ ...s, loading: false }));
      return;
    }

    let user: AuthResponse["user"] | null = null;
    const storedUser = window.localStorage.getItem("titan_user");
    if (storedUser) {
      try {
        user = JSON.parse(storedUser);
      } catch {
        user = null;
      }
    }

    if (!user) {
      user = parseJwtToken(token);
    }

    if (user?.role) {
      persistRoleCookie(user.role);
      persistTokenCookie(token);
    }

    setState({ user, token, loading: false, error: null, registered: false });
  }, []);

  const signIn = async (emailOuUsername: string, password: string) => {
    setState((s) => ({ ...s, loading: true, error: null }));
    try {
      const data = await login({ emailOuUsername, password });
      const role = String(data.user?.role ?? "").toLowerCase();

      // Les auditeurs n'ont pas accès à la plateforme web
      if (role.includes("auditeur") || role === "role_auditeur") {
        setState((s) => ({
          ...s,
          loading: false,
          error: "Ce compte auditeur n'a pas accès à la plateforme. Contactez l'administration.",
        }));
        return;
      }

      if (data.user?.role) {
        persistRoleCookie(data.user.role);
        persistTokenCookie(data.token);
      }

      if (typeof window !== "undefined") {
        window.localStorage.setItem("titan_token", data.token);
        window.localStorage.setItem("titan_user", JSON.stringify(data.user));
      }

      setState({ user: data.user, token: data.token, loading: false, error: null, registered: false });
      router.replace(resolveRedirect(role));
    } catch (err) {
      const message = err instanceof Error ? err.message : "Identifiants invalides ou erreur de connexion.";
      setState((s) => ({ ...s, loading: false, error: message }));
    }
  };

  /**
   * Inscription — met registered=true après succès.
   */
  const signUp = async (payload: RegisterPayload) => {
    setState((s) => ({ ...s, loading: true, error: null, registered: false }));
    try {
      await register(payload);
      setState({ user: null, token: null, loading: false, error: null, registered: true });
    } catch (err) {
      const message = err instanceof Error ? err.message : "Erreur lors de l'inscription.";
      setState((s) => ({ ...s, loading: false, error: message }));
    }
  };

  const signOut = async () => {
    clearRoleCookie();
    if (typeof window !== "undefined") {
      window.localStorage.removeItem("titan_token");
      window.localStorage.removeItem("titan_user");
    }
    await logout();
    setState({ user: null, token: null, loading: false, error: null, registered: false });
    router.push("/");
  };

  const value = useMemo(
    () => ({ ...state, signIn, signUp, signOut }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [state],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuthContext() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuthContext must be used within AuthProvider");
  return ctx;
}

