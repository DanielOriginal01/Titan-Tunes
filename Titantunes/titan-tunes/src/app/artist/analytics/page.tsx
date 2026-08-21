"use client";

import { useEffect, useState } from "react";
import { useAuth } from "@/hooks/useAuth";
import { getArtisteDashboard, getAllChansons } from "@/services/artist";
import type { ArtisteDashboard, ChansonResponse } from "@/types/api";

export default function ArtistAnalyticsPage() {
  const { user } = useAuth();
  const [dashboard, setDashboard] = useState<ArtisteDashboard | null>(null);
  const [chansons, setChansons]   = useState<ChansonResponse[]>([]);
  const [loading, setLoading]     = useState(true);
  const [error, setError]         = useState<string | null>(null);

  useEffect(() => {
    if (!user?.id) return;
    async function load() {
      setLoading(true);
      setError(null);
      try {
        const [dash, all] = await Promise.all([
          getArtisteDashboard(user!.id),
          getAllChansons(),
        ]);
        setDashboard(dash);
        setChansons(all.filter((c) => c.artisteId === user!.id));
      } catch (err) {
        setError(err instanceof Error ? err.message : "Impossible de charger les statistiques.");
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [user?.id]);

  // Top titres par écoutes
  const sortedChansons = [...chansons].sort((a, b) => (b.nbEcoutes || 0) - (a.nbEcoutes || 0));
  const topChansons = sortedChansons.slice(0, 7);
  const maxEcoutes = Math.max(...chansons.map((c) => c.nbEcoutes || 0), 1);

  // Répartition par genre
  const genreStats = chansons.reduce<Record<string, number>>((acc, c) => {
    const g = c.genre || "Afrobeat";
    acc[g] = (acc[g] || 0) + (c.nbEcoutes || 0);
    return acc;
  }, {});

  const totalGenreEcoutes = Object.values(genreStats).reduce((a, b) => a + b, 0) || 1;

  if (loading) {
    return (
      <div className="flex min-h-[60vh] items-center justify-center">
        <div className="h-10 w-10 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
      </div>
    );
  }

  return (
    <section className="space-y-8 pb-16">
      {/* ── En-tête ──────────────────────────────────────────────────────── */}
      <header className="relative overflow-hidden rounded-[2rem] bg-gradient-to-br from-slate-900 via-slate-900/80 to-sky-950/20 p-8 ring-1 ring-slate-700/50">
        <div className="pointer-events-none absolute inset-0 overflow-hidden rounded-[2rem]">
          <div className="absolute -right-16 -top-16 h-64 w-64 rounded-full bg-sky-500/10 blur-3xl" />
          <div className="absolute -bottom-8 -left-8 h-48 w-48 rounded-full bg-orange-500/10 blur-2xl" />
        </div>

        <div className="relative flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.3em] text-sky-400">
              Statistiques & Audience
            </p>
            <h1 className="mt-2 text-3xl font-bold text-white">Performances du Catalogue</h1>
            <p className="mt-1 text-sm text-slate-400">
              Visualisez la portée de vos chansons et la croissance de vos auditeurs.
            </p>
          </div>
        </div>
      </header>

      {error && (
        <div className="rounded-2xl border border-rose-500/30 bg-rose-500/10 p-4 text-sm text-rose-300">
          {error}
        </div>
      )}

      {/* ── KPIs Statistiques ─────────────────────────────────────────────────── */}
      <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Écoutes totales"
          value={(dashboard?.totalEcoutes ?? 0).toLocaleString("fr")}
          sub="Lectures cumulées"
          accent="from-orange-500 to-orange-600"
          icon={
            <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 19V6l12-3v13M9 19c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zm12-3c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zM9 10l12-3" />
            </svg>
          }
        />

        <StatCard
          label="Auditeurs Uniques"
          value={(dashboard?.auditeursUniques ?? 0).toLocaleString("fr")}
          sub="Utilisateurs distincts"
          accent="from-sky-500 to-sky-600"
          icon={
            <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
          }
        />

        <StatCard
          label="Favoris / Likes"
          value={(dashboard?.totalFavoris ?? 0).toLocaleString("fr")}
          sub="Morceaux sauvegardés"
          accent="from-pink-500 to-pink-600"
          icon={
            <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
            </svg>
          }
        />

        <StatCard
          label="Part Catalogue"
          value={dashboard?.partCatalogue ?? "—"}
          sub="Impact global plateforme"
          accent="from-emerald-500 to-emerald-600"
          icon={
            <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z" />
              <path strokeLinecap="round" strokeLinejoin="round" d="M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z" />
            </svg>
          }
        />
      </div>

      {/* ── Graphiques & Répartitions ───────────────────────────────────────── */}
      <div className="grid gap-6 lg:grid-cols-[1.3fr_0.7fr]">
        {/* Top Titres avec barres de progression */}
        <div className="rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
          <div className="mb-6 flex items-center justify-between">
            <div>
              <h2 className="text-lg font-semibold text-white">Classement des écoutes</h2>
              <p className="text-xs text-slate-500">Distribution des lectures par morceau</p>
            </div>
            <span className="text-xs text-orange-400 font-semibold">{chansons.length} titres au catalogue</span>
          </div>

          {topChansons.length === 0 ? (
            <p className="py-12 text-center text-sm text-slate-500">Aucun titre disponible pour l'analyse.</p>
          ) : (
            <div className="space-y-4">
              {topChansons.map((c, i) => {
                const percent = Math.round(((c.nbEcoutes || 0) / maxEcoutes) * 100);
                return (
                  <div key={c.id} className="space-y-1.5">
                    <div className="flex items-center justify-between text-xs">
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-slate-500">#{i + 1}</span>
                        <span className="font-semibold text-white truncate max-w-xs">{c.titre}</span>
                        <span className="text-slate-500">· {c.genre || "Afrobeat"}</span>
                      </div>
                      <span className="font-semibold text-slate-300">
                        {(c.nbEcoutes || 0).toLocaleString("fr")} écoutes
                      </span>
                    </div>
                    <div className="h-2 w-full overflow-hidden rounded-full bg-slate-800">
                      <div
                        className="h-full rounded-full bg-gradient-to-r from-orange-500 to-amber-400 transition-all duration-500"
                        style={{ width: `${percent}%` }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Répartition par genre */}
        <div className="rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
          <h2 className="text-lg font-semibold text-white">Genres Musicaux</h2>
          <p className="text-xs text-slate-500 mb-6">Répartition de votre audience</p>

          {Object.keys(genreStats).length === 0 ? (
            <p className="py-12 text-center text-sm text-slate-500">Aucune donnée de genre.</p>
          ) : (
            <div className="space-y-4">
              {Object.entries(genreStats).map(([genre, ecoutes]) => {
                const percent = Math.round((ecoutes / totalGenreEcoutes) * 100);
                return (
                  <div key={genre} className="space-y-1.5">
                    <div className="flex items-center justify-between text-xs">
                      <span className="font-medium text-slate-300">{genre}</span>
                      <span className="font-bold text-sky-400">{percent}% ({ecoutes.toLocaleString("fr")})</span>
                    </div>
                    <div className="h-2 w-full overflow-hidden rounded-full bg-slate-800">
                      <div
                        className="h-full rounded-full bg-gradient-to-r from-sky-500 to-blue-600 transition-all duration-500"
                        style={{ width: `${percent}%` }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          )}

          <div className="mt-8 rounded-2xl border border-slate-800 bg-slate-950/40 p-4">
            <p className="text-xs text-slate-400">
              💡 <strong className="text-white">Conseil Titan Tunes :</strong> Les titres publiés le vendredi après-midi enregistrent en moyenne 35% d'écoutes supplémentaires le week-end.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}

function StatCard({
  label,
  value,
  sub,
  accent,
  icon,
}: {
  label: string;
  value: string;
  sub: string;
  accent: string;
  icon: React.ReactNode;
}) {
  return (
    <article className="group relative overflow-hidden rounded-[2rem] bg-slate-900/70 p-6 ring-1 ring-slate-700/50 transition hover:ring-slate-600/60">
      <div className={`absolute -right-4 -top-4 h-24 w-24 rounded-full bg-gradient-to-br ${accent} opacity-10 blur-2xl transition group-hover:opacity-20`} />
      <div className={`mb-4 flex h-10 w-10 items-center justify-center rounded-2xl bg-gradient-to-br ${accent} text-white shadow-lg`}>
        {icon}
      </div>
      <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">{label}</p>
      <p className="mt-2 text-3xl font-bold text-white">{value}</p>
      <p className="mt-1 text-xs text-slate-500">{sub}</p>
    </article>
  );
}
