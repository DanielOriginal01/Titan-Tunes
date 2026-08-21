import api from "@/services/api";
import endpoints from "@/lib/api/endpoints";
import type { ArtisteResponse } from "@/types/api";

export interface UpdateProfilePayload {
  artistName?: string;
  bio?: string;
}

export interface ChangePasswordPayload {
  currentPassword: string;
  newPassword: string;
}

export async function getArtistProfile(id: number): Promise<ArtisteResponse> {
  return api.get<ArtisteResponse>(endpoints.artistes.byId(id));
}

export async function updateArtistProfile(id: number, payload: UpdateProfilePayload): Promise<ArtisteResponse> {
  return api.put<ArtisteResponse>(endpoints.artistes.update(id), payload);
}

export async function changeArtistPassword(payload: ChangePasswordPayload): Promise<void> {
  await api.post(`/auth/change-password`, payload);
}
