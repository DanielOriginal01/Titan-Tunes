type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "secondary" | "ghost";
};

const variantClasses = {
  primary: "bg-[#1E51A4] text-white hover:bg-[#173f87]",
  secondary: "bg-[#FF9800] text-slate-900 hover:bg-[#e68600]",
  ghost: "border border-slate-300 bg-white text-slate-900 hover:bg-slate-50",
};

export default function Button({ variant = "primary", className = "", ...props }: ButtonProps) {
  return (
    <button
      className={`inline-flex items-center justify-center rounded-2xl px-5 py-3 text-sm font-semibold transition ${variantClasses[variant]} ${className}`}
      {...props}
    />
  );
}
