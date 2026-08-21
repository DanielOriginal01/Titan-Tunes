import Image from "next/image";

export default function BrandShowcase() {
  return (
    <div className="grid gap-6 lg:grid-cols-[1fr_0.8fr]">
      <div
        className="rounded-4xl border p-8 shadow-lg shadow-orange-100/50 backdrop-blur-xl"
        style={{ borderColor: "var(--border)", backgroundColor: "var(--surface)" }}
      >
        <p className="text-sm uppercase tracking-[0.3em]" style={{ color: "var(--muted)" }}>
          Titan Tunes
        </p>
        <p className="mt-4 text-lg leading-8" style={{ color: "var(--foreground)" }}>
          Une plateforme pensée pour les artists, les labels et les créateurs qui veulent faire entendre leur univers, organiser leurs sorties et transformer leur audience en opportunités concrètes.
        </p>
      </div>
      <div
        className="rounded-4xl border p-6 shadow-xl shadow-sky-500/10"
        style={{ borderColor: "var(--border)", backgroundColor: "var(--surface)", color: "var(--foreground)" }}
      >
        <p className="text-sm uppercase tracking-[0.3em]" style={{ color: "var(--muted)" }}>
          Galerie
        </p>
        <div className="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-3">
          {[
            "/logos/ARTISITIC PHOTOGRAPHY.jpg",
            "/logos/Music Album cover.jpg",
            "/logos/Silver Vinyl Record.jpg",
            "/logos/STARBOY.jpg",
            "/logos/New music soon.jpg",
            "/logos/Model.jpg",
          ].map((src) => (
            <div
              key={src}
              className="relative overflow-hidden rounded-2xl p-0 ring-1"
              style={{ backgroundColor: "var(--surface)", borderColor: "var(--border)" }}
            >
              <Image src={src} alt="art" width={320} height={180} className="h-28 w-full object-cover" />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
