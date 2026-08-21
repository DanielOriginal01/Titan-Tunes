"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useAuth } from "@/hooks/useAuth";
import {
  getArtisteProfile,
  getArtisteDashboard,
  getAllChansons,
  getEvenementsByArtiste,
} from "@/services/artist";
import type { ArtisteResponse, ArtisteDashboard, ChansonResponse, EvenementResponse } from "@/types/api";

// ─── Types locaux ─────────────────────────────────────────────────────────────

interface DashboardData {
  profil:     ArtisteResponse;
  photoUrl:   string | null;
  kpis:       ArtisteDashboard;
  chansons:   ChansonResponse[];
  evenements: EvenementResponse[];
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function fmtDuration(sec?: number): string {
  if (!sec) return "—";
  const m = Math.floor(sec / 60);
  const s = sec % 60;
  return `${m}:${String(s).padStart(2, "0")}`;
}

function countdown(dateStr: string): { label: string; urgency: "high" | "medium" | "low" } {
  const jours = Math.ceil((new Date(dateStr).getTime() - Date.now()) / 86_400_000);
  if (jours === 0) return { label: "Aujourd'hui", urgency: "high" };
  if (jours < 0)  return { label: "Passé",        urgency: "low"  };
  if (jours <= 7) return { label: `J-${jours}`,   urgency: "high"   };
  if (jours <= 30) return { label: `J-${jours}`,  urgency: "medium" };
  return             { label: `J-${jours}`,        urgency: "low"    };
}

// ─── Composants atomiques ─────────────────────────────────────────────────────

function KpiCard({ label, value, accent, icon }: {
  label: string; value: string; accent: string; icon: React.ReactNode;
}) {
  return (
    <article className="group relative overflow-hidden rounded-[2rem] bg-slate-900/70 p-6 ring-1 ring-slate-700/50 transition hover:ring-slate-600/60">
      <div className={`absolute -right-4 -top-4 h-24 w-24 rounded-full bg-gradient-to-br ${accent} opacity-10 blur-2xl transition group-hover:opacity-20`} />
      <div className={`mb-4 flex h-10 w-10 items-center justify-center rounded-2xl bg-gradient-to-br ${accent} text-white shadow-lg`}>
        {icon}
      </div>
      <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">{label}</p>
      <p className="mt-2 text-3xl font-bold text-white">{value}</p>
    </article>
  );
}

function SectionTitle({ children, href, linkLabel = "Voir tout →" }: {
  children: React.ReactNode; href?: string; linkLabel?: string;
}) {
  return (
    <div className="mb-5 flex items-center justify-between">
      <h2 className="text-base font-semibold text-white">{children}</h2>
      {href && (
        <Link href={href} className="text-xs text-orange-400 transition hover:text-orange-300">
          {linkLabel}
        </Link>
      )}
    </div>
  );
}

// ─── Icônes KPI ───────────────────────────────────────────────────────────────

const IcEcoutes  = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9 19V6l12-3v13M9 19c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zm12-3c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zM9 10l12-3" /></svg>;
const IcUsers    = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" /></svg>;
const IcMusic    = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9 19V6l12-3v13M9 19c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zm12-3c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zM9 10l12-3" /></svg>;
const IcAlbum    = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" strokeLinecap="round" strokeLinejoin="round" /><circle cx="12" cy="12" r="3" strokeLinecap="round" strokeLinejoin="round" /></svg>;
const IcMoney    = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>;
const IcHeart    = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg>;
const IcPie      = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z" /><path strokeLinecap="round" strokeLinejoin="round" d="M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z" /></svg>;

// ─── Page principale ──────────────────────────────────────────────────────────

export default function ArtistDashboardPage() {
  const { user } = useAuth();

  const [data,    setData]    = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error,   setError]   = useState<string | null>(null);

  useEffect(() => {
    if (!user?.id) return;
    let cancelled = false;

    (async () => {
      setLoading(true);
      setError(null);
      try {
        const [profileRes, kpisRes, chansonsRes, eventsRes] = await Promise.allSettled([
          getArtisteProfile(user.id),
          getArtisteDashboard(user.id),
          getAllChansons(),
          getEvenementsByArtiste(user.id),
        ]);

        const profileData = profileRes.status === "fulfilled" ? profileRes.value : {
          profil: {
            id: user.id,
            nom: user.username || "Artiste",
            prenom: "",
            username: user.username || "Artiste",
            email: user.email || "",
            role: "ROLE_ARTISTE",
            verifie: false,
          } as unknown as ArtisteResponse,
          photoUrl: null,
        };

        const kpis = kpisRes.status === "fulfilled" ? kpisRes.value : {
          totalEcoutes: 0,
          auditeursUniques: 0,
          totalChansons: 0,
          totalAlbums: 0,
          royaltiesEstimees: 0,
          totalFavoris: 0,
          partCatalogue: "—",
        };

        const allChansons = chansonsRes.status === "fulfilled" ? chansonsRes.value : [];
        const allEvents   = eventsRes.status === "fulfilled" ? eventsRes.value : [];

        // Filtrer les chansons de l'artiste + tri par nb écoutes décroissant
        const chansons = allChansons
          .filter((c) => c.artisteId === user.id)
          .sort((a, b) => (b.nbEcoutes || 0) - (a.nbEcoutes || 0))
          .slice(0, 5);

        // Garder uniquement les événements futurs, triés par date croissante
        const now = Date.now();
        const evenements = allEvents
          .filter((e) => e.dateEvenement && new Date(e.dateEvenement).getTime() >= now)
          .sort((a, b) => new Date(a.dateEvenement).getTime() - new Date(b.dateEvenement).getTime())
          .slice(0, 4);

        if (!cancelled) {
          setData({
            profil: profileData.profil,
            photoUrl: profileData.photoUrl,
            kpis,
            chansons,
            evenements,
          });
        }
      } catch (err) {
        if (!cancelled) setError(err instanceof Error ? err.message : "Impossible de charger le tableau de bord.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();

    return () => { cancelled = true; };
  }, [user?.id]);

  // ── Spinner ────────────────────────────────────────────────────────────────
  if (loading) {
    return (
      <div className="flex min-h-[60vh] items-center justify-center">
        <div className="h-10 w-10 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
      </div>
    );
  }

  // ── Erreur ─────────────────────────────────────────────────────────────────
  if (error) {
    return (
      <div className="rounded-[2rem] border border-rose-500/30 bg-rose-500/10 p-8 text-center">
        <p className="text-rose-300">{error}</p>
        <button
          onClick={() => window.location.reload()}
          className="mt-4 rounded-xl bg-rose-500/20 px-4 py-2 text-sm text-rose-300 transition hover:bg-rose-500/30"
        >
          Réessayer
        </button>
      </div>
    );
  }

  const { profil, photoUrl, kpis, chansons, evenements } = data!;
  const displayName = profil.artistName || profil.username || user?.username || "Artiste";
  const initiale    = displayName[0].toUpperCase();

  return (
    <section className="space-y-8 pb-16">

      {/* ── En-tête personnalisé ─────────────────────────────────────────── */}
      <header className="relative overflow-hidden rounded-[2rem] bg-gradient-to-br from-slate-900 via-slate-900/80 to-orange-950/20 p-8 ring-1 ring-slate-700/50">
        {/* Fond décoratif */}
        <div className="pointer-events-none absolute inset-0 overflow-hidden rounded-[2rem]">
          <div className="absolute -right-16 -top-16 h-64 w-64 rounded-full bg-orange-500/8 blur-3xl" />
          <div className="absolute -bottom-8 -left-8 h-48 w-48 rounded-full bg-orange-600/6 blur-2xl" />
        </div>

        <div className="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
          {/* Profil */}
          <div className="flex items-center gap-5">
            {/* Avatar / photo */}
            <div className="relative h-20 w-20 shrink-0">
              {photoUrl ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={photoUrl}
                  alt={displayName}
                  className="h-full w-full rounded-[1.25rem] object-cover ring-2 ring-orange-500/40"
                />
              ) : (
                <div className="flex h-full w-full items-center justify-center rounded-[1.25rem] bg-gradient-to-br from-orange-500/30 to-orange-600/20 text-3xl font-bold text-orange-300 ring-2 ring-orange-500/30">
                  {initiale}
                </div>
              )}
              {/* Badge vérifié */}
              {profil.verifie && (
                <span className="absolute -bottom-1.5 -right-1.5 flex h-6 w-6 items-center justify-center rounded-full bg-emerald-500 ring-2 ring-slate-900">
                  <svg className="h-3.5 w-3.5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                  </svg>
                </span>
              )}
            </div>

            {/* Nom & bio */}
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.3em] text-orange-400">
                Espace artiste
              </p>
              <h1 className="mt-1 text-3xl font-bold text-white">
                Bonjour, {displayName} 👋
              </h1>
              {profil.bio && (
                <p className="mt-1.5 max-w-xl text-sm text-slate-400 line-clamp-2">
                  {profil.bio}
                </p>
              )}
              {!profil.verifie && (
                <span className="mt-2 inline-flex items-center gap-1.5 rounded-full bg-amber-500/15 px-3 py-1 text-xs font-medium text-amber-300">
                  <svg className="h-3 w-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}><path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" /></svg>
                  Vérification en attente
                </span>
              )}
            </div>
          </div>

          {/* Actions rapides */}
          <div className="flex flex-wrap gap-3">
            <Link
              href="/artist/music/upload"
              className="inline-flex items-center gap-2 rounded-2xl bg-orange-500 px-5 py-2.5 text-sm font-semibold text-white shadow-lg shadow-orange-500/25 transition hover:brightness-110 active:scale-[0.98]"
            >
              <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
              </svg>
              Nouveau titre
            </Link>
            <Link
              href="/artist/evenements"
              className="inline-flex items-center gap-2 rounded-2xl border border-slate-700 bg-slate-900/60 px-5 py-2.5 text-sm font-semibold text-slate-300 transition hover:border-slate-600 hover:text-white"
            >
              <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              + Événement
            </Link>
            <Link
              href="/artist/settings"
              className="inline-flex items-center gap-2 rounded-2xl border border-slate-700 bg-slate-900/60 px-5 py-2.5 text-sm font-semibold text-slate-300 transition hover:border-slate-600 hover:text-white"
            >
              <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" /><path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              Paramètres
            </Link>
          </div>
        </div>
      </header>

      {/* ── KPIs ligne 1 ────────────────────────────────────────────────────── */}
      <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
        <KpiCard label="Écoutes totales"   value={kpis.totalEcoutes.toLocaleString("fr")}    accent="from-orange-500 to-orange-600" icon={<IcEcoutes />} />
        <KpiCard label="Auditeurs uniques" value={kpis.auditeursUniques.toLocaleString("fr")} accent="from-sky-500 to-sky-600"        icon={<IcUsers />}   />
        <KpiCard label="Chansons"          value={kpis.totalChansons.toLocaleString("fr")}    accent="from-violet-500 to-violet-600"  icon={<IcMusic />}   />
        <KpiCard label="Albums"            value={kpis.totalAlbums.toLocaleString("fr")}      accent="from-emerald-500 to-emerald-600" icon={<IcAlbum />}  />
      </div>

      {/* ── KPIs ligne 2 ────────────────────────────────────────────────────── */}
      <div className="grid gap-5 sm:grid-cols-3">
        <KpiCard label="Royalties estimées" value={`${kpis.royaltiesEstimees.toLocaleString("fr")} XAF`} accent="from-amber-500 to-amber-600" icon={<IcMoney />} />
        <KpiCard label="Favoris"            value={kpis.totalFavoris.toLocaleString("fr")}               accent="from-pink-500 to-pink-600"    icon={<IcHeart />} />
        <KpiCard label="Part catalogue"     value={kpis.partCatalogue ?? "—"}                             accent="from-teal-500 to-teal-600"    icon={<IcPie />}   />
      </div>

      {/* ── Titres récents + Événements ──────────────────────────────────────── */}
      <div className="grid gap-6 lg:grid-cols-2">

        {/* Titres les plus écoutés */}
        <div className="rounded-[2rem] bg-slate-900/70 p-6 ring-1 ring-slate-700/50">
          <SectionTitle href="/artist/music">Titres les plus écoutés</SectionTitle>
          {chansons.length === 0 ? (
            <div className="flex flex-col items-center justify-center gap-3 py-10 text-center">
              <div className="flex h-14 w-14 items-center justify-center rounded-full bg-slate-800">
                <IcMusic />
              </div>
              <p className="text-sm text-slate-500">Aucun titre publié pour l&apos;instant.</p>
              <Link href="/artist/music/upload" className="text-xs text-orange-400 hover:text-orange-300">
                Publier mon premier titre →
              </Link>
            </div>
          ) : (
            <ol className="space-y-2">
              {chansons.map((c, idx) => (
                <li
                  key={c.id}
                  className="flex items-center gap-4 rounded-2xl bg-slate-950/60 px-4 py-3 transition hover:bg-slate-800/60"
                >
                  {/* Rang */}
                  <span className={[
                    "flex h-7 w-7 shrink-0 items-center justify-center rounded-xl text-xs font-bold",
                    idx === 0 ? "bg-orange-500/20 text-orange-300"
                    : idx === 1 ? "bg-slate-700/60 text-slate-300"
                    : idx === 2 ? "bg-amber-700/30 text-amber-400"
                    : "bg-slate-800/60 text-slate-500",
                  ].join(" ")}>
                    {idx + 1}
                  </span>
                  {/* Infos */}
                  <div className="flex-1 min-w-0">
                    <p className="truncate text-sm font-medium text-white">{c.titre}</p>
                    <p className="truncate text-xs text-slate-500">
                      {c.genre ?? "—"}
                      {c.albumTitre ? ` · ${c.albumTitre}` : ""}
                      {c.duree ? ` · ${fmtDuration(c.duree)}` : ""}
                    </p>
                  </div>
                  {/* Écoutes */}
                  <div className="text-right shrink-0">
                    <p className="text-sm font-semibold text-white">{c.nbEcoutes.toLocaleString("fr")}</p>
                    <p className="text-[10px] text-slate-500">écoutes</p>
                  </div>
                </li>
              ))}
            </ol>
          )}
        </div>

        {/* Événements à venir */}
        <div className="rounded-[2rem] bg-slate-900/70 p-6 ring-1 ring-slate-700/50">
          <SectionTitle href="/artist/evenements">Événements à venir</SectionTitle>
          {evenements.length === 0 ? (
            <div className="flex flex-col items-center justify-center gap-3 py-10 text-center">
              <div className="flex h-14 w-14 items-center justify-center rounded-full bg-slate-800">
                <svg className="h-6 w-6 text-slate-500" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
              <p className="text-sm text-slate-500">Aucun événement programmé.</p>
              <Link href="/artist/evenements" className="text-xs text-orange-400 hover:text-orange-300">
                Créer un événement →
              </Link>
            </div>
          ) : (
            <div className="space-y-3">
              {evenements.map((e) => {
                const d   = new Date(e.dateEvenement);
                const { label, urgency } = countdown(e.dateEvenement);
                const urgencyClass =
                  urgency === "high"   ? "bg-rose-500/15 text-rose-300"
                  : urgency === "medium" ? "bg-amber-500/15 text-amber-300"
                  : "bg-slate-700/60 text-slate-400";
                return (
                  <div
                    key={e.idEvenement}
                    className="flex items-center gap-4 rounded-2xl bg-slate-950/60 px-4 py-3 transition hover:bg-slate-800/60"
                  >
                    {/* Calendrier mini */}
                    <div className="flex h-12 w-12 shrink-0 flex-col items-center justify-center rounded-xl bg-orange-500/15 text-orange-300">
                      <span className="text-sm font-bold leading-none">
                        {d.toLocaleDateString("fr-FR", { day: "2-digit" })}
                      </span>
                      <span className="text-[10px] uppercase">
                        {d.toLocaleDateString("fr-FR", { month: "short" })}
                      </span>
                    </div>
                    {/* Détails */}
                    <div className="flex-1 min-w-0">
                      <p className="truncate text-sm font-semibold text-white">{e.nameConcert}</p>
                      <p className="truncate text-xs text-slate-500">{e.lieu}</p>
                      {e.prixTicket > 0 && (
                        <p className="text-xs text-slate-600">{e.prixTicket.toLocaleString("fr")} XAF / billet</p>
                      )}
                    </div>
                    {/* Countdown */}
                    <span className={`shrink-0 rounded-full px-2.5 py-1 text-[11px] font-semibold ${urgencyClass}`}>
                      {label}
                    </span>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* ── Accès rapide ────────────────────────────────────────────────────── */}
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {[
          { href: "/artist/music",      label: "Catalogue",    desc: "Gérer vos titres",        color: "orange" },
          { href: "/artist/analytics",  label: "Statistiques", desc: "Analyser vos performances", color: "sky"   },
          { href: "/artist/evenements", label: "Événements",   desc: "Concerts & shows",         color: "violet" },
          { href: "/artist/settings",   label: "Paramètres",   desc: "Bio, photo, compte",       color: "emerald" },
        ].map(({ href, label, desc, color }) => (
          <Link
            key={href}
            href={href}
            className="group flex items-center justify-between rounded-[1.5rem] border border-slate-800/60 bg-slate-900/50 px-5 py-4 transition hover:border-slate-700 hover:bg-slate-800/60"
          >
            <div>
              <p className="text-sm font-semibold text-white">{label}</p>
              <p className="text-xs text-slate-500">{desc}</p>
            </div>
            <svg
              className={`h-5 w-5 text-${color}-400 transition group-hover:translate-x-0.5`}
              fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </Link>
        ))}
      </div>

    </section>
  );
}
