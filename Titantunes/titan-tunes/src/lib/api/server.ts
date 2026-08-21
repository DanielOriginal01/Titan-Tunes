export async function serverFetch<T>(url: string, options?: RequestInit): Promise<T> {
  const response = await fetch(url, { ...options, cache: "no-store" });
  if (!response.ok) {
    throw new Error(`Server fetch failed: ${response.status}`);
  }
  return response.json() as Promise<T>;
}
