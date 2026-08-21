"use client";

import { useEffect, useState, useCallback } from "react";
import { getAllChansons } from "@/services/artist";
import type { ChansonResponse } from "@/types/api";
import Link from "next/link";
import { useAudioPlayer } from "@/providers/AudioPlayerProvider";
import { followArtiste, unfollowArtiste, getFavoris, getChansonCoverUrl, getArtisteProfilUrl } from "@/services/favorisService";

function useCurrentUser() {
  if (typeof window === "undefined") return null;
  try {
    const s = window.localStorage.getItem("titan_user");
    return s ? JSON.parse(s) : null;
  } catch { return null; }
}

export default function ChansonsPage() {
  const [chansons, setChansons]               = useState<ChansonResponse[]>([]);
  const [loading, setLoading]                 = useState(true);
  const [error, setError]                     = useState<string | null>(null);
  const [followedArtists, setFollowedArtists] = useState<Set<number>>(new Set());
  const [followLoading, setFollowLoading]     = useState<Set<number>>(new Set());

  const { currentChanson, isPlaying, playChanson, togglePlayPause, getCoverUrl } = useAudioPlayer();
  const user = typeof window !== "undefined" ? useCurrentUser() : null;

  // Charge les chansons
  useEffect(() => {
    async function load() {
      setLoading(true);
      setError(null);
      try {
        const data = await getAllChansons();
        setChansons(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Impossible de charger les chansons.");
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  // Charge les artistes déjà suivis
  useEffect(() => {
    if (!user?.id) return;
    getFavoris(user.id)
      .then((favs) => {
        const artistIds = new Set<number>(
          favs.filter((f) => f.type === "ARTISTE").map((f) => f.targetId)
        );
        setFollowedArtists(artistIds);
      })
      .catch(() => {});
  }, [user?.id]);

  const handleFollow = useCallback(
    async (artisteId: number) => {
      if (!user?.id) {
        alert("Vous devez être connecté pour suivre un artiste.");
        return;
      }
      setFollowLoading((s) => new Set(s).add(artisteId));
      try {
        if (followedArtists.has(artisteId)) {
          await unfollowArtiste(user.id, artisteId);
          setFollowedArtists((s) => { const n = new Set(s); n.delete(artisteId); return n; });
        } else {
          await followArtiste(user.id, artisteId);
          setFollowedArtists((s) => new Set(s).add(artisteId));
        }
      } catch (e) {
        console.error("Follow error:", e);
      } finally {
        setFollowLoading((s) => { const n = new Set(s); n.delete(artisteId); return n; });
      }
    },
    [user?.id, followedArtists]
  );

  // Résolution de la cover
  const resolveCover = (c: ChansonResponse): string => {
    if (c.coverImage && c.coverImage.startsWith("http")) return c.coverImage;
    if (c.coverUrl && c.coverUrl.startsWith("http")) return c.coverUrl;
    return getChansonCoverUrl(c.id);
  };

  // Résolution de la photo artiste
  const resolveArtistPhoto = (artisteId?: number): string | undefined => {
    if (!artisteId) return undefined;
    return getArtisteProfilUrl(artisteId);
  };

  return (
    <main className="mx-auto max-w-6xl px-4 py-10 sm:px-6 lg:px-8 pb-32">
      <div className="mb-8 flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
        <div>
          <p className="text-sm uppercase tracking-[0.35em] text-orange-400 font-semibold">Bibliothèque</p>
          <h1 className="mt-2 text-3xl font-bold text-slate-950 dark:text-white">Catalogue Titan Tunes</h1>
          <p className="mt-1 text-sm text-slate-500 dark:text-slate-400">
            Explorez et écoutez tous les titres et singles uploadés sur la plateforme.
          </p>
        </div>
        <div className="flex gap-3">
          <Link
            href="/artist/music"
            className="rounded-2xl border border-slate-700 bg-slate-900/60 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-slate-800"
          >
            Mes musiques
          </Link>
          <Link
            href="/artist/music/upload"
            className="rounded-2xl bg-gradient-to-r from-orange-500 to-rose-500 px-5 py-2.5 text-sm font-semibold text-white shadow-lg shadow-orange-500/30 transition hover:brightness-110"
          >
            + Publier
          </Link>
        </div>
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-24">
          <div className="h-10 w-10 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
        </div>
      ) : error ? (
        <div className="rounded-[2rem] border border-rose-500/30 bg-rose-500/10 p-6 text-sm text-rose-300">{error}</div>
      ) : chansons.length === 0 ? (
        <div className="rounded-[2rem] border border-dashed border-slate-700 bg-slate-900/30 p-16 text-center">
          <p className="text-slate-400">Aucun titre disponible pour l'instant.</p>
          <Link
            href="/artist/music/upload"
            className="mt-4 inline-block rounded-2xl bg-orange-500 px-6 py-2.5 text-sm font-semibold text-white hover:brightness-110"
          >
            Publier le premier titre
          </Link>
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {chansons.map((c) => {
            const isActive  = currentChanson?.id === c.id;
            const isThisPlaying = isActive && isPlaying;
            const coverSrc  = resolveCover(c);
            const artistPhoto = resolveArtistPhoto(c.artisteId);
            const isFollowed = c.artisteId ? followedArtists.has(c.artisteId) : false;
            const isFollowBusy = c.artisteId ? followLoading.has(c.artisteId) : false;

            return (
              <div
                key={c.id}
                className={`group relative flex flex-col overflow-hidden rounded-[1.75rem] border transition-all duration-300 ${
                  isActive
                    ? "border-orange-500/60 bg-orange-500/10 shadow-xl shadow-orange-500/20"
                    : "border-slate-800/60 bg-slate-900/50 hover:border-orange-500/30 hover:shadow-lg"
                }`}
              >
                {/* Cover */}
                <div className="relative aspect-square overflow-hidden">
                  <img
                    src={coverSrc}
                    alt={c.titre}
                    onError={(e) => {
                      (e.target as HTMLImageElement).src = `https://picsum.photos/seed/${c.id}/400/400`;
                    }}
                    className={`h-full w-full object-cover transition-transform duration-500 group-hover:scale-105 ${isThisPlaying ? "scale-105" : ""}`}
                  />
                  {/* Overlay play button */}
                  <button
                    id={`play-btn-${c.id}`}
                    onClick={() => {
                      if (isActive) togglePlayPause();
                      else playChanson(c, chansons);
                    }}
                    className="absolute inset-0 flex items-center justify-center bg-black/40 opacity-0 transition-opacity group-hover:opacity-100"
                    aria-label={isThisPlaying ? "Pause" : "Écouter"}
                  >
                    <span className={`flex h-14 w-14 items-center justify-center rounded-full shadow-2xl transition-transform active:scale-95 ${isThisPlaying ? "bg-orange-500" : "bg-white"}`}>
                      {isThisPlaying ? (
                        <svg className="h-6 w-6 text-white" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>
                        </svg>
                      ) : (
                        <svg className="h-6 w-6 text-slate-900 ml-0.5" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M8 5v14l11-7z"/>
                        </svg>
                      )}
                    </span>
                  </button>

                  {/* Now playing indicator */}
                  {isThisPlaying && (
                    <div className="absolute bottom-2 right-2 flex items-center gap-1 rounded-full bg-orange-500 px-2 py-1 text-xs font-semibold text-white shadow">
                      <span className="flex gap-0.5">
                        {[...Array(3)].map((_, i) => (
                          <span key={i} className="h-2 w-0.5 animate-bounce bg-white rounded-full" style={{ animationDelay: `${i * 0.1}s` }} />
                        ))}
                      </span>
                      En cours
                    </div>
                  )}
                </div>

                {/* Info */}
                <div className="flex flex-1 flex-col gap-3 p-4">
                  <div>
                    <p className={`truncate text-sm font-semibold ${isActive ? "text-orange-400" : "text-white"}`}>
                      {c.titre}
                    </p>
                    <div className="mt-1 flex items-center gap-2">
                      {artistPhoto && c.artisteId && (
                        <img
                          src={artistPhoto}
                          alt={c.artisteNom || "Artiste"}
                          onError={(e) => {
                            (e.target as HTMLImageElement).src = `https://ui-avatars.com/api/?name=${encodeURIComponent(c.artisteNom || "A")}&background=f97316&color=fff&size=64`;
                          }}
                          className="h-5 w-5 rounded-full object-cover ring-1 ring-slate-700"
                        />
                      )}
                      <p className="truncate text-xs text-slate-400">{c.artisteNom ?? "Artiste"}</p>
                    </div>
                    {c.genre && (
                      <span className="mt-1 inline-block rounded-full bg-slate-800 px-2 py-0.5 text-xs text-slate-400">
                        {c.genre}
                      </span>
                    )}
                  </div>

                  <div className="mt-auto flex items-center gap-2">
                    {/* Bouton Écouter */}
                    <button
                      id={`listen-btn-${c.id}`}
                      onClick={() => {
                        if (isActive) togglePlayPause();
                        else playChanson(c, chansons);
                      }}
                      className={`flex-1 rounded-xl py-2 text-xs font-semibold transition ${
                        isThisPlaying
                          ? "bg-orange-500 text-white shadow shadow-orange-500/30"
                          : "bg-slate-800 text-slate-200 hover:bg-orange-500 hover:text-white"
                      }`}
                    >
                      {isThisPlaying ? "⏸ Pause" : "▶ Écouter"}
                    </button>

                    {/* Bouton Follow artiste */}
                    {c.artisteId && (
                      <button
                        id={`follow-btn-artist-${c.artisteId}`}
                        onClick={() => c.artisteId && handleFollow(c.artisteId)}
                        disabled={isFollowBusy || !user}
                        title={!user ? "Connectez-vous pour suivre un artiste" : isFollowed ? "Ne plus suivre" : "Suivre l'artiste"}
                        className={`flex h-8 w-8 items-center justify-center rounded-xl transition disabled:opacity-50 ${
                          isFollowed
                            ? "bg-orange-500 text-white shadow shadow-orange-500/30"
                            : "bg-slate-800 text-slate-400 hover:bg-orange-500/20 hover:text-orange-400"
                        }`}
                      >
                        {isFollowBusy ? (
                          <svg className="h-4 w-4 animate-spin" fill="none" viewBox="0 0 24 24">
                            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"/>
                            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
                          </svg>
                        ) : isFollowed ? (
                          <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/>
                          </svg>
                        ) : (
                          <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth="2">
                            <path strokeLinecap="round" strokeLinejoin="round" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"/>
                          </svg>
                        )}
                      </button>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </main>
  );
}
