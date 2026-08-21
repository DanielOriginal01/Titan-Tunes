"use client";

import React, { useState } from "react";
import { useAudioPlayer } from "@/providers/AudioPlayerProvider";

function formatTime(seconds: number): string {
  if (isNaN(seconds) || seconds < 0) return "0:00";
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${mins}:${secs.toString().padStart(2, "0")}`;
}

export function FloatingAudioPlayer() {
  const {
    currentChanson,
    isPlaying,
    isLoading,
    currentTime,
    duration,
    volume,
    isMuted,
    togglePlayPause,
    seek,
    setVolume,
    toggleMute,
    skipForward,
    skipBackward,
    playNext,
    playPrevious,
    closePlayer,
    getCoverUrl,
  } = useAudioPlayer();

  const [isMinimized, setIsMinimized] = useState(false);
  const [coverErr, setCoverErr]       = useState(false);

  if (!currentChanson) return null;

  const progressPercent = duration > 0 ? (currentTime / duration) * 100 : 0;
  const coverSrc = coverErr ? null : getCoverUrl(currentChanson);

  if (isMinimized) {
    return (
      <aside
        aria-label="Mini lecteur audio"
        className="fixed bottom-6 right-6 z-50 flex items-center gap-3 rounded-full border border-orange-500/40 bg-slate-950/90 px-4 py-2.5 shadow-2xl backdrop-blur-xl transition-all hover:scale-105"
      >
        <button
          onClick={() => togglePlayPause()}
          className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-orange-500 text-white shadow-lg shadow-orange-500/30"
          title={isPlaying ? "Pause" : "Lecture"}
        >
          {isPlaying ? (
            <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
              <rect x="6" y="4" width="4" height="16" rx="1" />
              <rect x="14" y="4" width="4" height="16" rx="1" />
            </svg>
          ) : (
            <svg className="h-4 w-4 ml-0.5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M8 5v14l11-7z" />
            </svg>
          )}
        </button>

        <div className="max-w-[140px] truncate" onClick={() => setIsMinimized(false)}>
          <p className="truncate text-xs font-semibold text-white">{currentChanson.titre}</p>
          <p className="truncate text-[10px] text-slate-400">{currentChanson.artisteNom || "Titan Tunes"}</p>
        </div>

        <button
          onClick={() => setIsMinimized(false)}
          className="rounded-full p-1.5 text-slate-400 hover:bg-slate-800 hover:text-white"
          title="Agrandir"
        >
          <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" />
          </svg>
        </button>
      </aside>
    );
  }

  return (
    <aside
      aria-label="Lecteur audio principal"
      className="fixed bottom-4 left-4 right-4 z-50 md:left-64 md:right-8 flex flex-col gap-2 rounded-3xl border border-orange-500/30 bg-slate-950/92 p-4 shadow-2xl shadow-orange-950/40 backdrop-blur-2xl transition-all"
    >
      {/* Barre de progression supérieure */}
      <div className="relative flex items-center gap-2 px-1">
        <span className="text-[11px] font-mono text-slate-400 w-10 text-right">
          {formatTime(currentTime)}
        </span>
        <div className="group relative flex-1 flex items-center h-4 cursor-pointer">
          <input
            type="range"
            min={0}
            max={duration || 100}
            value={currentTime}
            onChange={(e) => seek(Number(e.target.value))}
            className="h-1.5 w-full cursor-pointer appearance-none rounded-full bg-slate-800 accent-orange-500 transition group-hover:h-2"
          />
          <div
            className="pointer-events-none absolute left-0 h-1.5 rounded-full bg-gradient-to-r from-orange-600 to-orange-400 group-hover:h-2"
            style={{ width: `${progressPercent}%` }}
          />
        </div>
        <span className="text-[11px] font-mono text-slate-400 w-10">
          {formatTime(duration)}
        </span>
      </div>

      {/* Contenu principal */}
      <div className="flex items-center justify-between gap-4">
        {/* Infos du titre & Pochette */}
        <div className="flex items-center gap-3 min-w-0 flex-1 md:flex-initial md:w-64">
          <div className="relative flex h-12 w-12 shrink-0 items-center justify-center overflow-hidden rounded-2xl bg-orange-500/20 text-orange-400 ring-1 ring-orange-500/30">
            {coverSrc ? (
              <img
                src={coverSrc}
                alt={currentChanson.titre}
                onError={() => setCoverErr(true)}
                className={`h-full w-full object-cover transition-transform duration-700 ${isPlaying ? "scale-105" : ""}`}
              />
            ) : (
              <svg className={`h-6 w-6 ${isPlaying ? "animate-pulse" : ""}`} fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 19V6l12-3v13M9 19c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zm12-3c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zM9 10l12-3" />
              </svg>
            )}
            {isPlaying && (
              <span className="absolute bottom-1 right-1 flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-orange-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-orange-500"></span>
              </span>
            )}
          </div>

          <div className="min-w-0">
            <p className="truncate text-sm font-bold text-white tracking-tight">{currentChanson.titre}</p>
            <div className="flex items-center gap-1.5 text-xs text-slate-400">
              <span className="truncate text-orange-400 font-medium">{currentChanson.artisteNom || "Artiste Titan"}</span>
              {currentChanson.genre && (
                <>
                  <span>•</span>
                  <span className="truncate">{currentChanson.genre}</span>
                </>
              )}
            </div>
          </div>
        </div>

        {/* Contrôles Centraux */}
        <div className="flex items-center gap-2 sm:gap-4">
          <button
            onClick={() => playPrevious()}
            className="hidden sm:flex h-9 w-9 items-center justify-center rounded-full text-slate-400 transition hover:bg-slate-800 hover:text-white"
            title="Précédent"
          >
            <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
              <path d="M6 6h2v12H6zm3.5 6l8.5 6V6z" />
            </svg>
          </button>

          <button
            onClick={() => skipBackward(10)}
            className="flex h-9 w-9 items-center justify-center rounded-full text-slate-400 transition hover:bg-slate-800 hover:text-white"
            title="Reculer de 10s"
          >
            <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M12.066 11.2a1 1 0 000 1.6l5.334 4A1 1 0 0019 16V8a1 1 0 00-1.6-.8l-5.334 4zM4.066 11.2a1 1 0 000 1.6l5.334 4A1 1 0 0011 16V8a1 1 0 00-1.6-.8l-5.334 4z" />
            </svg>
          </button>

          <button
            onClick={() => togglePlayPause()}
            disabled={isLoading}
            className="flex h-12 w-12 items-center justify-center rounded-full bg-gradient-to-tr from-orange-600 to-orange-400 text-white shadow-xl shadow-orange-500/30 transition hover:scale-105 active:scale-95 disabled:opacity-75"
            title={isPlaying ? "Mettre en pause" : "Écouter"}
          >
            {isLoading ? (
              <div className="h-5 w-5 animate-spin rounded-full border-2 border-white border-t-transparent" />
            ) : isPlaying ? (
              <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                <rect x="6" y="4" width="4" height="16" rx="1.5" />
                <rect x="14" y="4" width="4" height="16" rx="1.5" />
              </svg>
            ) : (
              <svg className="h-5 w-5 ml-0.5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M8 5v14l11-7z" />
              </svg>
            )}
          </button>

          <button
            onClick={() => skipForward(10)}
            className="flex h-9 w-9 items-center justify-center rounded-full text-slate-400 transition hover:bg-slate-800 hover:text-white"
            title="Avancer de 10s"
          >
            <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M11.933 12.8a1 1 0 000-1.6L6.6 7.2A1 1 0 005 8v8a1 1 0 001.6.8l5.333-4zM19.933 12.8a1 1 0 000-1.6l-5.333-4A1 1 0 0013 8v8a1 1 0 001.6.8l5.333-4z" />
            </svg>
          </button>

          <button
            onClick={() => playNext()}
            className="hidden sm:flex h-9 w-9 items-center justify-center rounded-full text-slate-400 transition hover:bg-slate-800 hover:text-white"
            title="Suivant"
          >
            <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
              <path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z" />
            </svg>
          </button>
        </div>

        {/* Contrôles Volume & Options */}
        <div className="flex items-center gap-3">
          {/* Badge Streaming Direct */}
          <div className="hidden lg:flex items-center gap-1.5 rounded-full bg-orange-500/10 px-3 py-1 text-[11px] font-semibold text-orange-400 ring-1 ring-orange-500/20">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-400 animate-pulse" />
            <span>Streaming HD</span>
          </div>

          {/* Volume */}
          <div className="hidden sm:flex items-center gap-2">
            <button
              onClick={() => toggleMute()}
              className="rounded-full p-1.5 text-slate-400 hover:bg-slate-800 hover:text-white transition"
              title={isMuted ? "Activer le son" : "Couper le son"}
            >
              {isMuted || volume === 0 ? (
                <svg className="h-4 w-4 text-rose-400" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
                  <path strokeLinecap="round" strokeLinejoin="round" d="M17 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2" />
                </svg>
              ) : volume < 0.5 ? (
                <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
                </svg>
              ) : (
                <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
                </svg>
              )}
            </button>
            <input
              type="range"
              min={0}
              max={1}
              step={0.01}
              value={isMuted ? 0 : volume}
              onChange={(e) => setVolume(Number(e.target.value))}
              className="h-1.5 w-16 cursor-pointer appearance-none rounded-full bg-slate-800 accent-orange-500 transition hover:h-2"
            />
          </div>

          {/* Minimiser */}
          <button
            onClick={() => setIsMinimized(true)}
            className="rounded-full p-1.5 text-slate-400 hover:bg-slate-800 hover:text-white transition"
            title="Minimiser"
          >
            <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
            </svg>
          </button>

          {/* Fermer */}
          <button
            onClick={() => closePlayer()}
            className="rounded-full p-1.5 text-slate-400 hover:bg-rose-500/20 hover:text-rose-300 transition"
            title="Fermer le lecteur"
          >
            <svg className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
    </aside>
  );
}
