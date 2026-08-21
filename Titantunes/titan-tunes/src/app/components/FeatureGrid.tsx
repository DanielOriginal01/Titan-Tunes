const features = [
  {
    title: "Découverte intelligente",
    description: "Exposez votre musique à des audiences qualifiées et donnez de la visibilité à vos morceaux au bon moment.",
    badge: "Découverte",
    badgeColor: "text-sky-600 dark:text-sky-300",
  },
  {
    title: "Promotion créative",
    description: "Créez votre présence avec des outils de mise en avant, de storytelling et de positionnement artistique.",
    badge: "Marketing",
    badgeColor: "text-orange-600 dark:text-orange-300",
  },
  {
    title: "Monétisation simple",
    description: "Suivez les revenus, les performances et les engagements sans friction pour mieux gérer votre activité musicale.",
    badge: "Revenus",
    badgeColor: "text-violet-600 dark:text-violet-300",
  },
];

export default function FeatureGrid() {
  return (
    <div className="grid gap-8 lg:grid-cols-3">
      {features.map((feature) => (
        <article
          key={feature.title}
          className="rounded-4xl border p-8 shadow-lg shadow-slate-200/50 backdrop-blur-xl transition hover:-translate-y-1 hover:shadow-xl"
          style={{ borderColor: "var(--border)", backgroundColor: "var(--surface)" }}
        >
          <p className={`text-sm uppercase tracking-[0.3em] ${feature.badgeColor}`}>{feature.badge}</p>
          <h3 className="mt-4 text-2xl font-semibold" style={{ color: "var(--foreground)" }}>
            {feature.title}
          </h3>
          <p className="mt-3 text-sm leading-7" style={{ color: "var(--muted)" }}>
            {feature.description}
          </p>
        </article>
      ))}
    </div>
  );
}
