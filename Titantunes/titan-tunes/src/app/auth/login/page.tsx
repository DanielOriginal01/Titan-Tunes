"use client";

import Link from "next/link";
import { Suspense, useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
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

// ─── Formulaire (isolé pour useSearchParams + Suspense) ───────────────────────

function LoginForm() {
  const auth        = useAuth();
  const router      = useRouter();
  const params      = useSearchParams();
  const justRegistered = params.get("registered") === "1";

  const [identifier, setIdentifier]     = useState("");
  const [password, setPassword]         = useState("");
  const [showPassword, setShowPassword] = useState(false);

  // Rediriger si déjà authentifié
  useEffect(() => {
    if (!auth.loading && auth.token && auth.user?.role) {
      const role = String(auth.user.role).toLowerCase();
      router.replace(role.includes("admin") ? "/admin/dashboard" : "/artist/dashboard");
    }
  }, [auth.loading, auth.token, auth.user, router]);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    await auth.signIn(identifier, password);
    // useAuth.signIn gère la redirection selon le rôle
  };

  if (auth.loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-950">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
      </div>
    );
  }

  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-[radial-gradient(ellipse_at_top_left,_rgba(249,115,22,0.15),transparent_40%),radial-gradient(ellipse_at_bottom_right,_rgba(59,130,246,0.12),transparent_40%),linear-gradient(160deg,#020817_0%,#0f172a_50%,#111827_100%)] px-4 py-12">

      {/* Marque */}
      <div className="mb-8 flex w-full max-w-md items-center justify-between">
        <Link href="/" className="flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-orange-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.8}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
          </svg>
          <span className="text-sm font-semibold uppercase tracking-widest text-orange-400">Titan Tunes</span>
        </Link>
        <Link href="/" className="rounded-full border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-xs text-slate-400 transition hover:border-slate-600 hover:text-white">
          ← Accueil
        </Link>
      </div>

      {/* Carte */}
      <div className="w-full max-w-md overflow-hidden rounded-3xl border border-white/10 bg-slate-950/80 shadow-2xl shadow-black/50 backdrop-blur-2xl">

        {/* En-tête */}
        <div className="border-b border-white/8 bg-gradient-to-br from-orange-500/10 to-blue-600/10 px-8 py-7">
          <p className="text-xs font-medium uppercase tracking-[0.3em] text-orange-400">Espace artiste</p>
          <h1 className="mt-2 text-3xl font-bold tracking-tight text-white">Connexion</h1>
          <p className="mt-1.5 text-sm text-slate-400">Accédez à votre tableau de bord artiste.</p>
        </div>

        <div className="px-8 py-7">

          {/* Bannière post-inscription */}
          {justRegistered && (
            <div className="mb-6 flex items-start gap-3 rounded-2xl border border-emerald-500/30 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-300">
              <svg xmlns="http://www.w3.org/2000/svg" className="mt-0.5 h-4 w-4 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
              </svg>
              Compte créé. Connectez-vous pour accéder à votre espace.
            </div>
          )}

          <form className="space-y-5" onSubmit={handleSubmit} noValidate>

            <div className="space-y-1.5">
              <label htmlFor="login-id" className="block text-sm font-medium text-slate-300">
                Email ou nom d'utilisateur
              </label>
              <input
                id="login-id"
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                type="text"
                autoComplete="username"
                autoFocus
                required
                className="w-full rounded-2xl border border-slate-700/80 bg-slate-900/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition focus:border-orange-500 focus:ring-2 focus:ring-orange-500/25"
                placeholder="johndoe ou johndoe@exemple.com"
              />
            </div>

            <div className="space-y-1.5">
              <label htmlFor="login-pwd" className="block text-sm font-medium text-slate-300">
                Mot de passe
              </label>
              <div className="relative">
                <input
                  id="login-pwd"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  type={showPassword ? "text" : "password"}
                  autoComplete="current-password"
                  required
                  className="w-full rounded-2xl border border-slate-700/80 bg-slate-900/60 px-4 py-3 pr-12 text-sm text-white placeholder-slate-500 outline-none transition focus:border-orange-500 focus:ring-2 focus:ring-orange-500/25"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((v) => !v)}
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 p-1 text-slate-400 transition hover:text-slate-200"
                  aria-label={showPassword ? "Masquer" : "Afficher"}
                >
                  <EyeIcon open={showPassword} />
                </button>
              </div>
            </div>

            {auth.error && (
              <p role="alert" className="rounded-2xl border border-rose-500/30 bg-rose-500/10 px-4 py-3 text-sm text-rose-300">
                {auth.error}
              </p>
            )}

            <button
              type="submit"
              disabled={auth.loading}
              className="w-full rounded-2xl bg-gradient-to-r from-orange-500 to-orange-600 px-5 py-3.5 text-sm font-semibold text-white shadow-lg shadow-orange-500/25 transition hover:brightness-110 active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-60"
            >
              {auth.loading ? (
                <span className="flex items-center justify-center gap-2">
                  <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
                  Connexion…
                </span>
              ) : (
                "Se connecter"
              )}
            </button>
          </form>

          <p className="mt-6 text-center text-sm text-slate-500">
            Pas encore de compte ?{" "}
            <Link href="/auth/register" className="font-semibold text-orange-400 transition hover:text-orange-300">
              Créer un compte
            </Link>
          </p>
        </div>
      </div>
    </main>
  );
}

// ─── Export avec Suspense (requis par useSearchParams) ────────────────────────

export default function AuthLoginPage() {
  return (
    <Suspense fallback={
      <div className="flex min-h-screen items-center justify-center bg-slate-950">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
      </div>
    }>
      <LoginForm />
    </Suspense>
  );
}
