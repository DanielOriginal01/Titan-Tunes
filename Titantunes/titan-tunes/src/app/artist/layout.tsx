"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import AuthGuard from "@/components/shared/AuthGuard";
import { useAuth } from "@/hooks/useAuth";
import type { ReactNode } from "react";

// ─── Icônes inline ────────────────────────────────────────────────────────────

function IconDashboard() {
  return (
    <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
    </svg>
  );
}
function IconMusic() {
  return (
    <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" d="M9 19V6l12-3v13M9 19c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zm12-3c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zM9 10l12-3" />
    </svg>
  );
}
function IconCalendar() {
  return (
    <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
    </svg>
  );
}
function IconChart() {
  return (
    <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
    </svg>
  );
}
function IconSettings() {
  return (
    <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
      <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
    </svg>
  );
}
function IconLogout() {
  return (
    <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
    </svg>
  );
}

function IconPayouts() {
  return (
    <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
    </svg>
  );
}

// ─── Nav items ────────────────────────────────────────────────────────────────

const NAV = [
  { href: "/artist/dashboard",  label: "Dashboard",    Icon: IconDashboard },
  { href: "/artist/music",      label: "Catalogue",    Icon: IconMusic     },
  { href: "/artist/payouts",    label: "Royalties",    Icon: IconPayouts   },
  { href: "/artist/evenements", label: "Événements",   Icon: IconCalendar  },
  { href: "/artist/analytics",  label: "Statistiques", Icon: IconChart     },
  { href: "/artist/settings",   label: "Paramètres",   Icon: IconSettings  },
];

// ─── Sidebar (client car usePathname + useAuth) ───────────────────────────────

function Sidebar() {
  const pathname = usePathname();
  const { user, signOut } = useAuth();

  return (
    <aside className="fixed left-0 top-0 flex h-full w-64 flex-col border-r border-slate-800/60 bg-slate-950/98 backdrop-blur-xl">
      {/* Logo */}
      <div className="px-6 pt-8 pb-6 border-b border-slate-800/60">
        <p className="text-[11px] font-semibold uppercase tracking-[0.3em] text-orange-400">Titan Tunes</p>
        <h2 className="mt-1.5 text-lg font-bold text-white">Espace artiste</h2>
      </div>

      {/* Nav */}
      <nav className="flex-1 overflow-y-auto px-3 py-4 space-y-1">
        {NAV.map(({ href, label, Icon }) => {
          const active = pathname === href || pathname.startsWith(href + "/");
          return (
            <Link
              key={href}
              href={href}
              className={[
                "flex items-center gap-3 rounded-2xl px-4 py-3 text-sm font-medium transition-all",
                active
                  ? "bg-orange-500/15 text-orange-300 ring-1 ring-orange-500/30"
                  : "text-slate-400 hover:bg-slate-900/60 hover:text-slate-100",
              ].join(" ")}
            >
              <Icon />
              {label}
            </Link>
          );
        })}
      </nav>

      {/* User + Déconnexion */}
      <div className="border-t border-slate-800/60 px-4 py-4 space-y-2">
        <div className="flex items-center gap-3 rounded-2xl bg-slate-900/60 px-4 py-3">
          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-orange-500/20 text-sm font-bold text-orange-400">
            {(user?.username ?? "A")[0].toUpperCase()}
          </div>
          <div className="min-w-0">
            <p className="truncate text-sm font-semibold text-white">{user?.username ?? "Artiste"}</p>
            <p className="truncate text-xs text-slate-500">{user?.email ?? ""}</p>
          </div>
        </div>
        <button
          onClick={() => signOut()}
          className="flex w-full items-center gap-3 rounded-2xl px-4 py-3 text-sm font-medium text-slate-400 transition hover:bg-rose-500/10 hover:text-rose-400"
        >
          <IconLogout />
          Se déconnecter
        </button>
      </div>
    </aside>
  );
}

// ─── Layout ───────────────────────────────────────────────────────────────────

export default function ArtistLayout({ children }: { children: ReactNode }) {
  const pathname = usePathname();

  if (pathname === "/artist/signup" || pathname === "/artist/login") {
    return <>{children}</>;
  }

  return (
    <AuthGuard role="artist">
      <div className="min-h-screen bg-[linear-gradient(180deg,#020617_0%,#0f172a_38%,#111827_100%)] text-slate-100">
        <Sidebar />
        <main className="ml-64 min-h-screen px-8 py-8">
          {children}
        </main>
      </div>
    </AuthGuard>
  );
}
