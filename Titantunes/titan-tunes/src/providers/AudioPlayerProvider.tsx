"use client";

import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  useRef,
  useCallback,
} from "react";
import type { ChansonResponse } from "@/types/api";
import { API_BASE_URL } from "@/services/api";

interface AudioPlayerContextType {
  currentChanson: ChansonResponse | null;
  isPlaying: boolean;
  isLoading: boolean;
  currentTime: number;
  duration: number;
  volume: number;
  isMuted: boolean;
  queue: ChansonResponse[];
  playChanson: (chanson: ChansonResponse, newQueue?: ChansonResponse[]) => void;
  pauseChanson: () => void;
  togglePlayPause: (chanson?: ChansonResponse) => void;
  seek: (timeInSeconds: number) => void;
  setVolume: (vol: number) => void;
  toggleMute: () => void;
  skipForward: (seconds?: number) => void;
  skipBackward: (seconds?: number) => void;
  playNext: () => void;
  playPrevious: () => void;
  closePlayer: () => void;
  getCoverUrl: (chanson: ChansonResponse) => string;
}

const AudioPlayerContext = createContext<AudioPlayerContextType | undefined>(
  undefined,
);

export function AudioPlayerProvider({ children }: { children: React.ReactNode }) {
  const [currentChanson, setCurrentChanson] = useState<ChansonResponse | null>(null);
  const [isPlaying, setIsPlaying]           = useState(false);
  const [isLoading, setIsLoading]           = useState(false);
  const [currentTime, setCurrentTime]       = useState(0);
  const [duration, setDuration]             = useState(0);
  const [volume, setVolumeState]            = useState(0.85);
  const [isMuted, setIsMuted]               = useState(false);
  const [queue, setQueue]                   = useState<ChansonResponse[]>([]);

  const audioRef = useRef<HTMLAudioElement | null>(null);
  const hasTrackedPlayRef = useRef(false);

  // Initialisation de l'objet Audio unique
  useEffect(() => {
    const audio = new Audio();
    audio.preload = "auto";
    audioRef.current = audio;

    const onTimeUpdate = () => {
      setCurrentTime(audio.currentTime);
      // Compte d'écoute après 30s
      if (audio.currentTime >= 30 && !hasTrackedPlayRef.current) {
        hasTrackedPlayRef.current = true;
        trackEcouteAsync(currentChanson?.id, audio.currentTime);
      }
    };

    const onLoadedMetadata = () => {
      if (audio.duration && !isNaN(audio.duration)) {
        setDuration(audio.duration);
      }
      setIsLoading(false);
    };

    const onPlaying = () => {
      setIsPlaying(true);
      setIsLoading(false);
    };

    const onPause = () => {
      setIsPlaying(false);
    };

    const onWaiting = () => {
      setIsLoading(true);
    };

    const onEnded = () => {
      setIsPlaying(false);
      setCurrentTime(0);
      playNext();
    };

    const onError = (e: Event) => {
      console.warn("Erreur de flux audio :", e);
      setIsLoading(false);
      setIsPlaying(false);
    };

    audio.addEventListener("timeupdate", onTimeUpdate);
    audio.addEventListener("loadedmetadata", onLoadedMetadata);
    audio.addEventListener("playing", onPlaying);
    audio.addEventListener("pause", onPause);
    audio.addEventListener("waiting", onWaiting);
    audio.addEventListener("ended", onEnded);
    audio.addEventListener("error", onError);

    return () => {
      audio.pause();
      audio.removeEventListener("timeupdate", onTimeUpdate);
      audio.removeEventListener("loadedmetadata", onLoadedMetadata);
      audio.removeEventListener("playing", onPlaying);
      audio.removeEventListener("pause", onPause);
      audio.removeEventListener("waiting", onWaiting);
      audio.removeEventListener("ended", onEnded);
      audio.removeEventListener("error", onError);
    };
  }, []);

  // Synchronisation du volume
  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.volume = isMuted ? 0 : volume;
    }
  }, [volume, isMuted]);

  const getAudioStreamUrl = (chanson: ChansonResponse): string => {
    if (chanson.audioUrl && (chanson.audioUrl.startsWith("http://") || chanson.audioUrl.startsWith("https://"))) {
      return chanson.audioUrl;
    }
    return `${API_BASE_URL}/chansons/${chanson.id}/audio`;
  };

  const getCoverUrl = (chanson: ChansonResponse): string => {
    if (chanson.coverImage && (chanson.coverImage.startsWith("http://") || chanson.coverImage.startsWith("https://"))) {
      return chanson.coverImage;
    }
    return `${API_BASE_URL}/chansons/${chanson.id}/cover`;
  };

  const trackEcouteAsync = async (chansonId?: number, duree?: number) => {
    if (!chansonId) return;
    try {
      const token = typeof window !== "undefined" ? window.localStorage.getItem("titan_token") : null;
      const userStr = typeof window !== "undefined" ? window.localStorage.getItem("titan_user") : null;
      const user = userStr ? JSON.parse(userStr) : null;
      if (token && user?.id) {
        fetch(`${API_BASE_URL}/ecoutes/async`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({
            auditeurId: user.id,
            chansonId,
            dureeEcoute: Math.round(duree || 30),
          }),
        }).catch(() => {});
      }
    } catch {
      /* ignore */
    }
  };

  const playChanson = useCallback(
    (chanson: ChansonResponse, newQueue?: ChansonResponse[]) => {
      if (!audioRef.current) return;
      hasTrackedPlayRef.current = false;

      if (newQueue && newQueue.length > 0) {
        setQueue(newQueue);
      }

      // Si c'est déjà la chanson en cours, toggle play
      if (currentChanson?.id === chanson.id) {
        if (audioRef.current.paused) {
          audioRef.current.play().catch(() => {});
        } else {
          audioRef.current.pause();
        }
        return;
      }

      setCurrentChanson(chanson);
      setIsLoading(true);
      setCurrentTime(0);
      setDuration(chanson.duree || 0);

      const streamUrl = getAudioStreamUrl(chanson);
      audioRef.current.src = streamUrl;
      audioRef.current.load();
      audioRef.current
        .play()
        .then(() => {
          setIsPlaying(true);
          setIsLoading(false);
        })
        .catch((err) => {
          console.warn("Échec lecture directe, essai stream fallback :", err);
          // Fallback présigné
          if (audioRef.current) {
            audioRef.current.src = `${API_BASE_URL}/chansons/${chanson.id}/stream`;
            audioRef.current.play().catch(() => setIsLoading(false));
          }
        });
    },
    [currentChanson],
  );

  const pauseChanson = useCallback(() => {
    if (audioRef.current) {
      audioRef.current.pause();
    }
  }, []);

  const togglePlayPause = useCallback(
    (chanson?: ChansonResponse) => {
      if (chanson && currentChanson?.id !== chanson.id) {
        playChanson(chanson);
        return;
      }
      if (!audioRef.current) return;
      if (isPlaying) {
        audioRef.current.pause();
      } else {
        audioRef.current.play().catch(() => {});
      }
    },
    [isPlaying, currentChanson, playChanson],
  );

  const seek = useCallback((timeInSeconds: number) => {
    if (audioRef.current) {
      audioRef.current.currentTime = timeInSeconds;
      setCurrentTime(timeInSeconds);
    }
  }, []);

  const setVolume = useCallback((vol: number) => {
    const clamped = Math.max(0, Math.min(1, vol));
    setVolumeState(clamped);
    if (clamped > 0) setIsMuted(false);
  }, []);

  const toggleMute = useCallback(() => {
    setIsMuted((prev) => !prev);
  }, []);

  const skipForward = useCallback((seconds = 10) => {
    if (audioRef.current) {
      const nextTime = Math.min(audioRef.current.duration || 9999, audioRef.current.currentTime + seconds);
      audioRef.current.currentTime = nextTime;
      setCurrentTime(nextTime);
    }
  }, []);

  const skipBackward = useCallback((seconds = 10) => {
    if (audioRef.current) {
      const nextTime = Math.max(0, audioRef.current.currentTime - seconds);
      audioRef.current.currentTime = nextTime;
      setCurrentTime(nextTime);
    }
  }, []);

  const playNext = useCallback(() => {
    if (!currentChanson || queue.length === 0) return;
    const currentIndex = queue.findIndex((c) => c.id === currentChanson.id);
    if (currentIndex >= 0 && currentIndex < queue.length - 1) {
      playChanson(queue[currentIndex + 1]);
    }
  }, [currentChanson, queue, playChanson]);

  const playPrevious = useCallback(() => {
    if (!currentChanson || queue.length === 0) return;
    const currentIndex = queue.findIndex((c) => c.id === currentChanson.id);
    if (currentIndex > 0) {
      playChanson(queue[currentIndex - 1]);
    } else if (audioRef.current) {
      audioRef.current.currentTime = 0;
    }
  }, [currentChanson, queue, playChanson]);

  const closePlayer = useCallback(() => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current.src = "";
    }
    setCurrentChanson(null);
    setIsPlaying(false);
    setCurrentTime(0);
  }, []);

  return (
    <AudioPlayerContext.Provider
      value={{
        currentChanson,
        isPlaying,
        isLoading,
        currentTime,
        duration,
        volume,
        isMuted,
        queue,
        playChanson,
        pauseChanson,
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
      }}
    >
      {children}
    </AudioPlayerContext.Provider>
  );
}

export function useAudioPlayer() {
  const context = useContext(AudioPlayerContext);
  if (!context) {
    throw new Error("useAudioPlayer doit être utilisé au sein d'un AudioPlayerProvider");
  }
  return context;
}
