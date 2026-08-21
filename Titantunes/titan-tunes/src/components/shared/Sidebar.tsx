import Link from "next/link";

type SidebarProps = {
  links: Array<{ label: string; href: string }>;
};

export default function Sidebar({ links }: SidebarProps) {
  return (
    <aside className="w-72 rounded-3xl border border-slate-200 bg-white p-6 shadow-lg shadow-slate-200/40">
      <nav className="space-y-3 text-sm text-slate-700">
        {links.map((link) => (
          <Link key={link.href} href={link.href} className="block rounded-2xl px-4 py-3 hover:bg-slate-100">
            {link.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
}
