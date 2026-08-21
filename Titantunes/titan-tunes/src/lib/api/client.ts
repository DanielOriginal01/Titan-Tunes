export async function apiFetch<T>(input: RequestInfo, init?: RequestInit): Promise<T> {
  const response = await fetch(input, init);
  if (!response.ok) {
    throw new Error(`Fetch failed: ${response.status}`);
  }
  return response.json() as Promise<T>;
}
