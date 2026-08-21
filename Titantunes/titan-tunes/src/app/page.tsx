import Header from "./components/Header";
import HeroSection from "./components/HeroSection";
import FeatureGrid from "./components/FeatureGrid";
import BrandShowcase from "./components/BrandShowcase";

export default function HomePage() {
  return (
    <main
      className="min-h-screen transition-colors duration-300"
      style={{ backgroundColor: "var(--bg-page)", color: "var(--foreground)" }}
    >
      <Header />
      <HeroSection />
      <section className="border-t px-6 py-16 sm:px-10 lg:py-20" style={{ borderColor: "var(--border)" }}>
        <div className="mx-auto max-w-7xl space-y-10">
          <FeatureGrid />
          <BrandShowcase />
        </div>
      </section>
    </main>
  );
}
