"use client";

import Link from "next/link";
import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/hooks/useAuth";

// ─── Icône œil ────────────────────────────────────────────────────────────────

function EyeIcon({ open }: { open: boolean }) {
  return open ? (
    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.8}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M13.875 18.825A10.05 10.05 0 0112 19c-5 0-9-4-9-7s4-7 9-7a9.97 9.97 0 016.025 2.025M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
      <path strokeLinecap="round" strokeLinejoin="round" d="M3 3l18 18" />
    </svg>
  ) : (
    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.8}>
      <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
      <path strokeLinecap="round" strokeLinejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
    </svg>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

export default function AdminLoginPage() {
  const auth   = useAuth();
  const router = useRouter();

  const [identifier,    setIdentifier]    = useState("");
  const [password,      setPassword]      = useState("");
  const [showPassword,  setShowPassword]  = useState(false);
  const [localError,    setLocalError]    = useState<string | null>(null);

  // Empêche une double redirection si le composant se re-rend
  const redirecting = useRef(false);

  // ── Garde : déjà connecté en tant qu'admin → aller directement au dashboard
  useEffect(() => {
    if (auth.loading || redirecting.current) return;
    if (auth.token && auth.user?.role) {
      const role = String(auth.user.role).toLowerCase();
      if (role.includes("admin")) {
        redirecting.current = true;
        router.replace("/admin/dashboard");
      }
    }
  }, [auth.loading, auth.token, auth.user?.role, router]);

  // ── Soumission du formulaire ──────────────────────────────────────────────
  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (redirecting.current) return;
    setLocalError(null);

    await auth.signIn(identifier.trim(), password);
  };

  // ── Affichage ─────────────────────────────────────────────────────────────

  if (auth.loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-950">
        <div className="h-9 w-9 animate-spin rounded-full border-4 border-blue-500 border-t-transparent" />
      </div>
    );
  }

  const errorMsg = localError ?? auth.error;

  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-[radial-gradient(ellipse_at_top_left,_rgba(59,130,246,0.15),transparent_40%),radial-gradient(ellipse_at_bottom_right,_rgba(249,115,22,0.10),transparent_40%),linear-gradient(160deg,#020817_0%,#0f172a_50%,#111827_100%)] px-4 py-12">

      {/* Marque */}
      <div className="mb-8 flex w-full max-w-md items-center justify-between">
        <div className="flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.8}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
          </svg>
          <span className="text-sm font-semibold uppercase tracking-widest text-blue-400">
            Titan Tunes Admin
          </span>
        </div>
        <Link
          href="/"
          className="rounded-full border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-xs text-slate-400 transition hover:border-slate-600 hover:text-white"
        >
          ← Accueil
        </Link>
      </div>

      {/* Carte */}
      <div className="w-full max-w-md overflow-hidden rounded-3xl border border-blue-500/20 bg-slate-950/80 shadow-2xl shadow-black/50 backdrop-blur-2xl">

        {/* En-tête */}
        <div className="border-b border-blue-500/15 bg-gradient-to-br from-blue-600/12 to-slate-900/0 px-8 py-7">
          <p className="text-xs font-medium uppercase tracking-[0.3em] text-blue-400">
            Accès restreint
          </p>
          <h1 className="mt-2 text-3xl font-bold tracking-tight text-white">
            Administration
          </h1>
          <p className="mt-1.5 text-sm text-slate-400">
            Réservé aux administrateurs de la plateforme.
          </p>
        </div>

        {/* Formulaire */}
        <div className="px-8 py-7">
          <form className="space-y-5" onSubmit={handleSubmit} noValidate>

            {/* Identifiant */}
            <div className="space-y-1.5">
              <label htmlFor="admin-id" className="block text-sm font-medium text-slate-300">
                Email ou nom d&apos;utilisateur
              </label>
              <input
                id="admin-id"
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                type="text"
                autoComplete="username"
                autoFocus
                required
                disabled={auth.loading}
                className="w-full rounded-2xl border border-slate-700/80 bg-slate-900/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition focus:border-blue-500 focus:ring-2 focus:ring-blue-500/25 disabled:opacity-50"
                placeholder="admin@titantunes.com"
              />
            </div>

            {/* Mot de passe */}
            <div className="space-y-1.5">
              <label htmlFor="admin-pwd" className="block text-sm font-medium text-slate-300">
                Mot de passe
              </label>
              <div className="relative">
                <input
                  id="admin-pwd"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  type={showPassword ? "text" : "password"}
                  autoComplete="current-password"
                  required
                  disabled={auth.loading}
                  className="w-full rounded-2xl border border-slate-700/80 bg-slate-900/60 px-4 py-3 pr-12 text-sm text-white placeholder-slate-500 outline-none transition focus:border-blue-500 focus:ring-2 focus:ring-blue-500/25 disabled:opacity-50"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((v) => !v)}
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 p-1 text-slate-400 transition hover:text-slate-200"
                  aria-label={showPassword ? "Masquer le mot de passe" : "Afficher le mot de passe"}
                >
                  <EyeIcon open={showPassword} />
                </button>
              </div>
            </div>

            {/* Message d'erreur */}
            {errorMsg && (
              <div
                role="alert"
                className="flex items-start gap-3 rounded-2xl border border-rose-500/30 bg-rose-500/10 px-4 py-3"
              >
                <svg className="mt-0.5 h-4 w-4 shrink-0 text-rose-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" />
                </svg>
                <p className="text-sm text-rose-300">{errorMsg}</p>
              </div>
            )}

            {/* Bouton de connexion */}
            <button
              type="submit"
              disabled={auth.loading || !identifier || !password}
              className="w-full rounded-2xl bg-gradient-to-r from-blue-600 to-blue-700 px-5 py-3.5 text-sm font-semibold text-white shadow-lg shadow-blue-600/25 transition hover:brightness-110 active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-60"
            >
              {auth.loading ? (
                <span className="flex items-center justify-center gap-2">
                  <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
                  Connexion en cours…
                </span>
              ) : (
                "Accéder au panneau admin"
              )}
            </button>

          </form>
        </div>
      </div>

      {/* Pied de page */}
      <p className="mt-8 text-center text-xs text-slate-600">
        Titan Tunes © {new Date().getFullYear()} · Accès administrateur sécurisé
      </p>
    </main>
  );
}
