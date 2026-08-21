import api from "@/services/api";
import endpoints from "@/lib/api/endpoints";
import type { Notification, PageResponse } from "@/types/api";

function extractContent<T>(payload: PageResponse<T> | T[] | unknown): T[] {
  if (!payload) return [];
  if (Array.isArray(payload)) return payload;
  if (typeof payload === "object" && payload !== null && "content" in payload && Array.isArray((payload as PageResponse<T>).content)) {
    return (payload as PageResponse<T>).content;
  }
  return [];
}

export async function getAllNotifications(): Promise<Notification[]> {
  try {
    const res = await api.get<PageResponse<Notification> | Notification[]>(endpoints.notifications.list);
    return extractContent(res);
  } catch {
    return [];
  }
}

export async function createNotification(payload: {
  titre?: string;
  message: string;
  type?: string;
}): Promise<Notification> {
  return api.post<Notification>(endpoints.notifications.create, payload);
}

export async function marquerCommeLue(id: number): Promise<Notification> {
  return api.put<Notification>(endpoints.notifications.markRead(id), {});
}

export async function deleteNotification(id: number): Promise<void> {
  await api.delete(endpoints.notifications.delete(id));
}

export const notificationService = {
  getAllNotifications,
  createNotification,
  marquerCommeLue,
  deleteNotification,
};
export default notificationService;

