import Image from "next/image";
import Link from "next/link";

export default function HeroSection() {
  return (
    <section className="relative overflow-hidden px-6 py-16 sm:px-10 lg:py-24">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(56,189,248,0.18),transparent_24%),radial-gradient(circle_at_bottom_right,rgba(249,115,22,0.18),transparent_22%)]" />
      <div className="relative mx-auto grid max-w-7xl gap-12 lg:grid-cols-[1.2fr_0.8fr] lg:items-center">
        <div className="space-y-8">
          <div className="space-y-5">
            <h1
              className="max-w-2xl text-5xl font-semibold tracking-tight sm:text-6xl lg:text-7xl drop-shadow-[0_6px_18px_rgba(2,6,23,0.6)] dark:drop-shadow-[0_6px_18px_rgba(0,0,0,0.45)]"
              style={{ color: "var(--foreground)" }}
            >
              Faites rayonner votre musique.
            </h1>
            <p className="max-w-xl text-lg leading-8 sm:text-xl" style={{ color: "var(--muted)" }}>
              Titan Tunes aide les artistes à partager leur son, développer leur audience et transformer leur
              visibilité en revenus — avec une expérience moderne pensée pour la mise en avant musicale.
            </p>
          </div>

          <div className="flex flex-col gap-4 sm:flex-row">
            <Link
              href="/auth/login"
              className="inline-flex items-center justify-center rounded-full bg-linear-to-r from-sky-600 to-blue-700 px-6 py-4 text-sm font-semibold text-white shadow-lg shadow-sky-600/20 transition hover:brightness-110"
            >
              Connexion artiste
            </Link>
            <Link
              href="/auth/register"
              className="inline-flex items-center justify-center rounded-full border px-6 py-4 text-sm font-semibold shadow-sm transition hover:brightness-110"
              style={{
                borderColor: "var(--border)",
                backgroundColor: "var(--surface)",
                color: "var(--foreground)",
              }}
            >
              Créer un compte artiste
            </Link>
          </div>

          <div className="flex flex-wrap items-center gap-6 text-sm" style={{ color: "var(--muted)" }}>
            <span>+12k artistes</span>
            <span>•</span>
            <span>1M écoutes</span>
            <span>•</span>
            <span>Analytique temps réel</span>
          </div>
        </div>

        <div className="flex items-center justify-center">
          <div className="relative w-full max-w-xl">
            <div className="relative aspect-4/5 w-full rounded-3xl overflow-hidden shadow-2xl">
              <div className="absolute inset-0 z-10 bg-linear-to-br from-black/10 via-transparent to-black/20 mix-blend-overlay" />

              {/* Image collage */}
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="relative h-105 w-80 sm:h-130 sm:w-105">
                  <Image
                    src="/logos/ARTISITIC PHOTOGRAPHY.jpg"
                    alt="Artistic"
                    fill
                    className="object-cover rounded-2xl rotate-[-4deg] shadow-lg"
                    sizes="(max-width: 640px) 80vw, 420px"
                  />
                </div>

                <div className="pointer-events-none absolute -right-10 top-12 hidden h-44 w-36 rotate-6 overflow-hidden rounded-2xl shadow-xl sm:block">
                  <Image src="/logos/Music Album cover.jpg" alt="Album" fill className="object-cover" sizes="180px" />
                </div>

                <div className="pointer-events-none absolute -left-7 bottom-8 hidden h-36 w-28 -rotate-6 overflow-hidden rounded-2xl shadow-xl sm:block">
                  <Image src="/logos/Silver Vinyl Record.jpg" alt="Vinyl" fill className="object-cover" sizes="140px" />
                </div>

                <div
                  className="absolute bottom-4 left-4 z-20 w-40 rounded-2xl p-4 shadow-md"
                  style={{ backgroundColor: "var(--surface)", color: "var(--foreground)" }}
                >
                  <p className="text-xs uppercase tracking-[0.3em]" style={{ color: "var(--accent)" }}>
                    Artist Studio
                  </p>
                  <h3 className="mt-1 text-lg font-semibold">Votre scène digitale</h3>
                  <p className="mt-2 text-sm">Publiez, suivez vos performances et gagnez en visibilité.</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
