import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from "axios";
import type { ApiResponse } from "@/types/api";

export const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080/api/v1";

const http = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
  timeout: 20000,
});

function isApiEnvelope<T>(payload: unknown): payload is ApiResponse<T> {
  return Boolean(
    payload &&
      typeof payload === "object" &&
      "success" in payload &&
      "message" in payload &&
      "data" in payload &&
      "status" in payload &&
      "timestamp" in payload,
  );
}

function unwrapResponse<T>(response: AxiosResponse<ApiResponse<T> | T>): T {
  const payload = response.data;
  if (isApiEnvelope<T>(payload)) {
    return payload.data;
  }
  return payload as T;
}

http.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  if (typeof window !== "undefined") {
    const token = window.localStorage.getItem("titan_token");
    if (token) {
      config.headers = config.headers ?? {};
      config.headers.Authorization = `Bearer ${token}`;
    }
  }

  if (config.data instanceof FormData) {
    delete config.headers["Content-Type"];
  }

  return config;
}, (error: AxiosError) => Promise.reject(error));

http.interceptors.response.use(
  (response: AxiosResponse) => response,
  (error: AxiosError) => {
    const status = error.response?.status;
    const payload = error.response?.data as { message?: string } | undefined;
    const message = payload?.message ?? error.message ?? "Une erreur est survenue.";

    if (status === 401 && typeof window !== "undefined") {
      window.localStorage.removeItem("titan_token");
      window.localStorage.removeItem("titan_user");
      window.location.href = "/auth/login";
    }

    if (status === 403) {
      console.warn("Accès interdit ", message);
    }

    return Promise.reject(new Error(message));
  },
);

export const api = {
  get: async <T>(url: string, config?: AxiosRequestConfig): Promise<T> => {
    const response = await http.get<ApiResponse<T> | T>(url, config);
    return unwrapResponse<T>(response);
  },
  post: async <T>(url: string, data?: unknown, config?: AxiosRequestConfig): Promise<T> => {
    const response = await http.post<ApiResponse<T> | T>(url, data, config);
    return unwrapResponse<T>(response);
  },
  put: async <T>(url: string, data?: unknown, config?: AxiosRequestConfig): Promise<T> => {
    const response = await http.put<ApiResponse<T> | T>(url, data, config);
    return unwrapResponse<T>(response);
  },
  patch: async <T>(url: string, data?: unknown, config?: AxiosRequestConfig): Promise<T> => {
    const response = await http.patch<ApiResponse<T> | T>(url, data, config);
    return unwrapResponse<T>(response);
  },
  delete: async <T = void>(url: string, config?: AxiosRequestConfig): Promise<T> => {
    const response = await http.delete<ApiResponse<T> | T>(url, config);
    return unwrapResponse<T>(response);
  },
};

export default api;