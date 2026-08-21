type InputProps = React.InputHTMLAttributes<HTMLInputElement>;

export default function Input({ className = "", ...props }: InputProps) {
  return (
    <input
      className={`w-full rounded-2xl border border-slate-300 bg-white px-4 py-3 text-sm text-slate-900 outline-none transition focus:border-[#1E51A4] focus:ring-2 focus:ring-[#1E51A4]/20 ${className}`}
      {...props}
    />
  );
}
