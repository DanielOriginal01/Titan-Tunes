"use client";

import { useEffect, useState } from "react";
import { useAuth } from "@/hooks/useAuth";
import {
  getArtisteDashboard,
  getReversementsByArtiste,
  getTotalReversements,
  calculerReversements,
} from "@/services/artist";
import type { ArtisteDashboard, ReversementResponse, ReversementTotalData } from "@/types/api";

export default function ArtistPayoutsPage() {
  const { user } = useAuth();
  const [dashboard, setDashboard]       = useState<ArtisteDashboard | null>(null);
  const [reversements, setReversements] = useState<ReversementResponse[]>([]);
  const [totals, setTotals]             = useState<ReversementTotalData | null>(null);
  const [loading, setLoading]           = useState(true);
  const [calculating, setCalculating]   = useState(false);
  const [withdrawing, setWithdrawing]   = useState(false);
  const [error, setError]               = useState<string | null>(null);
  const [success, setSuccess]           = useState<string | null>(null);

  // Formulaire de retrait
  const [showWithdraw, setShowWithdraw] = useState(false);
  const [modePaiement, setModePaiement] = useState<"FLOOZ" | "TMONEY" | "WAVE">("FLOOZ");
  const [telephone, setTelephone]       = useState("");
  const [montantRetrait, setMontant]    = useState("");

  const load = async () => {
    if (!user?.id) return;
    setLoading(true);
    setError(null);
    try {
      const [dash, revPage, tot] = await Promise.all([
        getArtisteDashboard(user.id),
        getReversementsByArtiste(user.id, 0, 20),
        getTotalReversements(user.id).catch(() => ({ totalVerse: 0 })),
      ]);
      setDashboard(dash);
      setReversements(revPage.content || []);
      setTotals(tot);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Impossible de charger les données financières.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, [user?.id]);

  const handleCalculer = async () => {
    if (!user?.id) return;
    setCalculating(true);
    setError(null);
    setSuccess(null);
    try {
      const result = await calculerReversements(user.id);
      setSuccess(`Calcul effectué : ${result.montant?.toLocaleString("fr") || "0"} XAF calculés pour la période.`);
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors du calcul des royalties.");
    } finally {
      setCalculating(false);
    }
  };

  const handleWithdraw = async (e: React.FormEvent) => {
    e.preventDefault();
    setWithdrawing(true);
    setError(null);
    setSuccess(null);
    try {
      // Simulation Mobile Money payout request
      await new Promise((resolve) => setTimeout(resolve, 1200));
      setSuccess(`Demande de retrait de ${Number(montantRetrait).toLocaleString("fr")} XAF vers ${modePaiement} (${telephone}) initiée avec succès.`);
      setShowWithdraw(false);
      setMontant("");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Échec de la demande de retrait.");
    } finally {
      setWithdrawing(false);
    }
  };

  if (loading) {
    return (
      <div className="flex min-h-[60vh] items-center justify-center">
        <div className="h-10 w-10 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
      </div>
    );
  }

  const royaltiesEstimees = dashboard?.royaltiesEstimees ?? 0;
  const totalVerse = Number(totals?.totalVerse ?? totals?.total ?? 0);

  return (
    <section className="space-y-8 pb-16">
      {/* ── En-tête ──────────────────────────────────────────────────────── */}
      <header className="relative overflow-hidden rounded-[2rem] bg-gradient-to-br from-slate-900 via-slate-900/90 to-amber-950/30 p-8 ring-1 ring-slate-700/50">
        <div className="pointer-events-none absolute inset-0 overflow-hidden rounded-[2rem]">
          <div className="absolute -right-16 -top-16 h-64 w-64 rounded-full bg-amber-500/10 blur-3xl" />
          <div className="absolute -bottom-8 -left-8 h-48 w-48 rounded-full bg-orange-600/10 blur-2xl" />
        </div>

        <div className="relative flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
          <div>
            <div className="flex items-center gap-2">
              <span className="flex h-8 w-8 items-center justify-center rounded-xl bg-amber-500/20 text-amber-400">
                <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </span>
              <p className="text-xs font-semibold uppercase tracking-[0.3em] text-amber-400">
                Monétisation & Reversements
              </p>
            </div>
            <h1 className="mt-2 text-3xl font-bold text-white">Royalties & Revenus</h1>
            <p className="mt-1 text-sm text-slate-400">
              Suivi transparent de vos gains (70% des revenus d'écoutes) et retraits Mobile Money.
            </p>
          </div>

          <div className="flex flex-wrap gap-3">
            <button
              onClick={handleCalculer}
              disabled={calculating}
              className="inline-flex items-center gap-2 rounded-2xl border border-slate-700 bg-slate-900/80 px-5 py-2.5 text-sm font-semibold text-slate-200 transition hover:border-slate-600 hover:text-white disabled:opacity-50"
            >
              {calculating ? (
                <>
                  <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
                  Calcul en cours…
                </>
              ) : (
                <>
                  <svg className="h-4 w-4 text-amber-400" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                  </svg>
                  Recalculer mes gains
                </>
              )}
            </button>
            <button
              onClick={() => setShowWithdraw(true)}
              className="inline-flex items-center gap-2 rounded-2xl bg-gradient-to-r from-amber-500 to-orange-500 px-5 py-2.5 text-sm font-semibold text-white shadow-lg shadow-orange-500/20 transition hover:brightness-110 active:scale-[0.98]"
            >
              <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              Demander un retrait
            </button>
          </div>
        </div>
      </header>

      {/* Alertes feedback */}
      {(error || success) && (
        <div
          className={[
            "flex items-start gap-3 rounded-2xl p-4 text-sm",
            error ? "border border-rose-500/30 bg-rose-500/10 text-rose-300" : "border border-emerald-500/30 bg-emerald-500/10 text-emerald-300",
          ].join(" ")}
        >
          {error ? (
            <svg className="h-5 w-5 shrink-0 text-rose-400" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
          ) : (
            <svg className="h-5 w-5 shrink-0 text-emerald-400" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
            </svg>
          )}
          <p>{error ?? success}</p>
        </div>
      )}

      {/* ── KPIs Financiers ─────────────────────────────────────────────────── */}
      <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
        <div className="rounded-[2rem] bg-slate-900/70 p-6 ring-1 ring-amber-500/20">
          <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400">Royalties Disponibles</p>
          <p className="mt-2 text-3xl font-bold text-amber-400">{royaltiesEstimees.toLocaleString("fr")} <span className="text-lg font-medium text-slate-300">XAF</span></p>
          <p className="mt-1 text-xs text-slate-500">Estimées selon vos écoutes</p>
        </div>

        <div className="rounded-[2rem] bg-slate-900/70 p-6 ring-1 ring-slate-700/50">
          <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400">Total Versé</p>
          <p className="mt-2 text-3xl font-bold text-emerald-400">{totalVerse.toLocaleString("fr")} <span className="text-lg font-medium text-slate-300">XAF</span></p>
          <p className="mt-1 text-xs text-slate-500">Reversements payés à ce jour</p>
        </div>

        <div className="rounded-[2rem] bg-slate-900/70 p-6 ring-1 ring-slate-700/50">
          <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400">Taux de Reversement</p>
          <p className="mt-2 text-3xl font-bold text-white">70 %</p>
          <p className="mt-1 text-xs text-slate-500">Part reversée directement à l'artiste</p>
        </div>

        <div className="rounded-[2rem] bg-slate-900/70 p-6 ring-1 ring-slate-700/50">
          <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400">Opérateurs Supportés</p>
          <div className="mt-2 flex items-center gap-2">
            <span className="rounded-lg bg-yellow-500/20 px-2 py-1 text-xs font-bold text-yellow-300">FLOOZ</span>
            <span className="rounded-lg bg-green-500/20 px-2 py-1 text-xs font-bold text-green-300">TMONEY</span>
            <span className="rounded-lg bg-sky-500/20 px-2 py-1 text-xs font-bold text-sky-300">WAVE</span>
          </div>
          <p className="mt-1.5 text-xs text-slate-500">Paiements instantanés</p>
        </div>
      </div>

      {/* ── Modal de retrait Mobile Money ─────────────────────────────────── */}
      {showWithdraw && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 px-4 backdrop-blur-sm">
          <div className="w-full max-w-md rounded-3xl border border-slate-700/70 bg-slate-900 p-7 shadow-2xl">
            <div className="mb-5 flex items-center justify-between">
              <h2 className="text-lg font-semibold text-white">Demande de retrait Mobile Money</h2>
              <button
                onClick={() => setShowWithdraw(false)}
                className="rounded-xl p-1 text-slate-400 hover:bg-slate-800 hover:text-white"
              >
                <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <form onSubmit={handleWithdraw} className="space-y-4">
              <div className="space-y-1.5">
                <label className="text-xs font-medium text-slate-400">Opérateur de paiement *</label>
                <div className="grid grid-cols-3 gap-2">
                  {(["FLOOZ", "TMONEY", "WAVE"] as const).map((mode) => (
                    <button
                      key={mode}
                      type="button"
                      onClick={() => setModePaiement(mode)}
                      className={[
                        "rounded-xl py-2.5 text-xs font-bold transition",
                        modePaiement === mode
                          ? "bg-amber-500 text-slate-950 shadow-lg shadow-amber-500/30"
                          : "border border-slate-700 bg-slate-950/60 text-slate-400 hover:text-white",
                      ].join(" ")}
                    >
                      {mode}
                    </button>
                  ))}
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-medium text-slate-400">Numéro de téléphone *</label>
                <input
                  required
                  type="tel"
                  value={telephone}
                  onChange={(e) => setTelephone(e.target.value)}
                  placeholder="+22890123456"
                  className="w-full rounded-2xl border border-slate-700/80 bg-slate-950/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20"
                />
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-medium text-slate-400">Montant à retirer (XAF) *</label>
                <input
                  required
                  type="number"
                  min="500"
                  max={royaltiesEstimees > 0 ? royaltiesEstimees : 500000}
                  value={montantRetrait}
                  onChange={(e) => setMontant(e.target.value)}
                  placeholder="ex: 15000"
                  className="w-full rounded-2xl border border-slate-700/80 bg-slate-950/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20"
                />
                <p className="text-[11px] text-slate-500">Minimum : 500 XAF · Disponible : {royaltiesEstimees.toLocaleString("fr")} XAF</p>
              </div>

              <div className="flex gap-3 pt-3">
                <button
                  type="button"
                  onClick={() => setShowWithdraw(false)}
                  className="flex-1 rounded-2xl border border-slate-700 px-4 py-3 text-sm font-semibold text-slate-300 transition hover:text-white"
                >
                  Annuler
                </button>
                <button
                  type="submit"
                  disabled={withdrawing || !telephone || !montantRetrait}
                  className="flex-1 rounded-2xl bg-gradient-to-r from-amber-500 to-orange-500 px-4 py-3 text-sm font-semibold text-white transition hover:brightness-110 disabled:opacity-50"
                >
                  {withdrawing ? "Traitement…" : "Confirmer le retrait"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ── Historique des reversements ─────────────────────────────────────── */}
      <div className="rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
        <div className="mb-6 flex items-center justify-between">
          <div>
            <h2 className="text-lg font-semibold text-white">Historique des reversements</h2>
            <p className="text-xs text-slate-500">Détail des calculs et paiements enregistrés</p>
          </div>
          <button
            onClick={load}
            className="rounded-xl border border-slate-700 bg-slate-950/60 px-3 py-1.5 text-xs text-slate-400 transition hover:border-slate-600 hover:text-white"
          >
            Rafraîchir
          </button>
        </div>

        {reversements.length === 0 ? (
          <div className="flex flex-col items-center justify-center gap-3 py-12 text-center text-slate-500">
            <div className="flex h-12 w-12 items-center justify-center rounded-full bg-slate-800">
              <svg className="h-6 w-6 text-slate-400" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <p className="text-sm">Aucun historique de reversement pour le moment.</p>
            <p className="max-w-md text-xs text-slate-600">
              Vos gains s'accumulent au fur et à mesure des écoutes de vos titres sur la plateforme.
            </p>
          </div>
        ) : (
          <div className="overflow-hidden rounded-2xl ring-1 ring-slate-800">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-slate-800 bg-slate-950/60 text-left text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">
                  <th className="px-5 py-4">Période</th>
                  <th className="px-5 py-4">Référence</th>
                  <th className="px-5 py-4">Montant</th>
                  <th className="px-5 py-4">Date de versement</th>
                  <th className="px-5 py-4 text-right">Statut</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800/60 bg-slate-900/40">
                {reversements.map((rev) => (
                  <tr key={rev.id} className="transition hover:bg-slate-800/30">
                    <td className="px-5 py-4 font-medium text-white">{rev.periode ?? "Mensuel"}</td>
                    <td className="px-5 py-4 text-xs font-mono text-slate-400">{rev.reference ?? `REV-${rev.id}`}</td>
                    <td className="px-5 py-4 font-semibold text-amber-400">{rev.montant?.toLocaleString("fr")} XAF</td>
                    <td className="px-5 py-4 text-xs text-slate-400">
                      {rev.dateVersement ? new Date(rev.dateVersement).toLocaleDateString("fr-FR") : "En attente"}
                    </td>
                    <td className="px-5 py-4 text-right">
                      <span
                        className={[
                          "rounded-full px-2.5 py-0.5 text-[11px] font-medium",
                          rev.statut === "VERSÉ" || rev.statut === "SUCCES"
                            ? "bg-emerald-500/15 text-emerald-300 ring-1 ring-emerald-500/30"
                            : "bg-amber-500/15 text-amber-300 ring-1 ring-amber-500/30",
                        ].join(" ")}
                      >
                        {rev.statut ?? "Calculé"}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </section>
  );
}
