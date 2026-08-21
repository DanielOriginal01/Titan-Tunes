"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useAuth } from "@/hooks/useAuth";
import {
  publierChanson,
  getAlbumsByArtiste,
  getAllCategories,
  createAlbum,
} from "@/services/artist";
import type { AlbumResponse, CategorieResponse } from "@/types/api";
import { useAudioPlayer } from "@/providers/AudioPlayerProvider";

export default function MusicUploadPage() {
  const router = useRouter();
  const { user } = useAuth();
  const { playChanson } = useAudioPlayer();

  const [titre, setTitre] = useState("");
  const [duree, setDuree] = useState("180");
  const [albumId, setAlbumId] = useState<string>("");
  const [categorieId, setCategorieId] = useState<string>("1");
  const [categories, setCategories] = useState<CategorieResponse[]>([]);
  const [albums, setAlbums] = useState<AlbumResponse[]>([]);
  const [parole, setParole] = useState("");

  const [audioFile, setAudioFile] = useState<File | null>(null);
  const [audioPreviewUrl, setAudioPreviewUrl] = useState<string | null>(null);
  const [isPreviewPlaying, setIsPreviewPlaying] = useState(false);
  const previewAudioRef = useRef<HTMLAudioElement | null>(null);

  const [coverFile, setCoverFile] = useState<File | null>(null);
  const [coverPreview, setCoverPreview] = useState<string | null>(null);

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successTrack, setSuccessTrack] = useState<{ id: number; titre: string } | null>(null);

  // Modal rapide de création d'album
  const [showQuickAlbum, setShowQuickAlbum] = useState(false);
  const [newAlbumTitle, setNewAlbumTitle] = useState("");
  const [creatingAlbum, setCreatingAlbum] = useState(false);

  const audioInputRef = useRef<HTMLInputElement>(null);
  const coverInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    async function loadMeta() {
      try {
        const [cats, albs] = await Promise.all([
          getAllCategories(),
          user?.id ? getAlbumsByArtiste(user.id) : Promise.resolve([]),
        ]);
        if (cats.length > 0) {
          setCategories(cats);
          setCategorieId(String(cats[0].id));
        }
        setAlbums(albs);
      } catch (err) {
        console.error("Erreur de chargement des métadonnées:", err);
      }
    }
    loadMeta();
  }, [user?.id]);

  const handleAudioSelect = (file: File) => {
    setAudioFile(file);
    if (!titre.trim()) {
      const cleanName = file.name.replace(/\.[^/.]+$/, "").replace(/[_-]/g, " ");
      setTitre(cleanName);
    }
    try {
      const url = URL.createObjectURL(file);
      setAudioPreviewUrl(url);
      const audio = new Audio();
      audio.src = url;
      audio.onloadedmetadata = () => {
        if (audio.duration && !isNaN(audio.duration)) {
          setDuree(String(Math.round(audio.duration)));
        }
      };
    } catch {
      /* ignore */
    }
  };

  const togglePreviewPlay = () => {
    if (!previewAudioRef.current) return;
    if (isPreviewPlaying) {
      previewAudioRef.current.pause();
      setIsPreviewPlaying(false);
    } else {
      previewAudioRef.current.play().then(() => setIsPreviewPlaying(true)).catch(() => {});
    }
  };

  const handleCoverSelect = (file: File) => {
    setCoverFile(file);
    const reader = new FileReader();
    reader.onload = (e) => setCoverPreview(e.target?.result as string);
    reader.readAsDataURL(file);
  };

  const handleCreateQuickAlbum = async () => {
    if (!newAlbumTitle.trim() || !user?.id) return;
    setCreatingAlbum(true);
    try {
      const created = await createAlbum({
        title: newAlbumTitle.trim(),
        dateSortie: new Date().toISOString().split("T")[0],
        artisteId: user.id,
      });
      setAlbums((prev) => [...prev, created]);
      setAlbumId(String(created.id));
      setShowQuickAlbum(false);
      setNewAlbumTitle("");
    } catch (err) {
      alert(err instanceof Error ? err.message : "Erreur création album");
    } finally {
      setCreatingAlbum(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!audioFile) {
      setError("Veuillez sélectionner un fichier audio (.mp3 ou .wav).");
      return;
    }
    if (!titre.trim()) {
      setError("Le titre du morceau est obligatoire.");
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      const created = await publierChanson(
        {
          titre: titre.trim(),
          duree: Number(duree) || 180,
          artisteId: user?.id,
          categorieId: Number(categorieId) || 1,
          albumId: albumId ? Number(albumId) : undefined,
          parole: parole.trim() || undefined,
        },
        audioFile,
        coverFile,
      );

      setSuccessTrack({ id: created.id, titre: created.titre });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erreur lors de la publication.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <section className="space-y-8 max-w-4xl mx-auto pb-32">
      {/* En-tête */}
      <header className="rounded-3xl bg-slate-900/80 p-8 shadow-xl ring-1 ring-slate-800 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <Link
            href="/artist/music"
            className="inline-flex items-center gap-2 text-xs font-semibold text-orange-400 hover:text-orange-300 mb-2 transition"
          >
            ← Retour au Catalogue
          </Link>
          <h1 className="text-3xl font-bold text-white tracking-tight">Studio Upload Titan Tunes</h1>
          <p className="mt-1 text-sm text-slate-400">
            Publiez vos nouveaux singles ou ajoutez des morceaux à vos albums en streaming haute qualité.
          </p>
        </div>
        <div className="flex gap-2">
          <Link
            href="/artist/music"
            className="rounded-2xl border border-slate-700 bg-slate-800/80 px-4 py-2.5 text-xs font-semibold text-slate-300 hover:bg-slate-700 hover:text-white transition"
          >
            Gérer mes titres
          </Link>
        </div>
      </header>

      {error && (
        <div className="rounded-2xl border border-rose-500/30 bg-rose-500/10 p-4 text-sm text-rose-300">
          {error}
        </div>
      )}

      {successTrack && (
        <div className="rounded-3xl border border-emerald-500/40 bg-emerald-500/10 p-6 text-white shadow-xl">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
              <p className="text-xs font-semibold uppercase tracking-wider text-emerald-400">🎉 Morceau publié avec succès !</p>
              <h2 className="mt-1 text-2xl font-bold text-white">{successTrack.titre}</h2>
              <p className="mt-1 text-xs text-slate-300">Votre morceau est maintenant disponible en streaming pour tous les auditeurs.</p>
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => {
                  playChanson({
                    id: successTrack.id,
                    titre: successTrack.titre,
                    duree: Number(duree),
                    genre: "Afrobeat",
                    audioUrl: "",
                    coverImage: undefined,
                    nbEcoutes: 0,
                    artisteId: user?.id || 0,
                    artisteNom: user?.username || "Artiste",
                    albumId: undefined,
                    albumTitre: undefined,
                  });
                }}
                className="flex items-center gap-2 rounded-2xl bg-orange-500 px-5 py-3 text-sm font-bold text-white shadow-lg shadow-orange-500/30 transition hover:brightness-110"
              >
                <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M8 5v14l11-7z" />
                </svg>
                <span>Écouter maintenant</span>
              </button>
              <Link
                href="/artist/music"
                className="rounded-2xl border border-slate-700 bg-slate-900/80 px-5 py-3 text-sm font-semibold text-slate-200 hover:bg-slate-800 transition"
              >
                Voir dans mes musiques
              </Link>
            </div>
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="grid gap-6 md:grid-cols-2">
          {/* Zone Fichier Audio (Obligatoire) */}
          <div className="flex flex-col gap-3">
            <div
              onClick={() => audioInputRef.current?.click()}
              className={[
                "cursor-pointer rounded-3xl border-2 border-dashed p-6 transition text-center flex flex-col items-center justify-center min-h-[190px]",
                audioFile
                  ? "border-orange-500/80 bg-orange-500/10 shadow-lg shadow-orange-500/5"
                  : "border-slate-700 bg-slate-900/50 hover:border-slate-600 hover:bg-slate-900/80",
              ].join(" ")}
            >
              <input
                ref={audioInputRef}
                type="file"
                accept="audio/*,.mp3,.wav,.ogg,.m4a"
                className="hidden"
                onChange={(e) => e.target.files?.[0] && handleAudioSelect(e.target.files[0])}
              />
              <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-orange-500/20 text-orange-400 mb-3">
                <svg className="h-6 w-6" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 19V6l12-3v13M9 19c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zm12-3c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zM9 10l12-3" />
                </svg>
              </div>
              <p className="text-sm font-semibold text-white">
                {audioFile ? audioFile.name : "Fichier Audio Master (.mp3, .wav)"}
              </p>
              <p className="mt-1 text-xs text-slate-400">
                {audioFile ? `${(audioFile.size / (1024 * 1024)).toFixed(2)} MB — Cliquez pour changer` : "Glissez-déposez ou cliquez pour parcourir"}
              </p>
            </div>

            {/* Pré-écoute locale */}
            {audioPreviewUrl && (
              <div className="flex items-center justify-between rounded-2xl border border-orange-500/30 bg-slate-900/90 p-3 px-4 shadow-lg">
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={togglePreviewPlay}
                    className="flex h-8 w-8 items-center justify-center rounded-full bg-orange-500 text-white"
                    title={isPreviewPlaying ? "Pause" : "Pré-écouter"}
                  >
                    {isPreviewPlaying ? (
                      <svg className="h-3.5 w-3.5" fill="currentColor" viewBox="0 0 24 24">
                        <rect x="6" y="4" width="4" height="16" rx="1" />
                        <rect x="14" y="4" width="4" height="16" rx="1" />
                      </svg>
                    ) : (
                      <svg className="h-3.5 w-3.5 ml-0.5" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M8 5v14l11-7z" />
                      </svg>
                    )}
                  </button>
                  <span className="text-xs font-semibold text-white">Pré-écoute du fichier sélectionné</span>
                </div>
                <audio
                  ref={previewAudioRef}
                  src={audioPreviewUrl}
                  onEnded={() => setIsPreviewPlaying(false)}
                  className="hidden"
                />
                <span className="text-xs text-orange-400 font-mono">{duree}s</span>
              </div>
            )}
          </div>

          {/* Zone Pochette (Optionnelle) */}
          <div
            onClick={() => coverInputRef.current?.click()}
            className={[
              "cursor-pointer rounded-3xl border-2 border-dashed p-6 transition text-center flex flex-col items-center justify-center min-h-[190px] relative overflow-hidden",
              coverPreview
                ? "border-amber-500/80 bg-slate-900/50"
                : "border-slate-700 bg-slate-900/50 hover:border-slate-600 hover:bg-slate-900/80",
            ].join(" ")}
          >
            <input
              ref={coverInputRef}
              type="file"
              accept="image/*"
              className="hidden"
              onChange={(e) => e.target.files?.[0] && handleCoverSelect(e.target.files[0])}
            />
            {coverPreview ? (
              <div className="flex flex-col items-center gap-2">
                <img src={coverPreview} alt="Aperçu pochette" className="h-20 w-20 rounded-2xl object-cover shadow-md" />
                <p className="text-xs font-semibold text-amber-400">Pochette sélectionnée (Changer)</p>
              </div>
            ) : (
              <>
                <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-amber-500/20 text-amber-400 mb-3">
                  <svg className="h-6 w-6" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                  </svg>
                </div>
                <p className="text-sm font-semibold text-white">Image de Couverture (Optionnel)</p>
                <p className="mt-1 text-xs text-slate-400">PNG ou JPG (carré recommandé 1000x1000)</p>
              </>
            )}
          </div>
        </div>

        {/* Métadonnées */}
        <div className="rounded-3xl bg-slate-900/80 p-6 ring-1 ring-slate-800 space-y-4">
          <h3 className="text-sm font-semibold uppercase tracking-wider text-orange-400">Informations du Titre</h3>

          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1.5">Titre du morceau *</label>
            <input
              required
              value={titre}
              onChange={(e) => setTitre(e.target.value)}
              placeholder="ex: Kpanlogo Night 2026"
              className="w-full rounded-2xl border border-slate-700/80 bg-slate-950/70 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition focus:border-orange-500 focus:ring-2 focus:ring-orange-500/20"
            />
          </div>

          <div className="grid gap-4 sm:grid-cols-3">
            <div>
              <label className="block text-xs font-medium text-slate-400 mb-1.5">Catégorie / Genre *</label>
              <select
                value={categorieId}
                onChange={(e) => setCategorieId(e.target.value)}
                className="w-full rounded-2xl border border-slate-700/80 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none transition focus:border-orange-500"
              >
                {categories.map((c) => (
                  <option key={c.id} value={c.id}>{c.nom}</option>
                ))}
              </select>
            </div>

            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="block text-xs font-medium text-slate-400">Album (Optionnel)</label>
                <button
                  type="button"
                  onClick={() => setShowQuickAlbum(true)}
                  className="text-[11px] font-semibold text-orange-400 hover:text-orange-300"
                >
                  + Nouvel album
                </button>
              </div>
              <select
                value={albumId}
                onChange={(e) => setAlbumId(e.target.value)}
                className="w-full rounded-2xl border border-slate-700/80 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none transition focus:border-orange-500"
              >
                <option value="">Single (aucun album)</option>
                {albums.map((a) => (
                  <option key={a.id} value={a.id}>{a.title}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xs font-medium text-slate-400 mb-1.5">Durée (en secondes)</label>
              <input
                type="number"
                value={duree}
                onChange={(e) => setDuree(e.target.value)}
                className="w-full rounded-2xl border border-slate-700/80 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none transition focus:border-orange-500"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1.5">Paroles (Optionnel)</label>
            <textarea
              rows={4}
              value={parole}
              onChange={(e) => setParole(e.target.value)}
              placeholder="Écrivez ou collez les paroles de votre chanson ici..."
              className="w-full rounded-2xl border border-slate-700/80 bg-slate-950/70 px-4 py-3 text-sm text-white placeholder-slate-500 outline-none transition focus:border-orange-500"
            />
          </div>
        </div>

        {/* Bouton de Soumission */}
        <div className="flex gap-4">
          <Link
            href="/artist/music"
            className="flex-1 rounded-2xl border border-slate-700 bg-slate-900/80 px-6 py-4 text-center text-sm font-semibold text-slate-300 hover:bg-slate-800 transition"
          >
            Annuler
          </Link>
          <button
            type="submit"
            disabled={isSubmitting || !audioFile || !titre.trim()}
            className="flex-2 rounded-2xl bg-gradient-to-r from-orange-500 to-orange-600 px-8 py-4 text-sm font-bold text-white shadow-xl shadow-orange-500/25 transition hover:brightness-110 disabled:opacity-50"
          >
            {isSubmitting ? "Upload et Publication en cours..." : "🚀 Publier le morceau sur Titan Tunes"}
          </button>
        </div>
      </form>

      {/* Modal Création rapide d'album */}
      {showQuickAlbum && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm p-4">
          <div className="w-full max-w-md rounded-3xl border border-slate-800 bg-slate-900 p-6 shadow-2xl space-y-4">
            <h3 className="text-lg font-bold text-white">Créer un nouvel Album</h3>
            <input
              value={newAlbumTitle}
              onChange={(e) => setNewAlbumTitle(e.target.value)}
              placeholder="Titre de l'album (ex: Lomé Nights)"
              className="w-full rounded-2xl border border-slate-700 bg-slate-950 px-4 py-3 text-sm text-white outline-none focus:border-orange-500"
            />
            <div className="flex gap-3 pt-2">
              <button
                type="button"
                onClick={() => setShowQuickAlbum(false)}
                className="flex-1 rounded-2xl border border-slate-700 px-4 py-2.5 text-xs font-semibold text-slate-300 hover:text-white"
              >
                Annuler
              </button>
              <button
                type="button"
                onClick={handleCreateQuickAlbum}
                disabled={creatingAlbum || !newAlbumTitle.trim()}
                className="flex-1 rounded-2xl bg-orange-500 px-4 py-2.5 text-xs font-bold text-white hover:brightness-110 disabled:opacity-50"
              >
                {creatingAlbum ? "Création..." : "Créer"}
              </button>
            </div>
          </div>
        </div>
      )}
    </section>
  );
}
