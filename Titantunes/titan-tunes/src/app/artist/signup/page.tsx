"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

/** Page legacy — redirige vers l'inscription unifiée */
export default function ArtistSignupPage() {
  const router = useRouter();
  useEffect(() => { router.replace("/auth/register"); }, [router]);
  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-950">
      <div className="h-8 w-8 animate-spin rounded-full border-4 border-orange-500 border-t-transparent" />
    </div>
  );
}
