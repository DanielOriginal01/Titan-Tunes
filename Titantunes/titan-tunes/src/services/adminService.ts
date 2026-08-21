import api from "@/services/api";
import endpoints from "@/lib/api/endpoints";
import type {
  AdminMetriques,
  AdminFinances,
  ArtisteResponse,
  UtilisateurAdmin,
  PageResponse,
} from "@/types/api";
import type { RegisterPayload } from "@/features/auth/types";

function extractContent<T>(payload: PageResponse<T> | T[] | unknown): T[] {
  if (!payload) return [];
  if (Array.isArray(payload)) return payload;
  if (typeof payload === "object" && payload !== null && "content" in payload && Array.isArray((payload as PageResponse<T>).content)) {
    return (payload as PageResponse<T>).content;
  }
  return [];
}

export async function getAdminMetriques(): Promise<AdminMetriques> {
  try {
    return await api.get<AdminMetriques>(endpoints.admin.metriques);
  } catch {
    return {
      totalUtilisateurs: 0,
      totalArtistes: 0,
      totalAuditeurs: 0,
      totalAdmins: 1,
    };
  }
}

export async function getAdminFinances(): Promise<AdminFinances> {
  try {
    return await api.get<AdminFinances>(endpoints.admin.finances);
  } catch {
    return {
      totalRevenus: 0,
      totalTransactions: 0,
      royaltiesArtistes: 0,
      revenusNets: 0,
    };
  }
}

export async function getArtistesEnAttente(): Promise<ArtisteResponse[]> {
  try {
    const res = await api.get<PageResponse<ArtisteResponse> | ArtisteResponse[]>(endpoints.admin.artistesEnAttente);
    return extractContent(res);
  } catch {
    return [];
  }
}

export async function verifierArtiste(id: number): Promise<void> {
  await api.put(endpoints.admin.verifierArtiste(id), {});
}

export async function updateStatutUtilisateur(id: number, status: string): Promise<void> {
  await api.put(endpoints.admin.updateStatut(id), null, { params: { status } });
}

/** GET /admin/utilisateurs — liste tous les utilisateurs de la plateforme */
export async function getUtilisateurs(): Promise<UtilisateurAdmin[]> {
  try {
    const res = await api.get<PageResponse<UtilisateurAdmin> | UtilisateurAdmin[]>(endpoints.admin.utilisateurs);
    return extractContent(res);
  } catch {
    return [];
  }
}

/**
 * Crée un utilisateur depuis le panneau admin.
 * Si le rôle est ROLE_ADMIN, appelle POST /auth/admin/create.
 * Si le rôle est ROLE_ARTISTE, appelle POST /auth/register.
 */
export async function createUtilisateur(payload: RegisterPayload): Promise<void> {
  const url = payload.role === "ROLE_ADMIN" ? endpoints.auth.adminCreate : endpoints.auth.register;
  await api.post(url, {
    username:   payload.username,
    email:      payload.email,
    password:   payload.password,
    telephone:  payload.telephone,
    role:       payload.role,
    artistName: payload.artistName ?? null,
  });
}

export const adminService = {
  getAdminMetriques,
  getAdminFinances,
  getArtistesEnAttente,
  verifierArtiste,
  updateStatutUtilisateur,
  getUtilisateurs,
  createUtilisateur,
};
export default adminService;

