import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: ["class", ".dark"],
  content: ["./app/**/*.{js,ts,jsx,tsx,mdx}", "./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        primary: "#1E51A4",
        accent: "#FF9800",
      },
      boxShadow: {
        glass: "0 12px 40px rgba(30,81,164,0.12)",
      },
    },
  },
  plugins: [],
};

export default config;
