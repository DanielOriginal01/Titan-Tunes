"use client";

import { useEffect, useState } from "react";
import { createLabel, deleteLabel, getAllLabels } from "@/services/labelService";
import type { Label } from "@/types/api";

export default function AdminLabelsPage() {
  const [labels, setLabels]       = useState<Label[]>([]);
  const [form, setForm]           = useState({ nom: "", description: "" });
  const [loading, setLoading]     = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError]         = useState<string | null>(null);
  const [message, setMessage]     = useState<string | null>(null);

  useEffect(() => {
    loadLabels();
  }, []);

  async function loadLabels() {
    setLoading(true);
    setError(null);
    try {
      const data = await getAllLabels();
      setLabels(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Impossible de charger les labels.");
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSubmitting(true);
    setError(null);
    setMessage(null);

    try {
      const created = await createLabel({ nom: form.nom, description: form.description });
      setLabels((current) => [created, ...current]);
      setForm({ nom: "", description: "" });
      setMessage(`Label "${created.nom}" créé avec succès.`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de la création du label.");
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(id: number) {
    setError(null);
    setMessage(null);
    try {
      await deleteLabel(id);
      setLabels((current) => current.filter((item) => item.id !== id));
      setMessage("Label supprimé avec succès.");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de la suppression.");
    }
  }

  const inp = "w-full rounded-2xl border border-slate-700/80 bg-slate-950/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20";

  return (
    <section className="space-y-6 pb-12">
      {/* En-tête */}
      <header className="rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
        <p className="text-xs font-semibold uppercase tracking-[0.3em] text-blue-400">Labels Musicaux</p>
        <h1 className="mt-1.5 text-3xl font-bold text-white">Gestion des Maisons de Disque & Labels</h1>
      </header>

      {/* Messages */}
      {message && (
        <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/10 p-4 text-sm text-emerald-300">
          {message}
        </div>
      )}
      {error && (
        <div className="rounded-2xl border border-rose-500/30 bg-rose-500/10 p-4 text-sm text-rose-300">
          {error}
        </div>
      )}

      <div className="grid gap-6 xl:grid-cols-[0.85fr_1.15fr]">
        {/* Formulaire de création */}
        <form onSubmit={handleSubmit} className="space-y-4 rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
          <h2 className="text-lg font-semibold text-white">Créer un nouveau label</h2>
          <p className="text-xs text-slate-500">Ajoutez un label pour y associer des artistes et des reversements.</p>

          <div className="space-y-1.5">
            <label className="text-xs font-medium text-slate-400">Nom du label *</label>
            <input
              value={form.nom}
              onChange={(e) => setForm((curr) => ({ ...curr, nom: e.target.value }))}
              type="text"
              required
              placeholder="ex: Empire Music Africa"
              className={inp}
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-medium text-slate-400">Description</label>
            <textarea
              value={form.description}
              onChange={(e) => setForm((curr) => ({ ...curr, description: e.target.value }))}
              rows={4}
              placeholder="Historique, contact, catalogue géré…"
              className={`${inp} resize-none`}
            />
          </div>

          <button
            type="submit"
            disabled={submitting || !form.nom.trim()}
            className="w-full rounded-2xl bg-gradient-to-r from-blue-600 to-blue-700 px-5 py-3 text-sm font-semibold text-white shadow-lg shadow-blue-600/20 transition hover:brightness-110 disabled:opacity-50"
          >
            {submitting ? "Création…" : "Enregistrer le label"}
          </button>
        </form>

        {/* Liste des labels */}
        <div className="rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
          <div className="mb-5 flex items-center justify-between">
            <div>
              <h2 className="text-lg font-semibold text-white">Labels Référencés</h2>
              <p className="text-xs text-slate-500">{labels.length} labels enregistrés</p>
            </div>
            <button
              type="button"
              onClick={loadLabels}
              className="rounded-xl border border-slate-700 bg-slate-950/60 px-3 py-1.5 text-xs text-slate-400 hover:border-slate-600 hover:text-white transition"
            >
              Rafraîchir
            </button>
          </div>

          {loading ? (
            <div className="flex items-center justify-center py-16">
              <div className="h-8 w-8 animate-spin rounded-full border-4 border-blue-500 border-t-transparent" />
            </div>
          ) : labels.length === 0 ? (
            <div className="rounded-2xl bg-slate-950/40 p-8 text-center text-sm text-slate-500">
              Aucun label enregistré pour le moment.
            </div>
          ) : (
            <div className="space-y-3">
              {labels.map((l) => {
                const labelId = l.idLabel ?? l.id ?? 0;
                const labelTitle = l.labelName ?? l.nom ?? "Label";
                return (
                  <article key={labelId} className="flex items-start justify-between gap-4 rounded-2xl border border-slate-800 bg-slate-950/40 p-4 transition hover:bg-slate-800/30">
                    <div className="flex items-start gap-3 min-w-0">
                      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-blue-500/15 text-sm font-bold text-blue-400">
                        {labelTitle[0]?.toUpperCase() ?? "L"}
                      </div>
                      <div className="min-w-0">
                        <h3 className="font-semibold text-white truncate">{labelTitle}</h3>
                        <p className="mt-1 text-xs text-slate-400 line-clamp-2">{l.description || "Maison de disque enregistrée sur la plateforme."}</p>
                      </div>
                    </div>
                    <button
                      type="button"
                      onClick={() => handleDelete(labelId)}
                      className="rounded-xl border border-rose-500/30 bg-rose-500/10 px-3 py-1.5 text-xs font-medium text-rose-400 hover:bg-rose-500/20 transition shrink-0"
                    >
                      Supprimer
                    </button>
                  </article>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
