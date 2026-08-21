import api from "@/services/api";
import endpoints from "@/lib/api/endpoints";
import type { Label, PageResponse } from "@/types/api";

function extractContent<T>(payload: PageResponse<T> | T[] | unknown): T[] {
  if (!payload) return [];
  if (Array.isArray(payload)) return payload;
  if (typeof payload === "object" && payload !== null && "content" in payload && Array.isArray((payload as PageResponse<T>).content)) {
    return (payload as PageResponse<T>).content;
  }
  return [];
}

export async function getAllLabels(): Promise<Label[]> {
  const res = await api.get<PageResponse<Label> | Label[]>(endpoints.labels.list);
  return extractContent(res);
}

export async function getLabelById(id: number): Promise<Label> {
  return api.get<Label>(endpoints.labels.byId(id));
}

export async function createLabel(payload: { nom: string; description?: string }): Promise<Label> {
  return api.post<Label>(endpoints.labels.create, payload);
}

export async function deleteLabel(id: number): Promise<void> {
  await api.delete(endpoints.labels.delete(id));
}

export const labelService = { getAllLabels, getLabelById, createLabel, deleteLabel };
export default labelService;

