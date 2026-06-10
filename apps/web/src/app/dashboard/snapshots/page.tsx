"use client";

export default function SnapshotsPage() {
  return (
    <div>
      <div className="mb-8">
        <h2 className="text-2xl font-bold" style={{ color: "var(--phoenix-text, #fafafa)" }}>
          Snapshots
        </h2>
        <p className="text-sm mt-1" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
          Backups automáticos e manuais dos seus DataStores Roblox.
        </p>
      </div>

      {/* Coming soon banner */}
      <div
        className="rounded-2xl p-6 mb-6 flex items-start gap-4"
        style={{
          background: "rgba(255,107,0,0.06)",
          border: "1px solid rgba(255,107,0,0.15)",
        }}
      >
        <div
          className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
          style={{ background: "rgba(255,107,0,0.12)" }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--phoenix-primary, #ff6b00)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <polyline points="23 4 23 10 17 10" />
            <polyline points="1 20 1 14 7 14" />
            <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15" />
          </svg>
        </div>
        <div>
          <p className="font-semibold" style={{ color: "var(--phoenix-primary, #ff6b00)" }}>
            Serviço em desenvolvimento
          </p>
          <p className="text-sm mt-1" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
            O serviço de snapshots estará disponível em breve. Você poderá criar backups
            agendados e manuais, comparar versões e restaurar DataStores com um clique.
          </p>
        </div>
      </div>

      {/* Feature preview */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {[
          {
            icon: (
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="10" />
                <polyline points="12 6 12 12 16 14" />
              </svg>
            ),
            title: "Backups Agendados",
            description: "Configure snapshots automáticos por hora, dia ou semana.",
          },
          {
            icon: (
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="18" y1="20" x2="18" y2="10" />
                <line x1="12" y1="20" x2="12" y2="4" />
                <line x1="6" y1="20" x2="6" y2="14" />
              </svg>
            ),
            title: "Comparação de Versões",
            description: "Visualize diferenças entre dois snapshots lado a lado.",
          },
          {
            icon: (
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="1 4 1 10 7 10" />
                <path d="M3.51 15a9 9 0 1 0 .49-4.51" />
              </svg>
            ),
            title: "Restore com 1 Clique",
            description: "Reverta seu DataStore para qualquer ponto no histórico.",
          },
        ].map((feature) => (
          <div
            key={feature.title}
            className="rounded-2xl p-5"
            style={{
              background: "var(--phoenix-card, #18181b)",
              border: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))",
              opacity: 0.6,
            }}
          >
            <div
              className="w-10 h-10 rounded-xl flex items-center justify-center mb-3"
              style={{
                background: "rgba(255,255,255,0.05)",
                color: "var(--phoenix-text-secondary, #a1a1aa)",
              }}
            >
              {feature.icon}
            </div>
            <h3
              className="font-semibold text-sm"
              style={{ color: "var(--phoenix-text, #fafafa)" }}
            >
              {feature.title}
            </h3>
            <p
              className="text-xs mt-1.5"
              style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}
            >
              {feature.description}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}
