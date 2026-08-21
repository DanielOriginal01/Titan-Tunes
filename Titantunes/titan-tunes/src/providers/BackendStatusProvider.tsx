"use client";

/**
 * BackendStatusProvider
 * ---------------------
 * Détecte la disponibilité du backend Spring Boot et expose un contexte
 * { online, lastChecked } consommable dans toute l'app.
 *
 * Deux mécanismes complémentaires :
 *  1. Ping actif toutes les PING_INTERVAL ms vers /actuator/health
 *     (ou /api/v1/auth/login avec méthode HEAD si pas d'actuator).
 *  2. Écoute de l'événement global "backend:offline" / "backend:online"
 *     que l'intercepteur Axios dispatch quand il rencontre une erreur réseau.
 */

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
  type ReactNode,
} from "react";

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080/api/v1";
/** Endpoint léger pour le ping — on utilise HEAD sur /auth/login */
const PING_URL = `${API_BASE}/auth/login`;
const PING_INTERVAL = 15_000; // 15 s
const PING_TIMEOUT  =  5_000; //  5 s

type BackendStatus = {
  online: boolean;
  lastChecked: Date | null;
};

const BackendStatusContext = createContext<BackendStatus>({
  online: true,
  lastChecked: null,
});

export function useBackendStatus() {
  return useContext(BackendStatusContext);
}

async function ping(): Promise<boolean> {
  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), PING_TIMEOUT);
    const res = await fetch(PING_URL, {
      method: "HEAD",
      signal: controller.signal,
      cache: "no-store",
    });
    clearTimeout(timer);
    // Tout code HTTP (même 401/405) signifie que le serveur répond
    return res.status < 600;
  } catch {
    return false;
  }
}

export function BackendStatusProvider({ children }: { children: ReactNode }) {
  const [status, setStatus] = useState<BackendStatus>({
    online: true,
    lastChecked: null,
  });
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const check = useCallback(async () => {
    const reachable = await ping();
    setStatus({ online: reachable, lastChecked: new Date() });
  }, []);

  useEffect(() => {
    // Premier ping immédiat
    check();

    // Ping périodique
    intervalRef.current = setInterval(check, PING_INTERVAL);

    // Écoute des événements dispatchés par l'intercepteur Axios
    const handleOffline = () => setStatus((s) => ({ ...s, online: false, lastChecked: new Date() }));
    const handleOnline  = () => setStatus((s) => ({ ...s, online: true,  lastChecked: new Date() }));

    window.addEventListener("backend:offline", handleOffline);
    window.addEventListener("backend:online",  handleOnline);

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
      window.removeEventListener("backend:offline", handleOffline);
      window.removeEventListener("backend:online",  handleOnline);
    };
  }, [check]);

  return (
    <BackendStatusContext.Provider value={status}>
      {children}
    </BackendStatusContext.Provider>
  );
}
