"use client";

import { useEffect, useState } from "react";
import {
  createNotification,
  deleteNotification,
  getAllNotifications,
  marquerCommeLue,
} from "@/services/notificationService";
import type { Notification } from "@/types/api";

export default function AdminNotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [loading, setLoading]             = useState(true);
  const [submitting, setSubmitting]       = useState(false);
  const [error, setError]                 = useState<string | null>(null);
  const [message, setMessage]             = useState<string | null>(null);
  const [form, setForm]                   = useState({ titre: "", message: "", type: "INFO" });

  useEffect(() => {
    loadNotifications();
  }, []);

  async function loadNotifications() {
    setLoading(true);
    setError(null);
    try {
      const data = await getAllNotifications();
      setNotifications(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Impossible de charger les notifications.");
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
      const created = await createNotification({
        titre: form.titre,
        message: form.message,
        type: form.type,
      });
      setNotifications((curr) => [created, ...curr]);
      setForm({ titre: "", message: "", type: "INFO" });
      setMessage("Notification diffusée avec succès sur la plateforme.");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de l'envoi de la notification.");
    } finally {
      setSubmitting(false);
    }
  }

  async function markAsRead(id: number) {
    try {
      const updated = await marquerCommeLue(id);
      setNotifications((curr) => curr.map((item) => (item.id === id ? updated : item)));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de la mise à jour.");
    }
  }

  async function handleDelete(id: number) {
    try {
      await deleteNotification(id);
      setNotifications((curr) => curr.filter((item) => item.id !== id));
      setMessage("Notification supprimée.");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de la suppression.");
    }
  }

  const inp = "w-full rounded-2xl border border-slate-700/80 bg-slate-950/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20";

  return (
    <section className="space-y-6 pb-12">
      {/* En-tête */}
      <header className="rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
        <p className="text-xs font-semibold uppercase tracking-[0.3em] text-blue-400">Diffusion & Alertes</p>
        <h1 className="mt-1.5 text-3xl font-bold text-white">Notifications Système</h1>
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
        {/* Formulaire d'envoi */}
        <form onSubmit={handleSubmit} className="space-y-4 rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
          <h2 className="text-lg font-semibold text-white">Diffuser un message</h2>
          <p className="text-xs text-slate-500">Envoyez une annonce aux artistes et utilisateurs de la plateforme.</p>

          <div className="space-y-1.5">
            <label className="text-xs font-medium text-slate-400">Titre de la notification *</label>
            <input
              value={form.titre}
              onChange={(e) => setForm((curr) => ({ ...curr, titre: e.target.value }))}
              type="text"
              required
              placeholder="ex: Maintenance planifiée / Nouveau barème"
              className={inp}
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-medium text-slate-400">Type d'alerte *</label>
            <select
              value={form.type}
              onChange={(e) => setForm((curr) => ({ ...curr, type: e.target.value }))}
              className={inp}
            >
              <option value="INFO">Information (Générale)</option>
              <option value="ALERT">Alerte (Importante)</option>
              <option value="SUCCESS">Succès (Félicitations)</option>
              <option value="PAYMENT">Paiement / Reversement</option>
            </select>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-medium text-slate-400">Contenu du message *</label>
            <textarea
              value={form.message}
              onChange={(e) => setForm((curr) => ({ ...curr, message: e.target.value }))}
              rows={4}
              required
              placeholder="Rédigez votre annonce…"
              className={`${inp} resize-none`}
            />
          </div>

          <button
            type="submit"
            disabled={submitting || !form.titre.trim() || !form.message.trim()}
            className="w-full rounded-2xl bg-gradient-to-r from-blue-600 to-blue-700 px-5 py-3 text-sm font-semibold text-white shadow-lg shadow-blue-600/20 transition hover:brightness-110 disabled:opacity-50"
          >
            {submitting ? "Diffusion en cours…" : "Diffuser la notification"}
          </button>
        </form>

        {/* Historique des notifications */}
        <div className="rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
          <div className="mb-5 flex items-center justify-between">
            <div>
              <h2 className="text-lg font-semibold text-white">Historique des notifications</h2>
              <p className="text-xs text-slate-500">{notifications.length} notifications enregistrées</p>
            </div>
            <button
              type="button"
              onClick={loadNotifications}
              className="rounded-xl border border-slate-700 bg-slate-950/60 px-3 py-1.5 text-xs text-slate-400 hover:border-slate-600 hover:text-white transition"
            >
              Rafraîchir
            </button>
          </div>

          {loading ? (
            <div className="flex items-center justify-center py-16">
              <div className="h-8 w-8 animate-spin rounded-full border-4 border-blue-500 border-t-transparent" />
            </div>
          ) : notifications.length === 0 ? (
            <div className="rounded-2xl bg-slate-950/40 p-8 text-center text-sm text-slate-500">
              Aucune notification dans l'historique.
            </div>
          ) : (
            <div className="space-y-3">
              {notifications.map((n) => (
                <article key={n.id} className="flex items-start justify-between gap-4 rounded-2xl border border-slate-800 bg-slate-950/40 p-4 transition hover:bg-slate-800/30">
                  <div className="min-w-0">
                    <div className="flex items-center gap-2">
                      <h3 className="font-semibold text-white truncate">{n.titre || "Notification"}</h3>
                      {!n.lu && (
                        <span className="rounded-full bg-blue-500/20 px-2 py-0.5 text-[10px] font-bold text-blue-300">
                          Non lue
                        </span>
                      )}
                      {n.type && (
                        <span className="rounded-full bg-slate-800 px-2 py-0.5 text-[10px] text-slate-400 font-medium">
                          {n.type}
                        </span>
                      )}
                    </div>
                    <p className="mt-1.5 text-xs text-slate-400 leading-relaxed">{n.message}</p>
                  </div>
                  <div className="flex flex-col gap-1.5 shrink-0">
                    {!n.lu && (
                      <button
                        type="button"
                        onClick={() => markAsRead(n.id)}
                        className="rounded-xl border border-blue-500/30 bg-blue-500/10 px-2.5 py-1 text-[11px] font-medium text-blue-300 hover:bg-blue-500/20 transition"
                      >
                        Marquer lue
                      </button>
                    )}
                    <button
                      type="button"
                      onClick={() => handleDelete(n.id)}
                      className="rounded-xl border border-rose-500/30 bg-rose-500/10 px-2.5 py-1 text-[11px] font-medium text-rose-400 hover:bg-rose-500/20 transition"
                    >
                      Supprimer
                    </button>
                  </div>
                </article>
              ))}
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
