"use client";

import { useEffect, useState } from "react";
import {
  getArtistesEnAttente,
  verifierArtiste,
  updateStatutUtilisateur,
  getUtilisateurs,
} from "@/services/adminService";
import type { ArtisteResponse, UtilisateurAdmin } from "@/types/api";

// ─── Badge vérifié ────────────────────────────────────────────────────────────

function VerifBadge({ ok }: { ok: boolean }) {
  return ok ? (
    <span className="inline-flex items-center gap-1 rounded-full bg-emerald-500/15 px-2.5 py-0.5 text-[11px] font-medium text-emerald-300 ring-1 ring-emerald-500/30">
      <svg className="h-3 w-3" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
      </svg>
      Vérifié
    </span>
  ) : (
    <span className="rounded-full bg-amber-500/15 px-2.5 py-0.5 text-[11px] font-medium text-amber-300 ring-1 ring-amber-500/30">
      En attente
    </span>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

export default function AdminArtistesPage() {
  const [enAttente, setEnAttente]   = useState<ArtisteResponse[]>([]);
  const [artistes, setArtistes]     = useState<UtilisateurAdmin[]>([]);
  const [loading, setLoading]       = useState(true);
  const [error, setError]           = useState<string | null>(null);
  const [verifying, setVerifying]   = useState<number | null>(null);
  const [updatingId, setUpdatingId] = useState<number | null>(null);
  const [search, setSearch]         = useState("");
  const [tab, setTab]               = useState<"tous" | "attente">("attente");

  const load = async () => {
    setLoading(true); setError(null);
    try {
      const [attente, tous] = await Promise.all([
        getArtistesEnAttente(),
        getUtilisateurs(),
      ]);
      setEnAttente(attente);
      setArtistes(tous.filter((u) => u.role.toLowerCase().includes("artiste")));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Impossible de charger les artistes.");
    } finally { setLoading(false); }
  };

  useEffect(() => { load(); }, []);

  const handleVerifier = async (id: number) => {
    setVerifying(id);
    try {
      await verifierArtiste(id);
      setEnAttente((p) => p.filter((a) => a.id !== id));
      setArtistes((p) => p.map((a) => a.id === id ? { ...a } : a));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de la vérification.");
    } finally { setVerifying(null); }
  };

  const handleStatut = async (id: number, statut: string) => {
    setUpdatingId(id);
    try {
      await updateStatutUtilisateur(id, statut);
      setArtistes((p) => p.map((a) => a.id === id ? { ...a, statut: statut as "ACTIF" | "INACTIF" | "SUPPRIME" } : a));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de la mise à jour.");
    } finally { setUpdatingId(null); }
  };

  const filteredArtistes = artistes.filter((a) =>
    a.username.toLowerCase().includes(search.toLowerCase()) ||
    a.email.toLowerCase().includes(search.toLowerCase()),
  );

  return (
    <section className="space-y-6 pb-12">
      {/* En-tête */}
      <header className="rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
        <p className="text-xs font-semibold uppercase tracking-[0.3em] text-blue-400">Administration</p>
        <h1 className="mt-1.5 text-3xl font-bold text-white">Artistes</h1>
      </header>

      {/* KPIs */}
      <div className="grid gap-4 sm:grid-cols-3">
        <div className="rounded-2xl bg-slate-900/70 px-5 py-4 ring-1 ring-slate-700/50">
          <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">Total artistes</p>
          <p className="mt-2 text-2xl font-bold text-white">{artistes.length}</p>
        </div>
        <div className="rounded-2xl bg-slate-900/70 px-5 py-4 ring-1 ring-amber-500/20">
          <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">En attente de vérification</p>
          <p className="mt-2 text-2xl font-bold text-amber-400">{enAttente.length}</p>
        </div>
        <div className="rounded-2xl bg-slate-900/70 px-5 py-4 ring-1 ring-emerald-500/20">
          <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">Vérifiés</p>
          <p className="mt-2 text-2xl font-bold text-emerald-400">{artistes.length - enAttente.length}</p>
        </div>
      </div>

      {/* Onglets */}
      <div className="flex gap-2">
        {([["attente", "En attente", enAttente.length], ["tous", "Tous les artistes", artistes.length]] as const).map(([v, l, count]) => (
          <button key={v} onClick={() => setTab(v)}
            className={["rounded-2xl px-4 py-2.5 text-sm font-medium transition flex items-center gap-2",
              tab === v ? "bg-blue-600/15 text-blue-300 ring-1 ring-blue-500/30" : "text-slate-400 hover:bg-slate-800 hover:text-white"].join(" ")}>
            {l}
            <span className={["rounded-full px-2 py-0.5 text-[11px] font-bold",
              tab === v ? "bg-blue-500/30 text-blue-200" : "bg-slate-700/60 text-slate-400"].join(" ")}>
              {count}
            </span>
          </button>
        ))}
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-16">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-blue-500 border-t-transparent" />
        </div>
      ) : error ? (
        <div className="rounded-2xl bg-rose-500/10 px-4 py-3 text-sm text-rose-300">{error}</div>
      ) : tab === "attente" ? (
        /* ── Artistes en attente ── */
        enAttente.length === 0 ? (
          <div className="rounded-[2rem] bg-slate-900/50 p-12 text-center text-slate-500">
            Aucun artiste en attente de vérification.
          </div>
        ) : (
          <div className="space-y-4">
            {enAttente.map((a) => (
              <article key={a.id}
                className="flex flex-col gap-4 rounded-[2rem] bg-slate-900/70 p-6 ring-1 ring-amber-500/20 sm:flex-row sm:items-center sm:justify-between">
                <div className="flex items-center gap-4">
                  <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-orange-500/15 text-lg font-bold text-orange-400">
                    {a.username[0].toUpperCase()}
                  </div>
                  <div>
                    <div className="flex items-center gap-2 flex-wrap">
                      <p className="font-semibold text-white">{a.artistName ?? a.username}</p>
                      <VerifBadge ok={a.verifie} />
                    </div>
                    <p className="text-sm text-slate-400">{a.email}</p>
                  </div>
                </div>
                <button
                  onClick={() => handleVerifier(a.id)}
                  disabled={verifying === a.id}
                  className="shrink-0 rounded-2xl bg-emerald-600/80 px-5 py-2.5 text-sm font-semibold text-white hover:brightness-110 transition disabled:opacity-60">
                  {verifying === a.id ? "Vérification…" : "Valider le compte"}
                </button>
              </article>
            ))}
          </div>
        )
      ) : (
        /* ── Tous les artistes ── */
        <>
          <div className="relative">
            <svg className="absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-500" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 105 11a6 6 0 0012 0z" />
            </svg>
            <input value={search} onChange={(e) => setSearch(e.target.value)} type="search"
              placeholder="Rechercher un artiste…"
              className="w-full rounded-2xl border border-slate-700/80 bg-slate-900/60 py-3 pl-11 pr-4 text-sm text-white placeholder-slate-500 outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20" />
          </div>
          <div className="overflow-hidden rounded-[2rem] ring-1 ring-slate-700/50">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-slate-800 bg-slate-900/80 text-left text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">
                  <th className="px-5 py-4">Artiste</th>
                  <th className="hidden px-5 py-4 sm:table-cell">Statut compte</th>
                  <th className="px-5 py-4">Vérification</th>
                  <th className="px-5 py-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800/60 bg-slate-900/40">
                {filteredArtistes.length === 0 ? (
                  <tr><td colSpan={4} className="px-5 py-10 text-center text-slate-500">Aucun résultat.</td></tr>
                ) : filteredArtistes.map((a) => (
                  <tr key={a.id} className="transition hover:bg-slate-800/30">
                    <td className="px-5 py-4">
                      <p className="font-medium text-white">{a.artistName ?? a.username}</p>
                      <p className="text-xs text-slate-500">{a.email}</p>
                    </td>
                    <td className="hidden px-5 py-4 sm:table-cell">
                      <span className={["rounded-full px-2.5 py-0.5 text-[11px] font-medium",
                        a.statut === "ACTIF"    ? "bg-emerald-500/15 text-emerald-300" :
                        a.statut === "INACTIF"  ? "bg-amber-500/15 text-amber-300"    :
                        "bg-rose-500/15 text-rose-300"].join(" ")}>
                        {a.statut}
                      </span>
                    </td>
                    <td className="px-5 py-4">
                      <VerifBadge ok={enAttente.every((e) => e.id !== a.id)} />
                    </td>
                    <td className="px-5 py-4 text-right">
                      <div className="flex items-center justify-end gap-2">
                        {a.statut !== "ACTIF" && (
                          <button onClick={() => handleStatut(a.id, "ACTIF")} disabled={updatingId === a.id}
                            className="rounded-xl border border-emerald-500/30 px-3 py-1.5 text-[11px] font-medium text-emerald-400 hover:bg-emerald-500/10 transition disabled:opacity-40">
                            Activer
                          </button>
                        )}
                        {a.statut === "ACTIF" && (
                          <button onClick={() => handleStatut(a.id, "INACTIF")} disabled={updatingId === a.id}
                            className="rounded-xl border border-amber-500/30 px-3 py-1.5 text-[11px] font-medium text-amber-400 hover:bg-amber-500/10 transition disabled:opacity-40">
                            Désactiver
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </section>
  );
}
