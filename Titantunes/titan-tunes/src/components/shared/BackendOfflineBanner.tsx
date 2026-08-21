"use client";

import { useBackendStatus } from "@/providers/BackendStatusProvider";

/**
 * Bannière persistante affichée en haut de l'écran quand le backend
 * est injoignable. Disparaît automatiquement dès la reconnexion.
 */
export default function BackendOfflineBanner() {
  const { online, lastChecked } = useBackendStatus();

  if (online) return null;

  const time = lastChecked
    ? lastChecked.toLocaleTimeString("fr-FR", { hour: "2-digit", minute: "2-digit", second: "2-digit" })
    : null;

  return (
    <div
      role="alert"
      aria-live="assertive"
      className="fixed inset-x-0 top-0 z-[9999] flex items-center justify-between gap-4 bg-rose-600 px-5 py-3 text-white shadow-lg"
    >
      <div className="flex items-center gap-3">
        {/* Icône pulsante */}
        <span className="relative flex h-3 w-3 shrink-0">
          <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-white opacity-60" />
          <span className="relative inline-flex h-3 w-3 rounded-full bg-white" />
        </span>

        <p className="text-sm font-medium">
          Connexion au serveur perdue.{" "}
          <span className="font-normal opacity-80">
            Vérifiez que le backend est démarré et accessible.
          </span>
          {time && (
            <span className="ml-2 opacity-60 text-xs">— dernière vérification {time}</span>
          )}
        </p>
      </div>

      {/* Badge "Reconnexion..." */}
      <span className="shrink-0 rounded-full border border-white/30 bg-white/10 px-3 py-1 text-xs font-medium">
        Reconnexion en cours…
      </span>
    </div>
  );
}
