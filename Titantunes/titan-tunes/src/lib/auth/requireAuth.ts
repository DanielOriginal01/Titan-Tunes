import { cookies } from "next/headers";

export async function requireAuth() {
  const cookieStore = await cookies();
  const token = cookieStore.get("titan-tunes-token")?.value;
  if (!token) {
    throw new Error("Utilisateur non authentifié");
  }
  return token;
}
