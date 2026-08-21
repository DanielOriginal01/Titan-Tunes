type HeaderProps = {
  title: string;
  subtitle?: string;
};

export default function Header({ title, subtitle }: HeaderProps) {
  return (
    <header className="mb-8 rounded-3xl bg-white p-6 shadow-sm shadow-slate-200/40">
      <h1 className="text-3xl font-semibold text-slate-900">{title}</h1>
      {subtitle && <p className="mt-2 text-slate-600">{subtitle}</p>}
    </header>
  );
}
