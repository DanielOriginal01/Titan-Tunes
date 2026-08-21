import api from "@/services/api";
import endpoints from "@/lib/api/endpoints";
import type {
  ArtisteResponse,
  ArtisteDashboard,
  ChansonResponse,
  AlbumResponse,
  EvenementResponse,
  BanniereResponse,
  BanniereTypePromotion,
  PageResponse,
  ReversementResponse,
  ReversementTotalData,
  CategorieResponse,
} from "@/types/api";

function extractContent<T>(payload: PageResponse<T> | T[] | unknown): T[] {
  if (!payload) return [];
  if (Array.isArray(payload)) return payload;
  if (typeof payload === "object" && payload !== null && "content" in payload && Array.isArray((payload as PageResponse<T>).content)) {
    return (payload as PageResponse<T>).content;
  }
  return [];
}

// ─── Profil artiste ───────────────────────────────────────────────────────────

export async function getArtisteById(id: number): Promise<ArtisteResponse> {
  return api.get<ArtisteResponse>(endpoints.artistes.byId(id));
}

export async function updateArtiste(id: number, payload: Partial<ArtisteResponse>): Promise<ArtisteResponse> {
  return api.put<ArtisteResponse>(endpoints.artistes.update(id), payload);
}

export async function getAllArtistes(): Promise<ArtisteResponse[]> {
  try {
    const res = await api.get<PageResponse<ArtisteResponse> | ArtisteResponse[]>(endpoints.artistes.list);
    return extractContent(res);
  } catch {
    return [];
  }
}

/**
 * Retourne l'URL publique de la photo de profil d'un artiste.
 * GET /artistes/{id}/photo/url → string
 */
export async function getArtistePhotoUrl(id: number): Promise<string | null> {
  try {
    const url = await api.get<string>(endpoints.artistes.photoUrl(id));
    return url ?? null;
  } catch {
    return null;
  }
}

/**
 * Téléverse une photo de profil artiste vers MinIO.
 * POST /artistes/{id}/photo
 */
export async function uploadArtistePhoto(id: number, file: File): Promise<ArtisteResponse> {
  const formData = new FormData();
  formData.append("photo", file);
  return api.post<ArtisteResponse>(endpoints.artistes.uploadPhoto(id), formData);
}

/**
 * Charge le profil complet d'un artiste ET son URL de photo en parallèle.
 */
export async function getArtisteProfile(id: number): Promise<{
  profil: ArtisteResponse;
  photoUrl: string | null;
}> {
  try {
    const [profil, photoUrl] = await Promise.all([
      getArtisteById(id),
      getArtistePhotoUrl(id),
    ]);
    return { profil, photoUrl };
  } catch {
    return {
      profil: {
        id,
        nom: "Artiste",
        prenom: "",
        username: "Artiste",
        email: "",
        role: "ROLE_ARTISTE",
        verifie: false,
      } as unknown as ArtisteResponse,
      photoUrl: null,
    };
  }
}

// ─── Dashboard artiste ────────────────────────────────────────────────────────

export async function getArtisteDashboard(id: number): Promise<ArtisteDashboard> {
  try {
    return await api.get<ArtisteDashboard>(endpoints.artistes.dashboard(id));
  } catch {
    return {
      totalEcoutes: 0,
      auditeursUniques: 0,
      totalChansons: 0,
      totalAlbums: 0,
      royaltiesEstimees: 0,
      totalFavoris: 0,
      partCatalogue: "—",
    };
  }
}

// ─── Chansons ─────────────────────────────────────────────────────────────────

export async function getAllChansons(page = 0, size = 100): Promise<ChansonResponse[]> {
  try {
    const res = await api.get<PageResponse<ChansonResponse> | ChansonResponse[]>(endpoints.chansons.list, {
      params: { page, size, sort: "id,desc" },
    });
    return extractContent(res);
  } catch {
    return [];
  }
}

export async function getChansonsByArtiste(artisteId: number, page = 0, size = 100): Promise<ChansonResponse[]> {
  try {
    const res = await api.get<PageResponse<ChansonResponse> | ChansonResponse[]>(endpoints.chansons.byArtiste(artisteId), {
      params: { page, size, sort: "id,desc" },
    });
    return extractContent(res);
  } catch {
    return [];
  }
}

export async function getChansonById(id: number): Promise<ChansonResponse> {
  return api.get<ChansonResponse>(endpoints.chansons.byId(id));
}

export async function getChansonStreamUrl(id: number): Promise<string> {
  return api.get<string>(endpoints.chansons.stream(id));
}

export async function rechercheChanson(query: string): Promise<ChansonResponse[]> {
  try {
    const res = await api.get<PageResponse<ChansonResponse> | ChansonResponse[]>(endpoints.chansons.recherche, {
      params: { query },
    });
    return extractContent(res);
  } catch {
    return [];
  }
}

export async function getTendances(): Promise<ChansonResponse[]> {
  try {
    const res = await api.get<PageResponse<ChansonResponse> | ChansonResponse[]>(endpoints.chansons.tendances);
    return extractContent(res);
  } catch {
    return [];
  }
}

export async function deleteChanson(id: number): Promise<void> {
  return api.delete(endpoints.chansons.delete(id));
}

export interface PublierChansonPayload {
  titre: string;
  duree: number;
  artisteId?: number;
  categorieId: number;
  albumId?: number;
  parole?: string;
  coverImage?: string;
}

function appendJsonField(form: FormData, fieldName: string, value: unknown) {
  form.append(
    fieldName,
    new Blob([JSON.stringify(value)], { type: "application/json" }),
  );
}

export async function publierChanson(
  payload: PublierChansonPayload,
  audioFile: File,
  coverFile?: File | null,
): Promise<ChansonResponse> {
  const form = new FormData();

  const metadata = {
    titre: payload.titre,
    duree: payload.duree,
    artisteId: payload.artisteId ?? null,
    categorieId: payload.categorieId,
    albumId: payload.albumId ?? null,
    parole: payload.parole ?? null,
    coverImage: payload.coverImage ?? null,
  };

  appendJsonField(form, "data", metadata);
  form.append("file", audioFile, audioFile.name);
  if (coverFile) {
    form.append("cover", coverFile, coverFile.name);
  }

  return api.post<ChansonResponse>(endpoints.chansons.publier, form);
}

// ─── Albums ───────────────────────────────────────────────────────────────────

export async function getAlbumsByArtiste(artisteId: number): Promise<AlbumResponse[]> {
  try {
    const res = await api.get<PageResponse<AlbumResponse> | AlbumResponse[]>(endpoints.albums.byArtiste(artisteId));
    return extractContent(res);
  } catch {
    return [];
  }
}

export async function getAlbumById(id: number): Promise<AlbumResponse> {
  return api.get<AlbumResponse>(endpoints.albums.byId(id));
}

export interface CreateAlbumPayload {
  title: string;
  dateSortie?: string;
  coverImage?: string;
  artisteId?: number;
}

export async function createAlbum(
  payload: CreateAlbumPayload,
  coverFile?: File | null,
): Promise<AlbumResponse> {
  if (coverFile) {
    const form = new FormData();
    const dataBlob = new Blob(
      [
        JSON.stringify({
          title: payload.title,
          dateSortie: payload.dateSortie ?? new Date().toISOString().split("T")[0],
          coverImage: payload.coverImage ?? null,
          artisteId: payload.artisteId ?? null,
        }),
      ],
      { type: "application/json" },
    );
    form.append("data", dataBlob);
    form.append("cover", coverFile);
    return api.post<AlbumResponse>("/albums/publier", form);
  }

  return api.post<AlbumResponse>(endpoints.albums.create, {
    title: payload.title,
    dateSortie: payload.dateSortie ?? new Date().toISOString().split("T")[0],
    coverImage: payload.coverImage ?? null,
    artisteId: payload.artisteId,
  });
}

export async function deleteAlbum(id: number): Promise<void> {
  return api.delete(endpoints.albums.delete(id));
}

export async function getAllCategories(): Promise<CategorieResponse[]> {
  try {
    const res = await api.get<PageResponse<CategorieResponse> | CategorieResponse[]>(endpoints.categories.list);
    return extractContent(res);
  } catch {
    return [
      { id: 1, nom: "Afrobeat" },
      { id: 2, nom: "Hip-Hop / Rap" },
      { id: 3, nom: "Gospel" },
      { id: 4, nom: "Coupé-Décalé" },
      { id: 5, nom: "Reggae" },
      { id: 6, nom: "R&B / Soul" },
      { id: 7, nom: "Pop Africaine" },
      { id: 8, nom: "Highlife" },
      { id: 9, nom: "Afro-Pop" },
      { id: 10, nom: "Musique Traditionnelle" },
    ];
  }
}

// ─── Événements ───────────────────────────────────────────────────────────────

export async function getEvenementsByArtiste(artisteId: number): Promise<EvenementResponse[]> {
  try {
    const res = await api.get<PageResponse<EvenementResponse> | EvenementResponse[]>(endpoints.evenements.byArtiste(artisteId));
    return extractContent(res);
  } catch {
    return [];
  }
}

export async function getAllEvenements(): Promise<EvenementResponse[]> {
  try {
    const res = await api.get<PageResponse<EvenementResponse> | EvenementResponse[]>(endpoints.evenements.list);
    return extractContent(res);
  } catch {
    return [];
  }
}

export async function createEvenement(payload: Omit<EvenementResponse, "idEvenement">): Promise<EvenementResponse> {
  return api.post<EvenementResponse>(endpoints.evenements.create, payload);
}

export async function deleteEvenement(id: number): Promise<void> {
  return api.delete(endpoints.evenements.delete(id));
}

export async function updateEvenement(
  id: number,
  payload: Partial<Omit<EvenementResponse, "idEvenement">>,
): Promise<EvenementResponse> {
  return api.put<EvenementResponse>(endpoints.evenements.byId(id), payload);
}

// ─── Reversements & Royalties ─────────────────────────────────────────────────

export async function getReversementsByArtiste(
  artisteId: number,
  page = 0,
  size = 20,
): Promise<PageResponse<ReversementResponse>> {
  return api.get<PageResponse<ReversementResponse>>(endpoints.reversements.byArtiste(artisteId), {
    params: { page, size, sort: "id,desc" },
  });
}

export async function getTotalReversements(artisteId: number): Promise<ReversementTotalData> {
  return api.get<ReversementTotalData>(endpoints.reversements.totalByArtiste(artisteId));
}

export async function calculerReversements(artisteId: number, periode?: string): Promise<ReversementResponse> {
  return api.post<ReversementResponse>(endpoints.reversements.calculerArtiste(artisteId), null, {
    params: { periode: periode ?? "" },
  });
}

// ─── Bannières ────────────────────────────────────────────────────────────────

export async function getBanniersByArtiste(artisteId: number): Promise<BanniereResponse[]> {
  const res = await api.get<PageResponse<BanniereResponse> | BanniereResponse[]>(endpoints.bannieres.byArtiste(artisteId));
  return extractContent(res);
}

export async function getBannierById(id: number): Promise<BanniereResponse> {
  return api.get<BanniereResponse>(endpoints.bannieres.byId(id));
}

export async function getActiveBannieres(): Promise<BanniereResponse[]> {
  const res = await api.get<PageResponse<BanniereResponse> | BanniereResponse[]>(endpoints.bannieres.actives);
  return extractContent(res);
}

export interface CreateBannierePayload {
  titre: string;
  description?: string;
  lienCible?: string;
  typePromotion: BanniereTypePromotion;
  artisteId: number;
  albumId?: number;
  chansonId?: number;
  dateDebut?: string;
  dateFin?: string;
}

export async function createBanniere(
  data: CreateBannierePayload,
  imageFile: File,
): Promise<BanniereResponse> {
  const form = new FormData();
  form.append("data", JSON.stringify(data));
  form.append("image", imageFile);
  return api.post<BanniereResponse>(endpoints.bannieres.create, form);
}

export async function activerBanniere(id: number): Promise<BanniereResponse> {
  return api.put<BanniereResponse>(endpoints.bannieres.activer(id), {});
}

export async function desactiverBanniere(id: number): Promise<BanniereResponse> {
  return api.put<BanniereResponse>(endpoints.bannieres.desactiver(id), {});
}

export async function deleteBanniere(id: number): Promise<void> {
  return api.delete(endpoints.bannieres.delete(id));
}

// ─── Notifications promo (artiste → tous auditeurs) ───────────────────────────

export interface PromoNotifPayload {
  titre: string;
  message: string;
  typePromotion: BanniereTypePromotion;
}

export async function envoyerNotifPromo(
  artisteId: number,
  payload: PromoNotifPayload,
): Promise<void> {
  await api.post(endpoints.notifications.promoArtiste(artisteId), payload);
}

