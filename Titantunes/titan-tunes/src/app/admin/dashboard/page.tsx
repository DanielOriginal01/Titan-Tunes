"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useAuth } from "@/hooks/useAuth";
import {
  getAdminMetriques,
  getAdminFinances,
  getArtistesEnAttente,
  verifierArtiste,
} from "@/services/adminService";
import type { AdminMetriques, AdminFinances, ArtisteResponse } from "@/types/api";

// ─── Icônes ───────────────────────────────────────────────────────────────────

const IcUsers    = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" /></svg>;
const IcMic      = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9 19V6l12-3v13M9 19c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zm12-3c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zM9 10l12-3" /></svg>;
const IcHeadset  = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M3 18v-6a9 9 0 0118 0v6" /><path strokeLinecap="round" strokeLinejoin="round" d="M21 19a2 2 0 01-2 2h-1a2 2 0 01-2-2v-3a2 2 0 012-2h3zM3 19a2 2 0 002 2h1a2 2 0 002-2v-3a2 2 0 00-2-2H3z" /></svg>;
const IcShield   = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>;
const IcRevenu   = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>;
const IcTx       = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" /></svg>;
const IcRoyalty  = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" /></svg>;
const IcNet      = () => <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" /></svg>;

// ─── Composants atomiques ─────────────────────────────────────────────────────

function StatCard({ title, value, sub, accent, icon }: {
  title: string; value: string; sub: string; accent: string; icon: React.ReactNode;
}) {
  return (
    <article className="group relative overflow-hidden rounded-[2rem] bg-slate-900/70 p-6 ring-1 ring-slate-700/50 transition hover:ring-slate-600/60">
      <div className={`absolute -right-4 -top-4 h-24 w-24 rounded-full bg-gradient-to-br ${accent} opacity-10 blur-2xl transition group-hover:opacity-20`} />
      <div className={`mb-4 flex h-10 w-10 items-center justify-center rounded-2xl bg-gradient-to-br ${accent} text-white shadow-lg`}>
        {icon}
      </div>
      <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">{title}</p>
      <p className="mt-2 text-3xl font-bold text-white">{value}</p>
      <p className="mt-1.5 text-xs text-slate-500">{sub}</p>
    </article>
  );
}

function SectionHeading({ children, badge }: { children: React.ReactNode; badge?: number }) {
  return (
    <div className="mb-4 flex items-center gap-3">
      <h2 className="text-xs font-semibold uppercase tracking-[0.3em] text-slate-500">{children}</h2>
      {badge != null && badge > 0 && (
        <span className="rounded-full bg-amber-500/20 px-2 py-0.5 text-xs font-semibold text-amber-300">
          {badge}
        </span>
      )}
    </div>
  );
}

const DEFAULT_METRIQUES: AdminMetriques = {
  totalUtilisateurs: 0,
  totalArtistes: 0,
  totalAuditeurs: 0,
  totalAdmins: 1,
};

const DEFAULT_FINANCES: AdminFinances = {
  totalRevenus: 0,
  totalTransactions: 0,
  royaltiesArtistes: 0,
  revenusNets: 0,
};

// ─── Page principale ──────────────────────────────────────────────────────────

export default function AdminDashboardPage() {
  const { user } = useAuth();

  const [metriques,  setMetriques]  = useState<AdminMetriques>(DEFAULT_METRIQUES);
  const [finances,   setFinances]   = useState<AdminFinances>(DEFAULT_FINANCES);
  const [enAttente,  setEnAttente]  = useState<ArtisteResponse[]>([]);
  const [loading,    setLoading]    = useState(true);
  const [error,      setError]      = useState<string | null>(null);
  const [verifying,  setVerifying]  = useState<number | null>(null);
  // Pour le feedback visuel après validation
  const [validated,  setValidated]  = useState<Set<number>>(new Set());

  useEffect(() => {
    let cancelled = false;
    (async () => {
      setLoading(true);
      setError(null);
      try {
        const [mRes, fRes, attRes] = await Promise.allSettled([
          getAdminMetriques(),
          getAdminFinances(),
          getArtistesEnAttente(),
        ]);

        const m = mRes.status === "fulfilled" ? mRes.value : DEFAULT_METRIQUES;
        const f = fRes.status === "fulfilled" ? fRes.value : DEFAULT_FINANCES;
        const att = attRes.status === "fulfilled" ? attRes.value : [];

        if (!cancelled) {
          setMetriques(m || DEFAULT_METRIQUES);
          setFinances(f || DEFAULT_FINANCES);
          setEnAttente(Array.isArray(att) ? att : []);
        }
      } catch (err) {
        if (!cancelled) setError(err instanceof Error ? err.message : "Impossible de charger le dashboard.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();
    return () => { cancelled = true; };
  }, []);

  const handleVerifier = async (id: number) => {
    setVerifying(id);
    try {
      await verifierArtiste(id);
      setValidated((prev) => new Set(prev).add(id));
      // Retirer de la liste après un court délai (feedback visuel)
      setTimeout(() => {
        setEnAttente((prev) => prev.filter((a) => a.id !== id));
        setValidated((prev) => { const s = new Set(prev); s.delete(id); return s; });
      }, 800);
    } catch {
      // Silencieux — l'artiste reste dans la liste, l'admin peut réessayer
    } finally {
      setVerifying(null);
    }
  };

  // ── Spinner ────────────────────────────────────────────────────────────────
  if (loading) {
    return (
      <div className="flex min-h-[60vh] items-center justify-center">
        <div className="h-10 w-10 animate-spin rounded-full border-4 border-blue-500 border-t-transparent" />
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

  const m = metriques || DEFAULT_METRIQUES;
  const f = finances || DEFAULT_FINANCES;


  return (
    <section className="space-y-8 pb-16">

      {/* ── En-tête admin ────────────────────────────────────────────────────── */}
      <header className="relative overflow-hidden rounded-[2rem] bg-gradient-to-br from-slate-900 via-slate-900/80 to-blue-950/20 p-8 ring-1 ring-slate-700/50">
        <div className="pointer-events-none absolute inset-0 overflow-hidden rounded-[2rem]">
          <div className="absolute -right-16 -top-16 h-64 w-64 rounded-full bg-blue-500/8 blur-3xl" />
          <div className="absolute -bottom-8 -left-8 h-48 w-48 rounded-full bg-blue-600/6 blur-2xl" />
        </div>

        <div className="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <div className="flex items-center gap-2.5">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-blue-600/20">
                <IcShield />
              </div>
              <p className="text-xs font-semibold uppercase tracking-[0.3em] text-blue-400">
                Administration
              </p>
            </div>
            <h1 className="mt-3 text-4xl font-bold text-white">
              {user?.username ? ` ${user.username}` : ""} 
            </h1>
            <p className="mt-1.5 text-sm text-slate-400">
              Vue d&apos;ensemble de la plateforme Titan Tunes.
            </p>
          </div>

          {/* Actions rapides admin */}
          <div className="flex flex-wrap gap-3">
            <Link
              href="/admin/utilisateurs"
              className="inline-flex items-center gap-2 rounded-2xl bg-blue-600 px-5 py-2.5 text-sm font-semibold text-white shadow-lg shadow-blue-600/20 transition hover:brightness-110 active:scale-[0.98]"
            >
              <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" /></svg>
              Nouvel utilisateur
            </Link>
            <Link
              href="/admin/artistes"
              className="inline-flex items-center gap-2 rounded-2xl border border-slate-700 bg-slate-900/60 px-5 py-2.5 text-sm font-semibold text-slate-300 transition hover:border-slate-600 hover:text-white"
            >
              <IcMic />
              Gérer artistes
            </Link>
            <Link
              href="/admin/notifications"
              className="inline-flex items-center gap-2 rounded-2xl border border-slate-700 bg-slate-900/60 px-5 py-2.5 text-sm font-semibold text-slate-300 transition hover:border-slate-600 hover:text-white"
            >
              <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" /></svg>
              Notifications
            </Link>
          </div>
        </div>
      </header>

      {/* ── Métriques utilisateurs ───────────────────────────────────────────── */}
      <div>
        <SectionHeading>Utilisateurs</SectionHeading>
        <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
          <StatCard title="Total"     value={m.totalUtilisateurs.toLocaleString("fr")} sub="Comptes enregistrés"  accent="from-blue-500 to-blue-600"     icon={<IcUsers />}   />
          <StatCard title="Artistes"  value={m.totalArtistes.toLocaleString("fr")}     sub="Comptes artiste"      accent="from-orange-500 to-orange-600" icon={<IcMic />}     />
          <StatCard title="Auditeurs" value={m.totalAuditeurs.toLocaleString("fr")}    sub="Comptes auditeur"     accent="from-violet-500 to-violet-600" icon={<IcHeadset />} />
          <StatCard title="Admins"    value={m.totalAdmins.toLocaleString("fr")}       sub="Comptes admin"        accent="from-slate-500 to-slate-600"   icon={<IcShield />}  />
        </div>
      </div>

      {/* ── Finances ─────────────────────────────────────────────────────────── */}
      <div>
        <SectionHeading>Finances</SectionHeading>
        <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
          <StatCard title="Revenus"      value={`${f.totalRevenus.toLocaleString("fr")} XAF`}      sub="Flux cumulés"      accent="from-emerald-500 to-emerald-600" icon={<IcRevenu />}  />
          <StatCard title="Transactions" value={f.totalTransactions.toLocaleString("fr")}          sub="Paiements traités"  accent="from-teal-500 to-teal-600"       icon={<IcTx />}      />
          <StatCard title="Royalties"    value={`${f.royaltiesArtistes.toLocaleString("fr")} XAF`} sub="70 % des revenus"  accent="from-orange-400 to-orange-500"   icon={<IcRoyalty />} />
          <StatCard title="Revenus nets" value={`${f.revenusNets.toLocaleString("fr")} XAF`}       sub="Après royalties"   accent="from-blue-400 to-blue-500"       icon={<IcNet />}     />
        </div>
      </div>

      {/* ── Artistes en attente ──────────────────────────────────────────────── */}
      <div>
        <div className="mb-4 flex items-center justify-between">
          <SectionHeading badge={enAttente.length}>
            Artistes en attente de vérification
          </SectionHeading>
          <Link href="/admin/artistes" className="text-xs text-blue-400 transition hover:text-blue-300">
            Voir tous →
          </Link>
        </div>

        {enAttente.length === 0 ? (
          <div className="flex items-center justify-center gap-3 rounded-[2rem] bg-slate-900/50 p-10 text-center">
            <svg className="h-6 w-6 text-emerald-500" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <p className="text-sm text-slate-400">Aucun artiste en attente. Tout est à jour ✓</p>
          </div>
        ) : (
          <div className="space-y-3">
            {enAttente.slice(0, 5).map((a) => {
              const isValidating = verifying === a.id;
              const isValidated  = validated.has(a.id);
              return (
                <div
                  key={a.id}
                  className={[
                    "flex items-center justify-between rounded-2xl px-5 py-4 ring-1 transition",
                    isValidated
                      ? "bg-emerald-900/20 ring-emerald-500/30"
                      : "bg-slate-900/70 ring-amber-500/20 hover:ring-amber-500/35",
                  ].join(" ")}
                >
                  <div className="flex items-center gap-4">
                    {/* Avatar initial */}
                    <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-orange-500/15 text-base font-bold text-orange-400">
                      {(a.artistName ?? a.username)[0].toUpperCase()}
                    </div>
                    <div>
                      <p className="font-semibold text-white">
                        {a.artistName ?? a.username}
                      </p>
                      <p className="text-xs text-slate-500">{a.email}</p>
                      {a.artistName && a.artistName !== a.username && (
                        <p className="text-xs text-slate-600">@{a.username}</p>
                      )}
                    </div>
                  </div>

                  {/* Action */}
                  {isValidated ? (
                    <span className="flex items-center gap-1.5 rounded-xl bg-emerald-600/20 px-4 py-2 text-xs font-semibold text-emerald-400">
                      <svg className="h-3.5 w-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                      </svg>
                      Validé
                    </span>
                  ) : (
                    <button
                      onClick={() => handleVerifier(a.id)}
                      disabled={isValidating}
                      className="rounded-xl bg-emerald-600/80 px-4 py-2 text-xs font-semibold text-white transition hover:bg-emerald-600 active:scale-[0.97] disabled:cursor-not-allowed disabled:opacity-60"
                    >
                      {isValidating ? (
                        <span className="flex items-center gap-1.5">
                          <span className="h-3 w-3 animate-spin rounded-full border-2 border-white border-t-transparent" />
                          Validation…
                        </span>
                      ) : (
                        "Valider"
                      )}
                    </button>
                  )}
                </div>
              );
            })}

            {enAttente.length > 5 && (
              <Link
                href="/admin/artistes"
                className="flex items-center justify-center rounded-2xl border border-dashed border-slate-700 py-3 text-sm text-slate-500 transition hover:border-slate-600 hover:text-slate-400"
              >
                + {enAttente.length - 5} autres en attente — voir tout
              </Link>
            )}
          </div>
        )}
      </div>

      {/* ── Accès rapide ─────────────────────────────────────────────────────── */}
      <div>
        <SectionHeading>Accès rapide</SectionHeading>
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          {[
            { href: "/admin/utilisateurs",  label: "Utilisateurs",  desc: "Gérer les comptes",       color: "blue"    },
            { href: "/admin/artistes",       label: "Artistes",      desc: "Vérification & profils",  color: "orange"  },
            { href: "/admin/labels",         label: "Labels",        desc: "Gérer les labels",        color: "violet"  },
            { href: "/admin/notifications",  label: "Notifications", desc: "Diffuser des messages",   color: "emerald" },
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
      </div>

      {/* ── Info système ──────────────────────────────────────────────────────── */}
      <div className="rounded-[2rem] bg-slate-900/50 p-6 ring-1 ring-slate-800/60">
        <h2 className="mb-4 text-xs font-semibold uppercase tracking-[0.3em] text-slate-600">
          Système
        </h2>
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          {[
            ["Plateforme",   "Titan Tunes"],
            ["API",          "Spring Boot · /api/v1"],
            ["Auth",         "JWT Bearer"],
            ["Rôles actifs", "ROLE_ARTISTE · ROLE_ADMIN"],
          ].map(([k, v]) => (
            <div
              key={k}
              className="flex items-center justify-between rounded-2xl border border-slate-800/60 bg-slate-950/40 px-4 py-3"
            >
              <span className="text-xs text-slate-500">{k}</span>
              <span className="text-xs font-medium text-slate-300">{v}</span>
            </div>
          ))}
        </div>
      </div>

    </section>
  );
}
