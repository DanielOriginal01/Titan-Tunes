const DEFAULT_API_URL = "http://localhost:8080/api/v1";

export type ApiResponse<T = unknown> = {
  success: boolean;
  message: string;
  data: T;
  status: number;
  timestamp: string;
};

export type ApiErrorPayload = {
  success?: boolean;
  message?: string;
  data?: unknown;
  status?: number;
  timestamp?: string;
};

export type RequestOptions = Omit<RequestInit, "body"> & {
  body?: unknown;
  params?: Record<string, string | number | boolean | undefined>;
};

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? DEFAULT_API_URL;

function getAuthToken(): string | null {
  if (typeof window === "undefined") return null;
  return window.localStorage.getItem("titan_token");
}

function buildUrl(path: string, params?: Record<string, string | number | boolean | undefined>) {
  const url = path.startsWith("http") ? path : `${API_URL}${path}`;

  if (!params) return url;

  const search = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== null) {
      search.append(key, String(value));
    }
  });

  const query = search.toString();
  return query ? `${url}${url.includes("?") ? "&" : "?"}${query}` : url;
}

function isApiResponse<T>(payload: unknown): payload is ApiResponse<T> {
  if (!payload || typeof payload !== "object") return false;
  return "success" in payload && "message" in payload && "status" in payload;
}

function extractPayload<T>(payload: unknown): T {
  if (payload && typeof payload === "object" && "success" in payload && "data" in payload) {
    return (payload as ApiResponse<T>).data as T;
  }
  return payload as T;
}

function parseJsonSafely<T>(response: Response): Promise<T | null> {
  return response.text().then((text) => {
    if (!text) return null;
    try {
      return JSON.parse(text) as T;
    } catch {
      return null;
    }
  });
}

async function handleResponse<T>(response: Response): Promise<T> {
  const payload = await parseJsonSafely<T>(response);

  if (!response.ok) {
    const errorPayload = payload as ApiErrorPayload | null;
    const message = errorPayload?.message || response.statusText || "Une erreur est survenue.";
    const error = new Error(message) as Error & { status?: number; payload?: unknown };
    error.status = response.status;
    error.payload = payload;

    if (response.status === 401) {
      if (typeof window !== "undefined") {
        window.localStorage.removeItem("titan_token");
        window.localStorage.removeItem("titan_user");
        window.location.href = "/auth/login";
      }
    }

    throw error;
  }

  if (payload && typeof payload === "object" && "success" in payload) {
    const normalized = payload as unknown as ApiResponse<T>;
    if (normalized.success === false) {
      const error = new Error(normalized.message || "Erreur backend") as Error & { status?: number; payload?: unknown };
      error.status = normalized.status;
      error.payload = normalized;
      throw error;
    }
  }

  return extractPayload<T>(payload as unknown);
}

export async function httpRequest<T>(
  path: string,
  options: RequestOptions = {},
): Promise<T> {
  const token = getAuthToken();
  const { params, headers: customHeaders, body, ...rest } = options;

  const requestHeaders = new Headers(customHeaders ?? {});
  if (!(body instanceof FormData)) {
    requestHeaders.set("Content-Type", "application/json");
  }

  if (token) {
    requestHeaders.set("Authorization", `Bearer ${token}`);
  }

  const requestBody: BodyInit | null =
    body == null
      ? null
      : typeof body === "string"
        ? body
        : body instanceof FormData || body instanceof URLSearchParams
          ? (body as BodyInit)
          : JSON.stringify(body);

  const response = await fetch(buildUrl(path, params), {
    ...rest,
    headers: requestHeaders,
    body: requestBody,
  });

  return handleResponse<T>(response);
}

export const apiClient = {
  get: <T>(path: string, options?: Omit<RequestOptions, "method" | "body">) =>
    httpRequest<T>(path, { ...options, method: "GET" }),
  post: <T>(path: string, body?: unknown, options?: Omit<RequestOptions, "method" | "body">) =>
    httpRequest<T>(path, { ...options, method: "POST", body }),
  put: <T>(path: string, body?: unknown, options?: Omit<RequestOptions, "method" | "body">) =>
    httpRequest<T>(path, { ...options, method: "PUT", body }),
  patch: <T>(path: string, body?: unknown, options?: Omit<RequestOptions, "method" | "body">) =>
    httpRequest<T>(path, { ...options, method: "PATCH", body }),
  delete: <T>(path: string, options?: Omit<RequestOptions, "method" | "body">) =>
    httpRequest<T>(path, { ...options, method: "DELETE" }),
};

export function getApiBaseUrl() {
  return API_URL;
}
