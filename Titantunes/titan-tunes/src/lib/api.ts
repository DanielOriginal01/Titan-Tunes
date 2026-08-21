export const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8080";

export type HttpMethod = "GET" | "POST" | "PUT" | "PATCH" | "DELETE";

export type ApiFetchOptions = {
  method?: HttpMethod;
  body?: unknown;
  headers?: HeadersInit;
  useCredentials?: boolean;
};

export class ApiError extends Error {
  status: number;
  data: unknown;

  constructor(status: number, message: string, data: unknown) {
    super(message);
    this.status = status;
    this.data = data;
  }
}

const jsonHeaders = () => ({
  "Content-Type": "application/json",
});

function getClientToken(): string | null {
  if (typeof window === "undefined") return null;
  return window.localStorage.getItem("titan_token");
}

export async function apiFetch<T>(path: string, options: ApiFetchOptions = {}): Promise<T> {
  const url = path.startsWith("http") ? path : `${API_BASE_URL}${path}`;
  const headers: HeadersInit = {
    ...jsonHeaders(),
    ...options.headers,
  };

  const token = getClientToken();
  if (token) {
    (headers as Record<string, string>)["Authorization"] = `Bearer ${token}`;
  }

  const response = await fetch(url, {
    method: options.method ?? "GET",
    headers,
    body: options.body ? JSON.stringify(options.body) : undefined,
    credentials: options.useCredentials === false ? "same-origin" : "include",
  });

  const text = await response.text();
  const data = text ? JSON.parse(text) : null;

  if (!response.ok) {
    throw new ApiError(response.status, (data && (data as any).message) || response.statusText, data);
  }

  return data as T;
}
