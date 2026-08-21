"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/hooks/useAuth";
import type { UserRole } from "@/features/auth/types";

// ─── Force du mot de passe ────────────────────────────────────────────────────

type StrengthLevel = 0 | 1 | 2 | 3 | 4;

function getPasswordStrength(pwd: string): { score: StrengthLevel; label: string; color: string } {
  if (!pwd) return { score: 0, label: "", color: "" };
  let s = 0;
  if (pwd.length >= 8)          s++;
  if (/[A-Z]/.test(pwd))        s++;
  if (/[0-9]/.test(pwd))        s++;
  if (/[^A-Za-z0-9]/.test(pwd)) s++;
  const map: Record<number, { label: string; color: string }> = {
    1: { label: "Très faible", color: "bg-rose-500" },
    2: { label: "Faible",      color: "bg-orange-400" },
    3: { label: "Moyen",       color: "bg-yellow-400" },
    4: { label: "Fort",        color: "bg-emerald-500" },
  };
  return { score: s as StrengthLevel, ...(map[s] ?? { label: "", color: "" }) };
}

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

// ─── Écran de succès (affiché inline après inscription réussie) ───────────────

function SuccessScreen({ email, onLogin }: { email: string; onLogin: () => void }) {
  return (
    <div className="flex flex-col items-center py-8 text-center">
      <div className="mb-6 flex h-16 w-16 items-center justify-center rounded-full bg-emerald-500/15 ring-2 ring-emerald-500/30">
        <svg xmlns="http://www.w3.org/2000/svg" className="h-8 w-8 text-emerald-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.8}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
        </svg>
      </div>
      <h2 className="text-2xl font-bold text-white">Compte créé !</h2>
      <p className="mt-3 max-w-xs text-sm leading-6 text-slate-400">
        Votre compte est actif. Connectez-vous maintenant avec
        <span className="font-medium text-emerald-300"> {email}</span>.
      </p>
      <button
        type="button"
        onClick={onLogin}
        className="mt-7 w-full max-w-xs rounded-2xl bg-gradient-to-r from-emerald-500 to-emerald-600 px-5 py-3.5 text-sm font-semibold text-white shadow-lg shadow-emerald-500/25 transition hover:brightness-110"
      >
        Se connecter
      </button>
    </div>
  );
}

// ─── Page principale ──────────────────────────────────────────────────────────

export default function AuthRegisterPage() {
  const auth   = useAuth();
  const router = useRouter();

  // Le rôle est fixe : seuls les artistes s'inscrivent ici
  const role: UserRole = "ROLE_ARTISTE";

  const [username, setUsername]               = useState("");
  const [email, setEmail]                     = useState("");
  const [telephone, setTelephone]             = useState("");
  const [password, setPassword]               = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [artistName, setArtistName]           = useState("");
  const [showPassword, setShowPassword]       = useState(false);
  const [localError, setLocalError]           = useState<string | null>(null);

  const strength = getPasswordStrength(password);

  // Rediriger si déjà connecté
  useEffect(() => {
    if (!auth.loading && auth.token && auth.user?.role) {
      const r = String(auth.user.role).toLowerCase();
      router.replace(r.includes("admin") ? "/admin/dashboard" : "/artist/dashboard");
    }
  }, [auth.loading, auth.token, auth.user, router]);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLocalError(null);

    if (password !== confirmPassword) {
      setLocalError("Les mots de passe ne correspondent pas.");
      return;
    }
    if (password.length < 8) {
      setLocalError("Le mot de passe doit contenir au moins 8 caractères.");
      return;
    }

    await auth.signUp({
      username,
      email,
      password,
      telephone,
      role,
      artistName: artistName.trim() || null,
    });
    // auth.registered passera à true si succès → l'écran de confirmation s'affiche
  };

  if (auth.loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-950">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
      </div>
    );
  }

  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-[radial-gradient(ellipse_at_top_left,_rgba(249,115,22,0.14),transparent_40%),radial-gradient(ellipse_at_bottom_right,_rgba(59,130,246,0.12),transparent_40%),linear-gradient(160deg,#020817_0%,#0f172a_50%,#111827_100%)] px-4 py-12">

      {/* Marque */}
      <div className="mb-8 flex w-full max-w-lg items-center justify-between">
        <Link href="/" className="flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-orange-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.8}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
          </svg>
          <span className="text-sm font-semibold uppercase tracking-widest text-orange-400">Titan Tunes</span>
        </Link>
        <Link href="/auth/login" className="rounded-full border border-slate-700 bg-slate-900/60 px-3 py-1.5 text-xs text-slate-400 transition hover:border-slate-600 hover:text-white">
          Déjà inscrit →
        </Link>
      </div>

      {/* Carte */}
      <div className="w-full max-w-lg overflow-hidden rounded-3xl border border-white/10 bg-slate-950/80 shadow-2xl shadow-black/50 backdrop-blur-2xl">

        {/* En-tête */}
        <div className="border-b border-white/8 bg-gradient-to-br from-orange-500/10 to-blue-600/10 px-8 py-7">
          <p className="text-xs font-medium uppercase tracking-[0.3em] text-orange-400">Rejoindre la plateforme</p>
          <h1 className="mt-2 text-3xl font-bold tracking-tight text-white">Créer un compte artiste</h1>
          <p className="mt-1.5 text-sm text-slate-400">Publiez votre musique et suivez vos performances.</p>
        </div>

        <div className="px-8 py-7">

          {/* Écran de succès inline */}
          {auth.registered ? (
            <SuccessScreen email={email} onLogin={() => router.push("/auth/login?registered=1")} />
          ) : (
            <form className="space-y-5" onSubmit={handleSubmit} noValidate>

              {/* Nom d'utilisateur */}
              <div className="space-y-1.5">
                <label htmlFor="reg-username" className="block text-sm font-medium text-slate-300">
                  Nom d'utilisateur <span className="text-rose-400">*</span>
                </label>
                <input
                  id="reg-username"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  type="text"
                  autoComplete="username"
                  required
                  className="w-full rounded-2xl border border-slate-700/80 bg-slate-900/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition focus:border-orange-500 focus:ring-2 focus:ring-orange-500/25"
                  placeholder="johndoe"
                />
              </div>

              {/* Nom d'artiste */}
              <div className="space-y-1.5">
                <label htmlFor="reg-artist" className="block text-sm font-medium text-slate-300">
                  Nom d'artiste <span className="text-slate-500 font-normal">(optionnel)</span>
                </label>
                <input
                  id="reg-artist"
                  value={artistName}
                  onChange={(e) => setArtistName(e.target.value)}
                  type="text"
                  className="w-full rounded-2xl border border-slate-700/80 bg-slate-900/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition focus:border-orange-500 focus:ring-2 focus:ring-orange-500/25"
                  placeholder="Nom de scène (défaut : nom d'utilisateur)"
                />
              </div>

              {/* Email */}
              <div className="space-y-1.5">
                <label htmlFor="reg-email" className="block text-sm font-medium text-slate-300">
                  Email <span className="text-rose-400">*</span>
                </label>
                <input
                  id="reg-email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  type="email"
                  autoComplete="email"
                  required
                  className="w-full rounded-2xl border border-slate-700/80 bg-slate-900/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition focus:border-orange-500 focus:ring-2 focus:ring-orange-500/25"
                  placeholder="nom@exemple.com"
                />
              </div>

              {/* Téléphone */}
              <div className="space-y-1.5">
                <label htmlFor="reg-tel" className="block text-sm font-medium text-slate-300">
                  Téléphone <span className="text-rose-400">*</span>
                </label>
                <input
                  id="reg-tel"
                  value={telephone}
                  onChange={(e) => setTelephone(e.target.value)}
                  type="tel"
                  autoComplete="tel"
                  required
                  className="w-full rounded-2xl border border-slate-700/80 bg-slate-900/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition focus:border-orange-500 focus:ring-2 focus:ring-orange-500/25"
                  placeholder="+22890000000"
                />
              </div>

              {/* Mot de passe */}
              <div className="space-y-1.5">
                <label htmlFor="reg-pwd" className="block text-sm font-medium text-slate-300">
                  Mot de passe <span className="text-rose-400">*</span>
                </label>
                <div className="relative">
                  <input
                    id="reg-pwd"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    type={showPassword ? "text" : "password"}
                    autoComplete="new-password"
                    required
                    minLength={8}
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
                {/* Barre de force */}
                {password.length > 0 && (
                  <div className="mt-2 space-y-1">
                    <div className="flex gap-1">
                      {[1, 2, 3, 4].map((lvl) => (
                        <div
                          key={lvl}
                          className={[
                            "h-1.5 flex-1 rounded-full transition-all",
                            strength.score >= lvl ? strength.color : "bg-slate-700",
                          ].join(" ")}
                        />
                      ))}
                    </div>
                    {strength.label && (
                      <p className="text-xs text-slate-500">Force : <span className="text-slate-300">{strength.label}</span></p>
                    )}
                  </div>
                )}
              </div>

              {/* Confirmer mot de passe */}
              <div className="space-y-1.5">
                <label htmlFor="reg-confirm" className="block text-sm font-medium text-slate-300">
                  Confirmer le mot de passe <span className="text-rose-400">*</span>
                </label>
                <input
                  id="reg-confirm"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  type={showPassword ? "text" : "password"}
                  autoComplete="new-password"
                  required
                  className={[
                    "w-full rounded-2xl border px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition bg-slate-900/60 focus:ring-2",
                    confirmPassword && confirmPassword !== password
                      ? "border-rose-500 focus:border-rose-500 focus:ring-rose-500/20"
                      : "border-slate-700/80 focus:border-orange-500 focus:ring-orange-500/25",
                  ].join(" ")}
                  placeholder="••••••••"
                />
                {confirmPassword && confirmPassword !== password && (
                  <p className="text-xs text-rose-400">Les mots de passe ne correspondent pas.</p>
                )}
              </div>

              {/* Erreur */}
              {(localError || auth.error) && (
                <p role="alert" className="rounded-2xl border border-rose-500/30 bg-rose-500/10 px-4 py-3 text-sm text-rose-300">
                  {localError ?? auth.error}
                </p>
              )}

              {/* Submit */}
              <button
                type="submit"
                disabled={auth.loading}
                className="w-full rounded-2xl bg-gradient-to-r from-orange-500 to-orange-600 px-5 py-3.5 text-sm font-semibold text-white shadow-lg shadow-orange-500/25 transition hover:brightness-110 active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-60"
              >
                {auth.loading ? (
                  <span className="flex items-center justify-center gap-2">
                    <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
                    Création du compte…
                  </span>
                ) : (
                  "Créer mon compte artiste"
                )}
              </button>

              <p className="text-center text-sm text-slate-500">
                Déjà un compte ?{" "}
                <Link href="/auth/login" className="font-semibold text-orange-400 transition hover:text-orange-300">
                  Se connecter
                </Link>
              </p>
            </form>
          )}
        </div>
      </div>
    </main>
  );
}
