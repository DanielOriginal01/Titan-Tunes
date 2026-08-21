"use client";

import { useEffect, useState } from "react";
import { getUtilisateurs, createUtilisateur, updateStatutUtilisateur } from "@/services/adminService";
import type { UtilisateurAdmin, StatutUtilisateur } from "@/types/api";
import type { UserRole } from "@/features/auth/types";

// ─── Modal ────────────────────────────────────────────────────────────────────

function Modal({ title, onClose, children }: {
  title: string; onClose: () => void; children: React.ReactNode;
}) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm px-4">
      <div className="w-full max-w-lg rounded-3xl border border-slate-700/70 bg-slate-900 p-7 shadow-2xl">
        <div className="mb-6 flex items-center justify-between">
          <h2 className="text-lg font-semibold text-white">{title}</h2>
          <button onClick={onClose} aria-label="Fermer"
            className="rounded-xl p-1.5 text-slate-400 transition hover:bg-slate-800 hover:text-white">
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

// ─── Badges ───────────────────────────────────────────────────────────────────

const ROLE_BADGE: Record<string, string> = {
  role_admin:    "bg-blue-500/15 text-blue-300 ring-1 ring-blue-500/30",
  role_artiste:  "bg-orange-500/15 text-orange-300 ring-1 ring-orange-500/30",
  role_auditeur: "bg-violet-500/15 text-violet-300 ring-1 ring-violet-500/30",
};

const STATUT_BADGE: Record<StatutUtilisateur, string> = {
  ACTIF:     "bg-emerald-500/15 text-emerald-300",
  INACTIF:   "bg-amber-500/15 text-amber-300",
  SUPPRIME:  "bg-rose-500/15 text-rose-300",
};

function RoleBadge({ role }: { role: string }) {
  const key = role.toLowerCase();
  const cls = ROLE_BADGE[key] ?? "bg-slate-700/60 text-slate-400";
  const label = key.replace("role_", "").replace(/^\w/, (c) => c.toUpperCase());
  return <span className={`rounded-full px-2.5 py-0.5 text-[11px] font-medium ${cls}`}>{label}</span>;
}

function StatutBadge({ statut }: { statut: StatutUtilisateur }) {
  return (
    <span className={`rounded-full px-2.5 py-0.5 text-[11px] font-medium ${STATUT_BADGE[statut]}`}>
      {statut}
    </span>
  );
}

// ─── Formulaire d'ajout ───────────────────────────────────────────────────────

function AddUserForm({ onSuccess, onClose }: { onSuccess: () => void; onClose: () => void }) {
  const [form, setForm] = useState({
    username: "", email: "", password: "", telephone: "",
    role: "ROLE_ARTISTE" as UserRole, artistName: "",
  });
  const [loading, setLoading] = useState(false);
  const [error, setError]     = useState<string | null>(null);

  const inp = "w-full rounded-2xl border border-slate-700/80 bg-slate-950/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 transition";

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true); setError(null);
    try {
      await createUtilisateur({
        ...form,
        artistName: form.role === "ROLE_ARTISTE" ? (form.artistName.trim() || null) : null,
      });
      onSuccess();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de la création.");
    } finally { setLoading(false); }
  };

  const set = (k: keyof typeof form, v: string) => setForm((f) => ({ ...f, [k]: v }));

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-1.5">
          <label className="text-xs font-medium text-slate-400">Nom d'utilisateur *</label>
          <input required value={form.username} onChange={(e) => set("username", e.target.value)} className={inp} placeholder="johndoe" />
        </div>
        <div className="space-y-1.5">
          <label className="text-xs font-medium text-slate-400">Téléphone *</label>
          <input required value={form.telephone} onChange={(e) => set("telephone", e.target.value)} className={inp} placeholder="+22890000000" />
        </div>
      </div>
      <div className="space-y-1.5">
        <label className="text-xs font-medium text-slate-400">Email *</label>
        <input required type="email" value={form.email} onChange={(e) => set("email", e.target.value)} className={inp} placeholder="nom@exemple.com" />
      </div>
      <div className="space-y-1.5">
        <label className="text-xs font-medium text-slate-400">Mot de passe *</label>
        <input required type="password" minLength={8} value={form.password} onChange={(e) => set("password", e.target.value)} className={inp} placeholder="••••••••" />
      </div>
      <div className="space-y-1.5">
        <label className="text-xs font-medium text-slate-400">Rôle *</label>
        <select value={form.role} onChange={(e) => set("role", e.target.value as UserRole)} className={inp}>
          <option value="ROLE_ARTISTE">Artiste</option>
          <option value="ROLE_ADMIN">Administrateur</option>
        </select>
      </div>
      {form.role === "ROLE_ARTISTE" && (
        <div className="space-y-1.5">
          <label className="text-xs font-medium text-slate-400">Nom d'artiste (optionnel)</label>
          <input value={form.artistName} onChange={(e) => set("artistName", e.target.value)} className={inp} placeholder="Nom de scène" />
        </div>
      )}
      {error && <p className="rounded-2xl bg-rose-500/10 px-4 py-3 text-sm text-rose-300">{error}</p>}
      <div className="flex gap-3 pt-2">
        <button type="button" onClick={onClose}
          className="flex-1 rounded-2xl border border-slate-700 px-4 py-3 text-sm font-semibold text-slate-300 hover:text-white transition">
          Annuler
        </button>
        <button type="submit" disabled={loading}
          className="flex-1 rounded-2xl bg-blue-600 px-4 py-3 text-sm font-semibold text-white hover:brightness-110 transition disabled:opacity-60">
          {loading ? "Création…" : "Créer l'utilisateur"}
        </button>
      </div>
    </form>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

export default function AdminUtilisateursPage() {
  const [users, setUsers]       = useState<UtilisateurAdmin[]>([]);
  const [loading, setLoading]   = useState(true);
  const [error, setError]       = useState<string | null>(null);
  const [showAdd, setShowAdd]   = useState(false);
  const [search, setSearch]     = useState("");
  const [roleFilter, setRoleFilter] = useState("tous");
  const [updatingId, setUpdatingId] = useState<number | null>(null);

  const load = async () => {
    setLoading(true); setError(null);
    try { setUsers(await getUtilisateurs()); }
    catch (err) { setError(err instanceof Error ? err.message : "Impossible de charger les utilisateurs."); }
    finally { setLoading(false); }
  };

  useEffect(() => { load(); }, []);

  const handleStatut = async (id: number, statut: string) => {
    setUpdatingId(id);
    try {
      await updateStatutUtilisateur(id, statut);
      setUsers((u) => u.map((x) => x.id === id ? { ...x, statut: statut as StatutUtilisateur } : x));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de la mise à jour.");
    } finally { setUpdatingId(null); }
  };

  const filtered = users.filter((u) => {
    const q = search.toLowerCase();
    const matchSearch = u.username.toLowerCase().includes(q) || u.email.toLowerCase().includes(q);
    const matchRole = roleFilter === "tous" || u.role.toLowerCase().includes(roleFilter);
    return matchSearch && matchRole;
  });

  return (
    <section className="space-y-6 pb-12">
      {/* En-tête */}
      <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.3em] text-blue-400">Administration</p>
          <h1 className="mt-1.5 text-3xl font-bold text-white">Comptes Utilisateurs</h1>
        </div>
        <button onClick={() => setShowAdd(true)}
          className="rounded-2xl bg-blue-600 px-5 py-2.5 text-sm font-semibold text-white shadow-lg shadow-blue-600/20 hover:brightness-110 transition">
          + Ajouter un utilisateur
        </button>
      </header>

      {/* KPIs */}
      <div className="grid gap-4 sm:grid-cols-3">
        {[
          { label: "Total comptes", value: users.length,                                                     color: "text-white" },
          { label: "Artistes",      value: users.filter((u) => u.role.toLowerCase().includes("artiste")).length, color: "text-orange-300" },
          { label: "Administrateurs", value: users.filter((u) => u.role.toLowerCase().includes("admin")).length,   color: "text-blue-300" },
        ].map(({ label, value, color }) => (
          <div key={label} className="rounded-2xl bg-slate-900/70 px-5 py-4 ring-1 ring-slate-700/50">
            <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">{label}</p>
            <p className={`mt-2 text-2xl font-bold ${color}`}>{value}</p>
          </div>
        ))}
      </div>

      {/* Filtres */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
        <div className="relative flex-1">
          <svg className="absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-500" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 105 11a6 6 0 0012 0z" />
          </svg>
          <input value={search} onChange={(e) => setSearch(e.target.value)} type="search"
            placeholder="Rechercher par nom ou email…"
            className="w-full rounded-2xl border border-slate-700/80 bg-slate-900/60 py-3 pl-11 pr-4 text-sm text-white placeholder-slate-500 outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20" />
        </div>
        <div className="flex gap-2">
          {[["tous", "Tous"], ["admin", "Admins"], ["artiste", "Artistes"]].map(([v, l]) => (
            <button key={v} onClick={() => setRoleFilter(v)}
              className={["rounded-2xl px-4 py-2.5 text-sm font-medium transition",
                roleFilter === v ? "bg-blue-600/15 text-blue-300 ring-1 ring-blue-500/30" : "text-slate-400 hover:bg-slate-800 hover:text-white"].join(" ")}>
              {l}
            </button>
          ))}
        </div>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-16">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-blue-500 border-t-transparent" />
        </div>
      ) : error ? (
        <div className="rounded-2xl bg-rose-500/10 px-4 py-3 text-sm text-rose-300">{error}</div>
      ) : (
        <div className="overflow-hidden rounded-[2rem] ring-1 ring-slate-700/50">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-slate-800 bg-slate-900/80 text-left text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">
                <th className="px-5 py-4">Utilisateur</th>
                <th className="hidden px-5 py-4 sm:table-cell">Rôle</th>
                <th className="hidden px-5 py-4 md:table-cell">Téléphone</th>
                <th className="px-5 py-4">Statut</th>
                <th className="px-5 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/60 bg-slate-900/40">
              {filtered.length === 0 ? (
                <tr><td colSpan={5} className="px-5 py-10 text-center text-slate-500">Aucun utilisateur trouvé.</td></tr>
              ) : filtered.map((u) => (
                <tr key={u.id} className="transition hover:bg-slate-800/30">
                  <td className="px-5 py-4">
                    <p className="font-medium text-white">{u.username}</p>
                    <p className="text-xs text-slate-500">{u.email}</p>
                  </td>
                  <td className="hidden px-5 py-4 sm:table-cell">
                    <RoleBadge role={u.role} />
                  </td>
                  <td className="hidden px-5 py-4 text-slate-400 md:table-cell">{u.telephone ?? "—"}</td>
                  <td className="px-5 py-4">
                    <StatutBadge statut={u.statut} />
                  </td>
                  <td className="px-5 py-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      {u.statut !== "ACTIF" && (
                        <button onClick={() => handleStatut(u.id, "ACTIF")} disabled={updatingId === u.id}
                          className="rounded-xl border border-emerald-500/30 px-3 py-1.5 text-[11px] font-medium text-emerald-400 hover:bg-emerald-500/10 transition disabled:opacity-40">
                          Activer
                        </button>
                      )}
                      {u.statut === "ACTIF" && (
                        <button onClick={() => handleStatut(u.id, "INACTIF")} disabled={updatingId === u.id}
                          className="rounded-xl border border-amber-500/30 px-3 py-1.5 text-[11px] font-medium text-amber-400 hover:bg-amber-500/10 transition disabled:opacity-40">
                          Désactiver
                        </button>
                      )}
                      {u.statut !== "SUPPRIME" && (
                        <button onClick={() => handleStatut(u.id, "SUPPRIME")} disabled={updatingId === u.id}
                          className="rounded-xl border border-rose-500/30 px-3 py-1.5 text-[11px] font-medium text-rose-400 hover:bg-rose-500/10 transition disabled:opacity-40">
                          Supprimer
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {showAdd && (
        <Modal title="Ajouter un utilisateur" onClose={() => setShowAdd(false)}>
          <AddUserForm
            onSuccess={() => { setShowAdd(false); load(); }}
            onClose={() => setShowAdd(false)}
          />
        </Modal>
      )}
    </section>
  );
}
