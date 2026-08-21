"use client";

import { useEffect, useRef, useState } from "react";
import { useAuth } from "@/hooks/useAuth";
import { getArtisteById, updateArtiste, getArtistePhotoUrl, uploadArtistePhoto } from "@/services/artist";
import type { ArtisteResponse } from "@/types/api";

// ─── Section card ──────────────────────────────────────────────────────────────

function SectionCard({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
      <h2 className="mb-5 text-base font-semibold text-white">{title}</h2>
      {children}
    </div>
  );
}

const inp = "w-full rounded-2xl border border-slate-700/80 bg-slate-950/60 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition focus:border-orange-500 focus:ring-2 focus:ring-orange-500/20";

export default function ArtistSettingsPage() {
  const { user } = useAuth();
  const [profil, setProfil]         = useState<ArtisteResponse | null>(null);
  const [loading, setLoading]       = useState(true);
  const [saving, setSaving]         = useState(false);
  const [uploadingPhoto, setUploadingPhoto] = useState(false);
  const [error, setError]           = useState<string | null>(null);
  const [success, setSuccess]       = useState<string | null>(null);
  const [photoPreview, setPhotoPreview] = useState<string | null>(null);
  const photoRef = useRef<HTMLInputElement>(null);

  // Champs éditables
  const [artistName, setArtistName] = useState("");
  const [bio, setBio]               = useState("");

  useEffect(() => {
    if (!user?.id) return;
    (async () => {
      setLoading(true);
      try {
        const [data, photoUrl] = await Promise.all([
          getArtisteById(user.id),
          getArtistePhotoUrl(user.id),
        ]);
        setProfil(data);
        setArtistName(data.artistName ?? "");
        setBio(data.bio ?? "");
        if (photoUrl) {
          setPhotoPreview(photoUrl);
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : "Impossible de charger le profil.");
      } finally {
        setLoading(false);
      }
    })();
  }, [user?.id]);

  const handleSaveProfil = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user?.id) return;
    setSaving(true);
    setError(null);
    setSuccess(null);
    try {
      await updateArtiste(user.id, { artistName, bio });
      setSuccess("Profil mis à jour avec succès.");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de la sauvegarde.");
    } finally {
      setSaving(false);
    }
  };

  const handlePhotoChange = async (file: File) => {
    if (!user?.id) return;
    setUploadingPhoto(true);
    setError(null);
    setSuccess(null);
    try {
      await uploadArtistePhoto(user.id, file);
      const newUrl = await getArtistePhotoUrl(user.id);
      if (newUrl) {
        setPhotoPreview(newUrl);
      } else {
        setPhotoPreview(URL.createObjectURL(file));
      }
      setSuccess("Photo de profil mise à jour et enregistrée sur MinIO avec succès.");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de l'upload de la photo.");
    } finally {
      setUploadingPhoto(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="h-9 w-9 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
      </div>
    );
  }

  return (
    <section className="space-y-6 pb-12">
      {/* En-tête */}
      <header className="rounded-[2rem] bg-slate-900/70 p-7 ring-1 ring-slate-700/50">
        <p className="text-xs font-semibold uppercase tracking-[0.3em] text-orange-400">Compte</p>
        <h1 className="mt-1.5 text-3xl font-bold text-white">Paramètres</h1>
      </header>

      {(error || success) && (
        <div className={[
          "rounded-2xl px-5 py-4 text-sm",
          error   ? "bg-rose-500/10 text-rose-300"    : "",
          success ? "bg-emerald-500/10 text-emerald-300" : "",
        ].join(" ")}>
          {error ?? success}
        </div>
      )}

      {/* Photo de profil */}
      <SectionCard title="Photo de profil">
        <div className="flex items-center gap-6">
          <div
            className="relative h-20 w-20 cursor-pointer overflow-hidden rounded-full ring-2 ring-slate-700 transition hover:ring-orange-500/50"
            onClick={() => photoRef.current?.click()}
          >
            {photoPreview || profil?.photoCouverture ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={photoPreview ?? profil?.photoCouverture ?? ""}
                alt="Photo de profil"
                className="h-full w-full object-cover"
              />
            ) : (
              <div className="flex h-full w-full items-center justify-center bg-orange-500/15 text-2xl font-bold text-orange-400">
                {(user?.username ?? "A")[0].toUpperCase()}
              </div>
            )}
            {uploadingPhoto && (
              <div className="absolute inset-0 flex items-center justify-center bg-black/60">
                <div className="h-5 w-5 animate-spin rounded-full border-2 border-white border-t-transparent" />
              </div>
            )}
          </div>
          <div>
            <p className="text-sm text-slate-300">Cliquez sur la photo pour la modifier.</p>
            <p className="text-xs text-slate-500 mt-1">JPG, PNG — max 5 Mo</p>
            <input
              ref={photoRef}
              type="file"
              accept="image/*"
              className="hidden"
              onChange={(e) => { const f = e.target.files?.[0]; if (f) handlePhotoChange(f); }}
            />
          </div>
        </div>
      </SectionCard>

      {/* Infos artiste */}
      <SectionCard title="Informations artiste">
        <form onSubmit={handleSaveProfil} className="space-y-4">
          <div className="space-y-1.5">
            <label className="block text-xs font-medium text-slate-400">Nom d'artiste</label>
            <input value={artistName} onChange={(e) => setArtistName(e.target.value)} className={inp} placeholder="Votre nom de scène" />
          </div>
          <div className="space-y-1.5">
            <label className="block text-xs font-medium text-slate-400">Biographie</label>
            <textarea
              value={bio}
              onChange={(e) => setBio(e.target.value)}
              className={`${inp} resize-none`}
              rows={5}
              placeholder="Parlez de vous, de votre style musical…"
            />
          </div>
          <div className="space-y-1.5">
            <label className="block text-xs font-medium text-slate-400">Email</label>
            <input value={user?.email ?? ""} disabled className={`${inp} cursor-not-allowed opacity-50`} />
            <p className="text-xs text-slate-600">L'adresse email ne peut pas être modifiée ici.</p>
          </div>
          <button
            type="submit"
            disabled={saving}
            className="rounded-2xl bg-orange-500 px-6 py-3 text-sm font-semibold text-white transition hover:brightness-110 disabled:opacity-60"
          >
            {saving ? "Sauvegarde…" : "Enregistrer les modifications"}
          </button>
        </form>
      </SectionCard>

      {/* Infos compte */}
      <SectionCard title="Compte">
        <div className="space-y-3">
          <Row label="Nom d'utilisateur" value={user?.username ?? "—"} />
          <Row label="Rôle"              value={profil ? (profil.verifie ? "Artiste vérifié ✓" : "Artiste") : "—"} />
        </div>
      </SectionCard>
    </section>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between rounded-2xl border border-slate-800/60 bg-slate-950/40 px-4 py-3">
      <span className="text-sm text-slate-400">{label}</span>
      <span className="text-sm font-medium text-white">{value}</span>
    </div>
  );
}
