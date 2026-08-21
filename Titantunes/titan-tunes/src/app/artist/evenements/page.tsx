"use client";

import { useEffect, useState } from "react";
import { useAuth } from "@/hooks/useAuth";
import {
  getEvenementsByArtiste,
  createEvenement,
  updateEvenement,
  deleteEvenement,
} from "@/services/artist";
import type { EvenementResponse } from "@/types/api";

// ─── Utilitaires ──────────────────────────────────────────────────────────────

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString("fr-FR", {
    day: "2-digit", month: "long", year: "numeric",
  });
}

function delaiLabel(iso: string) {
  const diff = Math.ceil((new Date(iso).getTime() - Date.now()) / 86_400_000);
  if (diff < 0)  return { label: "Passé",        cls: "bg-slate-700/60 text-slate-400" };
  if (diff === 0) return { label: "Aujourd'hui",  cls: "bg-emerald-500/15 text-emerald-300" };
  if (diff <= 7)  return { label: `J-${diff}`,    cls: "bg-rose-500/15 text-rose-300" };
  if (diff <= 30) return { label: `J-${diff}`,    cls: "bg-amber-500/15 text-amber-300" };
  return               { label: `J-${diff}`,      cls: "bg-slate-700/60 text-slate-300" };
}

// ─── Modal ────────────────────────────────────────────────────────────────────

function Modal({ title, onClose, children }: { title: string; onClose: () => void; children: React.ReactNode }) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm px-4">
      <div className="w-full max-w-lg rounded-3xl border border-slate-700/70 bg-slate-900 p-7 shadow-2xl">
        <div className="mb-6 flex items-center justify-between">
          <h2 className="text-lg font-semibold text-white">{title}</h2>
          <button onClick={onClose} className="rounded-xl p-1.5 text-slate-400 transition hover:bg-slate-800 hover:text-white" aria-label="Fermer">
            <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}

// ─── Formulaire événement ─────────────────────────────────────────────────────

type EvenementFormData = Omit<EvenementResponse, "idEvenement">;

function EvenementForm({
  initial,
  onSubmit,
  onClose,
  submitLabel,
}: {
  initial?: Partial<EvenementFormData>;
  onSubmit: (data: EvenementFormData) => Promise<void>;
  onClose: () => void;
  submitLabel: string;
}) {
  const [form, setForm] = useState<EvenementFormData>({
    nameConcert:    initial?.nameConcert    ?? "",
    dateEvenement:  initial?.dateEvenement  ?? "",
    dateLimite:     initial?.dateLimite     ?? "",
    lieu:           initial?.lieu           ?? "",
    prixTicket:     initial?.prixTicket     ?? 0,
    artistName:     initial?.artistName     ?? "",
  });
  const [loading, setLoading] = useState(false);
  const [error, setError]     = useState<string | null>(null);

  const set = (key: keyof EvenementFormData, value: string | number) =>
    setForm((f) => ({ ...f, [key]: value }));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      await onSubmit(form);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de la sauvegarde.");
    } finally {
      setLoading(false);
    }
  };

  const inp = "w-full rounded-2xl border border-slate-700/80 bg-slate-950/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition focus:border-orange-500 focus:ring-2 focus:ring-orange-500/20";

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-1.5">
        <label className="text-xs font-medium text-slate-400">Nom du concert *</label>
        <input required value={form.nameConcert} onChange={(e) => set("nameConcert", e.target.value)} className={inp} placeholder="Concert acoustique Vol.2" />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-1.5">
          <label className="text-xs font-medium text-slate-400">Date de l'événement *</label>
          <input required type="datetime-local" value={form.dateEvenement?.slice(0, 16) ?? ""} onChange={(e) => set("dateEvenement", e.target.value)} className={inp} />
        </div>
        <div className="space-y-1.5">
          <label className="text-xs font-medium text-slate-400">Date limite billets</label>
          <input type="datetime-local" value={form.dateLimite?.slice(0, 16) ?? ""} onChange={(e) => set("dateLimite", e.target.value)} className={inp} />
        </div>
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-1.5">
          <label className="text-xs font-medium text-slate-400">Lieu *</label>
          <input required value={form.lieu} onChange={(e) => set("lieu", e.target.value)} className={inp} placeholder="Lomé, Palais des Congrès" />
        </div>
        <div className="space-y-1.5">
          <label className="text-xs font-medium text-slate-400">Prix ticket (XAF)</label>
          <input type="number" min="0" value={form.prixTicket} onChange={(e) => set("prixTicket", Number(e.target.value))} className={inp} placeholder="5000" />
        </div>
      </div>
      {error && <p className="rounded-2xl bg-rose-500/10 px-4 py-3 text-sm text-rose-300">{error}</p>}
      <div className="flex gap-3 pt-2">
        <button type="button" onClick={onClose} className="flex-1 rounded-2xl border border-slate-700 bg-transparent px-4 py-3 text-sm font-semibold text-slate-300 transition hover:text-white">Annuler</button>
        <button type="submit" disabled={loading} className="flex-1 rounded-2xl bg-orange-500 px-4 py-3 text-sm font-semibold text-white transition hover:brightness-110 disabled:opacity-60">
          {loading ? "Sauvegarde…" : submitLabel}
        </button>
      </div>
    </form>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

export default function ArtistEvenementsPage() {
  const { user } = useAuth();
  const [evenements, setEvenements] = useState<EvenementResponse[]>([]);
  const [loading, setLoading]       = useState(true);
  const [error, setError]           = useState<string | null>(null);
  const [showAdd, setShowAdd]       = useState(false);
  const [editing, setEditing]       = useState<EvenementResponse | null>(null);
  const [confirmId, setConfirmId]   = useState<number | null>(null);
  const [deletingId, setDeletingId] = useState<number | null>(null);
  const [filter, setFilter]         = useState<"tous" | "avenir" | "passes">("avenir");

  const load = async () => {
    if (!user?.id) return;
    setLoading(true);
    setError(null);
    try {
      const data = await getEvenementsByArtiste(user.id);
      setEvenements(data.sort((a, b) => new Date(a.dateEvenement).getTime() - new Date(b.dateEvenement).getTime()));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Impossible de charger les événements.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, [user?.id]);

  const handleCreate = async (data: Omit<EvenementResponse, "idEvenement">) => {
    await createEvenement(data);
    setShowAdd(false);
    load();
  };

  const handleUpdate = async (data: Omit<EvenementResponse, "idEvenement">) => {
    if (!editing) return;
    await updateEvenement(editing.idEvenement, data);
    setEditing(null);
    load();
  };

  const handleDelete = async (id: number) => {
    setDeletingId(id);
    try {
      await deleteEvenement(id);
      setEvenements((prev) => prev.filter((e) => e.idEvenement !== id));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de la suppression.");
    } finally {
      setDeletingId(null);
      setConfirmId(null);
    }
  };

  const now = Date.now();
  const filtered = evenements.filter((e) => {
    const t = new Date(e.dateEvenement).getTime();
    if (filter === "avenir") return t >= now;
    if (filter === "passes") return t < now;
    return true;
  });

  const prochainCount = evenements.filter((e) => new Date(e.dateEvenement).getTime() >= now).length;

  return (
    <section className="space-y-6 pb-12">
      {/* En-tête */}
      <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.3em] text-orange-400">Agenda</p>
          <h1 className="mt-1.5 text-3xl font-bold text-white">Événements</h1>
        </div>
        <button
          onClick={() => setShowAdd(true)}
          className="rounded-2xl bg-orange-500 px-5 py-2.5 text-sm font-semibold text-white shadow-lg shadow-orange-500/20 transition hover:brightness-110"
        >
          + Créer un événement
        </button>
      </header>

      {/* KPIs */}
      <div className="grid gap-4 sm:grid-cols-3">
        <div className="rounded-2xl bg-slate-900/70 px-5 py-4 ring-1 ring-slate-700/50">
          <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">Total</p>
          <p className="mt-2 text-2xl font-bold text-white">{evenements.length}</p>
        </div>
        <div className="rounded-2xl bg-slate-900/70 px-5 py-4 ring-1 ring-slate-700/50">
          <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">À venir</p>
          <p className="mt-2 text-2xl font-bold text-emerald-400">{prochainCount}</p>
        </div>
        <div className="rounded-2xl bg-slate-900/70 px-5 py-4 ring-1 ring-slate-700/50">
          <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">Passés</p>
          <p className="mt-2 text-2xl font-bold text-slate-400">{evenements.length - prochainCount}</p>
        </div>
      </div>

      {/* Filtres */}
      <div className="flex gap-2">
        {(["avenir", "tous", "passes"] as const).map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={[
              "rounded-2xl px-4 py-2 text-sm font-medium transition",
              filter === f
                ? "bg-orange-500/15 text-orange-300 ring-1 ring-orange-500/30"
                : "text-slate-400 hover:bg-slate-800 hover:text-white",
            ].join(" ")}
          >
            {f === "avenir" ? "À venir" : f === "tous" ? "Tous" : "Passés"}
          </button>
        ))}
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-16">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
        </div>
      ) : error ? (
        <div className="rounded-2xl bg-rose-500/10 px-4 py-3 text-sm text-rose-300">{error}</div>
      ) : filtered.length === 0 ? (
        <div className="rounded-[2rem] bg-slate-900/50 p-12 text-center text-slate-500">
          Aucun événement {filter === "avenir" ? "à venir" : filter === "passes" ? "passé" : ""} pour l'instant.
        </div>
      ) : (
        <div className="space-y-4">
          {filtered.map((e) => {
            const { label, cls } = delaiLabel(e.dateEvenement);
            const isPast = new Date(e.dateEvenement).getTime() < now;
            return (
              <article
                key={e.idEvenement}
                className={[
                  "flex flex-col gap-4 rounded-[2rem] p-6 ring-1 sm:flex-row sm:items-center sm:justify-between",
                  isPast
                    ? "bg-slate-900/40 ring-slate-800/40 opacity-70"
                    : "bg-slate-900/70 ring-slate-700/50",
                ].join(" ")}
              >
                <div className="flex items-start gap-5">
                  {/* Calendrier mini */}
                  <div className="flex h-14 w-14 shrink-0 flex-col items-center justify-center rounded-2xl bg-orange-500/10 ring-1 ring-orange-500/20">
                    <span className="text-lg font-bold leading-none text-orange-300">
                      {new Date(e.dateEvenement).toLocaleDateString("fr", { day: "2-digit" })}
                    </span>
                    <span className="text-[11px] uppercase text-orange-400">
                      {new Date(e.dateEvenement).toLocaleDateString("fr", { month: "short" })}
                    </span>
                  </div>
                  <div>
                    <div className="flex items-center gap-2 flex-wrap">
                      <h3 className="text-base font-semibold text-white">{e.nameConcert}</h3>
                      <span className={`rounded-full px-2.5 py-0.5 text-[11px] font-medium ${cls}`}>{label}</span>
                    </div>
                    <p className="mt-1 text-sm text-slate-400">{e.lieu}</p>
                    <div className="mt-2 flex flex-wrap gap-x-4 gap-y-1 text-xs text-slate-500">
                      <span>{formatDate(e.dateEvenement)}</span>
                      {e.dateLimite && <span>Billets jusqu'au {formatDate(e.dateLimite)}</span>}
                      {e.prixTicket > 0 && <span>{e.prixTicket.toLocaleString()} XAF</span>}
                    </div>
                  </div>
                </div>
                <div className="flex shrink-0 gap-2">
                  <button
                    onClick={() => setEditing(e)}
                    className="rounded-xl border border-slate-700 px-4 py-2 text-xs font-medium text-slate-300 transition hover:border-orange-500/40 hover:text-orange-300"
                  >
                    Modifier
                  </button>
                  <button
                    onClick={() => setConfirmId(e.idEvenement)}
                    disabled={deletingId === e.idEvenement}
                    className="rounded-xl border border-rose-500/30 px-4 py-2 text-xs font-medium text-rose-400 transition hover:bg-rose-500/10 disabled:opacity-40"
                  >
                    {deletingId === e.idEvenement ? "…" : "Supprimer"}
                  </button>
                </div>
              </article>
            );
          })}
        </div>
      )}

      {/* Modal création */}
      {showAdd && (
        <Modal title="Créer un événement" onClose={() => setShowAdd(false)}>
          <EvenementForm onSubmit={handleCreate} onClose={() => setShowAdd(false)} submitLabel="Créer" />
        </Modal>
      )}

      {/* Modal modification */}
      {editing && (
        <Modal title="Modifier l'événement" onClose={() => setEditing(null)}>
          <EvenementForm
            initial={editing}
            onSubmit={handleUpdate}
            onClose={() => setEditing(null)}
            submitLabel="Enregistrer"
          />
        </Modal>
      )}

      {/* Confirmation suppression */}
      {confirmId !== null && (
        <Modal title="Supprimer cet événement ?" onClose={() => setConfirmId(null)}>
          <p className="text-sm text-slate-400 mb-6">Cette action est irréversible.</p>
          <div className="flex gap-3">
            <button onClick={() => setConfirmId(null)} className="flex-1 rounded-2xl border border-slate-700 px-4 py-3 text-sm font-semibold text-slate-300 transition hover:text-white">Annuler</button>
            <button
              onClick={() => confirmId !== null && handleDelete(confirmId)}
              disabled={deletingId !== null}
              className="flex-1 rounded-2xl bg-rose-600 px-4 py-3 text-sm font-semibold text-white transition hover:brightness-110 disabled:opacity-60"
            >
              {deletingId !== null ? "Suppression…" : "Supprimer"}
            </button>
          </div>
        </Modal>
      )}
    </section>
  );
}
