"use client";

import { Sun, Moon } from "lucide-react";
import { useTheme } from "@/components/shared/ThemeProvider";

export default function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();
  const isDark = theme === "dark";

  return (
    <button
      onClick={toggleTheme}
      aria-pressed={isDark}
      title={isDark ? "Activer le mode clair" : "Activer le mode sombre"}
      className="inline-flex items-center gap-2 rounded-full border px-4 py-2 text-sm font-semibold shadow-sm transition hover:brightness-110"
      style={{ borderColor: "var(--border)", backgroundColor: "var(--surface)", color: "var(--foreground)" }}
    >
      {isDark ? <Moon className="h-4 w-4 text-amber-400" /> : <Sun className="h-4 w-4" />}
      <span>{isDark ? "Mode Nuit" : "Mode Jour"}</span>
    </button>
  );
}