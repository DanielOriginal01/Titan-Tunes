import { api } from "./api";
import { API_BASE_URL } from "./api";

export interface FavorisPayload {
  utilisateurId: number;
  targetId: number;
  type: "CHANSON" | "ARTISTE" | "ALBUM" | "PLAYLIST";
}

export interface FavorisResponse {
  id: number;
  targetId: number;
  type: string;
}

// ── Follow / Unfollow artiste ───────────────────────────────────────────────
export async function followArtiste(
  utilisateurId: number,
  artisteId: number
): Promise<FavorisResponse> {
  return api.post<FavorisResponse>("/favoris", {
    utilisateurId,
    targetId: artisteId,
    type: "ARTISTE",
  });
}

export async function unfollowArtiste(
  utilisateurId: number,
  artisteId: number
): Promise<void> {
  return api.delete<void>(`/favoris/user/${utilisateurId}/target/${artisteId}`, {
    params: { type: "ARTISTE" },
  });
}

export async function getFavoris(utilisateurId: number): Promise<FavorisResponse[]> {
  return api.get<FavorisResponse[]>(`/favoris/user/${utilisateurId}`);
}

// ── URL helpers: images directes depuis le backend ─────────────────────────
export function getArtisteProfilUrl(artisteId: number | string): string {
  return `${API_BASE_URL}/artistes/${artisteId}/photo-profil`;
}

export function getArtisteBanniereUrl(artisteId: number | string): string {
  return `${API_BASE_URL}/artistes/${artisteId}/photo`;
}

export function getAlbumCoverUrl(albumId: number | string): string {
  return `${API_BASE_URL}/albums/${albumId}/cover`;
}

export function getChansonCoverUrl(chansonId: number | string): string {
  return `${API_BASE_URL}/chansons/${chansonId}/cover`;
}
