type GlassHeaderProps = {
  title: string;
  action?: React.ReactNode;
};

export default function GlassHeader({ title, action }: GlassHeaderProps) {
  return (
    <div className="rounded-[2rem] border border-white/30 bg-white/50 p-6 shadow-xl shadow-slate-900/5 backdrop-blur-xl">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p className="text-sm uppercase tracking-[0.3em] text-slate-500">Interface</p>
          <h2 className="mt-2 text-2xl font-semibold text-slate-900">{title}</h2>
        </div>
        {action}
      </div>
    </div>
  );
}
