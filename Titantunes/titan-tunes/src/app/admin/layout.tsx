"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuth } from "@/hooks/useAuth";
import AuthGuard from "@/components/shared/AuthGuard";
import type { ReactNode } from "react";

// ─── Icônes ───────────────────────────────────────────────────────────────────

const IconDashboard = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
  </svg>
);
const IconUsers = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
  </svg>
);
const IconMic = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" d="M9 19V6l12-3v13M9 19c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zm12-3c0 1.1-1.34 2-3 2s-3-.9-3-2 1.34-2 3-2 3 .9 3 2zM9 10l12-3" />
  </svg>
);
const IconLabel = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
  </svg>
);
const IconBell = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
  </svg>
);
const IconLogout = () => (
  <svg className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth={1.7} viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
  </svg>
);

// ─── Nav items ────────────────────────────────────────────────────────────────

const NAV = [
  { href: "/admin/dashboard",    label: "Dashboard",     Icon: IconDashboard },
  { href: "/admin/utilisateurs", label: "Utilisateurs",  Icon: IconUsers     },
  { href: "/admin/artistes",     label: "Artistes",      Icon: IconMic       },
  { href: "/admin/labels",       label: "Labels",        Icon: IconLabel     },
  { href: "/admin/notifications",label: "Notifications", Icon: IconBell      },
];

// ─── Sidebar ─────────────────────────────────────────────────────────────────

function Sidebar() {
  const pathname = usePathname();
  const { user, signOut } = useAuth();

  return (
    <aside className="fixed left-0 top-0 flex h-full w-64 flex-col border-r border-slate-800/70 bg-slate-950 z-30">
      {/* Logo */}
      <div className="border-b border-slate-800/70 px-6 py-7">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-blue-600/20">
            <svg className="h-4 w-4 text-blue-400" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
            </svg>
          </div>
          <div>
            <p className="text-[11px] font-semibold uppercase tracking-[0.3em] text-blue-400">Titan Tunes</p>
            <p className="text-xs text-slate-500">Admin Panel</p>
          </div>
        </div>
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
                  ? "bg-blue-600/15 text-blue-300 ring-1 ring-blue-500/30"
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
      <div className="border-t border-slate-800/70 px-4 py-4 space-y-2">
        <div className="flex items-center gap-3 rounded-2xl bg-slate-900/60 px-4 py-3">
          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-blue-600/20 text-sm font-bold text-blue-400">
            {(user?.username ?? "A")[0].toUpperCase()}
          </div>
          <div className="min-w-0">
            <p className="truncate text-sm font-semibold text-white">{user?.username ?? "Admin"}</p>
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

export default function AdminLayout({ children }: { children: ReactNode }) {
  const pathname = usePathname();

  // Si on est sur la page de connexion admin, afficher directement le contenu sans AuthGuard ni Sidebar
  if (pathname === "/admin/login" || pathname?.startsWith("/admin/login/")) {
    return <>{children}</>;
  }

  return (
    <AuthGuard role="administrateur">
      <div className="min-h-screen bg-[linear-gradient(180deg,#020817_0%,#0f172a_40%,#111827_100%)] text-slate-100">
        <Sidebar />
        <main className="ml-64 min-h-screen px-8 py-8">
          {children}
        </main>
      </div>
    </AuthGuard>
  );
}

