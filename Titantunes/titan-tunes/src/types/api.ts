// ─── Enveloppe générique ──────────────────────────────────────────────────────

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  status: number;
  timestamp: string;
}

export interface PageResponse<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  first: boolean;
  last: boolean;
  empty: boolean;
}

// ─── Auth ─────────────────────────────────────────────────────────────────────

/** Réponse du POST /auth/login */
export interface AuthLoginData {
  token: string;
  type: "Bearer";
  id: number;
  username: string;
  email: string;
  role: string;
  photoProfil?: string;
  refreshToken?: string;
}

/** Réponse du POST /auth/register */
export interface AuthRegisterData {
  message: string;
  success: boolean;
}

// ─── Artiste ──────────────────────────────────────────────────────────────────

export interface ArtisteResponse {
  id: number;
  username: string;
  email: string;
  artistName?: string;
  bio?: string;
  photoProfil?: string;
  photoCouverture?: string;
  verifie: boolean;
}

/** Réponse de GET /artistes/{id}/dashboard */
export interface ArtisteDashboard {
  totalEcoutes: number;
  auditeursUniques: number;
  totalChansons: number;
  totalAlbums: number;
  totalFavoris: number;
  royaltiesEstimees: number;
  partCatalogue: string;
}

// ─── Chanson ──────────────────────────────────────────────────────────────────

export interface ChansonResponse {
  id: number;
  titre: string;
  duree?: number;
  genre?: string;
  audioUrl?: string;
  coverImage?: string | null;
  coverUrl?: string;
  nbEcoutes: number;
  artisteId?: number;
  artisteNom?: string;
  albumId?: number;
  albumTitre?: string;
}

// ─── Album ────────────────────────────────────────────────────────────────────

export interface AlbumResponse {
  id: number;
  title: string;
  dateSortie?: string;
  coverImage?: string;
  artisteId?: number;
  artiste?: string;
  chansons?: ChansonResponse[];
}

export interface CreateAlbumPayload {
  title: string;
  dateSortie?: string;
  coverImage?: string;
  artisteId: number;
}

export interface CategorieResponse {
  id: number;
  nom: string;
}

// ─── Reversements & Royalties ─────────────────────────────────────────────────

export interface ReversementResponse {
  id: number;
  montant: number;
  periode?: string;
  dateVersement?: string;
  statut?: string;
  reference?: string;
  createdAt?: string;
  artisteId?: number;
  artisteName?: string;
  labelId?: number;
  labelName?: string;
}

export interface ReversementTotalData {
  artisteId?: number;
  totalVerse?: number;
  total?: number;
  [key: string]: unknown;
}

// ─── Admin ────────────────────────────────────────────────────────────────────

/** GET /admin/dashboard/metriques */
export interface AdminMetriques {
  totalUtilisateurs: number;
  totalArtistes: number;
  totalAuditeurs: number;
  totalAdmins: number;
}

/** GET /admin/dashboard/finances */
export interface AdminFinances {
  totalRevenus: number;
  totalTransactions: number;
  royaltiesArtistes: number;
  revenusNets: number;
}

// ─── Utilisateurs (admin & général) ──────────────────────────────────────────

export type StatutUtilisateur = "ACTIF" | "INACTIF" | "SUPPRIME";

export interface UtilisateurAdmin {
  id: number;
  username: string;
  email: string;
  telephone?: string;
  role: string;
  statut: StatutUtilisateur;
  photoProfil?: string;
  createdAt?: string;
  artistName?: string;
}

export interface UtilisateurResponse {
  id: number;
  username: string;
  email: string;
  telephone?: string;
  role: string;
  statut: string;
  photoProfil?: string;
}

// ─── Label ────────────────────────────────────────────────────────────────────

export interface Label {
  id?: number;
  idLabel?: number;
  nom?: string;
  labelName?: string;
  description?: string;
  createdAt?: string;
}

// ─── Notification ─────────────────────────────────────────────────────────────

export interface Notification {
  id: number;
  titre?: string;
  message: string;
  lu: boolean;
  type?: string;
  createdAt?: string;
}

/** Bannière promotionnelle */
export type BanniereTypePromotion = "ALBUM" | "SINGLE" | "TOURNEE" | "GENERAL";

export interface BanniereResponse {
  id: number;
  titre: string;
  description?: string;
  lienCible?: string;
  imageUrl?: string;
  typePromotion: BanniereTypePromotion;
  artisteId?: number;
  albumId?: number;
  chansonId?: number;
  dateDebut?: string;
  dateFin?: string;
  active: boolean;
}

export interface EvenementResponse {
  idEvenement: number;
  nameConcert: string;
  dateEvenement: string;
  dateLimite?: string;
  lieu: string;
  prixTicket: number;
  artistName?: string;
}
