"use client";

import Image from "next/image";
import Link from "next/link";
import ThemeToggle from "@/app/components/ThemeToggle";
import { useAuth } from "@/hooks/useAuth";

export default function Header() {
  const { user, token, signOut } = useAuth();
  const role = String(user?.role || "").toLowerCase();
  const isAdmin = role.includes("admin");
  const isArtiste = role.includes("artiste") || role.includes("artist");

  return (
    <header
      className="sticky top-0 z-30 border-b backdrop-blur-xl"
      style={{ borderColor: "var(--border)", backgroundColor: "var(--bg-elevated)", color: "var(--foreground)" }}
    >
      <div className="mx-auto flex max-w-7xl items-center justify-between gap-4 px-6 py-4 sm:px-10">
        <Link href="/" className="inline-flex items-center gap-3">
          <div
            className="relative h-11 w-11 overflow-hidden rounded-2xl ring-1 shadow-lg shadow-sky-500/10"
            style={{ backgroundColor: "var(--surface)", borderColor: "var(--border)" }}
          >
            <Image
              src="/logos/titan_orange_tunes.png"
              alt="Titan Tunes"
              fill
              sizes="44px"
              className="h-full w-full object-contain"
            />
          </div>
          <div>
            <p className="text-sm font-semibold" style={{ color: "var(--foreground)" }}>
              Titan Tunes
            </p>
            <p className="text-xs" style={{ color: "var(--muted)" }}>
              Plateforme Promotionnelle & Distribution
            </p>
          </div>
        </Link>

        <div className="flex items-center gap-3 sm:gap-4">
          <ThemeToggle />

          {token && user ? (
            <div className="flex items-center gap-3">
              <Link
                href={isAdmin ? "/admin/dashboard" : "/artist/dashboard"}
                className={[
                  "inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm font-semibold shadow-lg transition hover:brightness-110",
                  isAdmin
                    ? "bg-gradient-to-r from-blue-600 to-blue-700 text-white shadow-blue-500/20"
                    : "bg-gradient-to-r from-orange-500 to-amber-500 text-white shadow-orange-500/20",
                ].join(" ")}
              >
                <span>{isAdmin ? "Tableau de Bord Admin" : "Espace Artiste"}</span>
                <span className="text-xs opacity-80">({user.username})</span>
              </Link>
              <button
                onClick={() => signOut()}
                className="rounded-full border px-3 py-2 text-xs font-semibold text-slate-400 hover:border-rose-500/40 hover:text-rose-400 transition"
                style={{ borderColor: "var(--border)" }}
              >
                Déconnexion
              </button>
            </div>
          ) : (
            <div className="flex items-center gap-3">
              <Link
                href="/auth/login"
                className="inline-flex items-center justify-center rounded-full border px-4 py-2 text-sm font-semibold transition hover:brightness-110"
                style={{ borderColor: "var(--border)", backgroundColor: "var(--surface)", color: "var(--foreground)" }}
              >
                Connexion
              </Link>
              <Link
                href="/auth/register"
                className="inline-flex items-center justify-center rounded-full bg-gradient-to-r from-orange-500 to-[#f59e0b] px-4 py-2 text-sm font-semibold text-white shadow-lg shadow-orange-500/20 transition hover:brightness-110"
              >
                Rejoindre comme Artiste
              </Link>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
