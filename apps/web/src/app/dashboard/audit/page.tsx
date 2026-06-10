"use client";

export default function AuditPage() {
  return (
    <div>
      <div className="mb-8">
        <h2 className="text-2xl font-bold" style={{ color: "var(--phoenix-text, #fafafa)" }}>
          Auditoria
        </h2>
        <p className="text-sm mt-1" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
          Histórico completo de operações e eventos de segurança.
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
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
            <polyline points="14 2 14 8 20 8" />
            <line x1="16" y1="13" x2="8" y2="13" />
            <line x1="16" y1="17" x2="8" y2="17" />
          </svg>
        </div>
        <div>
          <p className="font-semibold" style={{ color: "var(--phoenix-primary, #ff6b00)" }}>
            Serviço em desenvolvimento
          </p>
          <p className="text-sm mt-1" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
            O serviço de auditoria estará disponível em breve. Todos os eventos de
            leitura, escrita e deleção de DataStores serão registrados e auditáveis.
          </p>
        </div>
      </div>

      {/* Log table placeholder */}
      <div
        className="rounded-2xl overflow-hidden"
        style={{
          background: "var(--phoenix-card, #18181b)",
          border: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))",
        }}
      >
        {/* Table header */}
        <div
          className="grid gap-4 px-5 py-3 text-xs font-medium"
          style={{
            gridTemplateColumns: "1fr 1fr 1fr 1fr",
            color: "var(--phoenix-text-secondary, #a1a1aa)",
            borderBottom: "1px solid var(--phoenix-border, rgba(255,255,255,0.06))",
          }}
        >
          <span>Timestamp</span>
          <span>Ação</span>
          <span>Usuário</span>
          <span>Recurso</span>
        </div>

        {/* Empty state */}
        <div className="py-16 text-center">
          <svg
            width="40"
            height="40"
            viewBox="0 0 24 24"
            fill="none"
            stroke="rgba(255,255,255,0.1)"
            strokeWidth="1"
            className="mx-auto mb-3"
          >
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
            <polyline points="14 2 14 8 20 8" />
            <line x1="16" y1="13" x2="8" y2="13" />
            <line x1="16" y1="17" x2="8" y2="17" />
          </svg>
          <p
            className="text-sm"
            style={{ color: "var(--phoenix-text-secondary, #71717a)" }}
          >
            Nenhum log disponível ainda.
          </p>
        </div>
      </div>

      {/* Feature preview cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
        {[
          {
            icon: (
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                <circle cx="12" cy="12" r="3" />
              </svg>
            ),
            title: "Rastreamento Completo",
            description: "Cada leitura, escrita e deleção fica registrada com userId e timestamp.",
          },
          {
            icon: (
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3" />
              </svg>
            ),
            title: "Filtros Avançados",
            description: "Filtre por projeto, usuário, tipo de ação, período ou DataStore.",
          },
          {
            icon: (
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                <polyline points="7 10 12 15 17 10" />
                <line x1="12" y1="15" x2="12" y2="3" />
              </svg>
            ),
            title: "Exportação CSV",
            description: "Exporte logs de auditoria para compliance e relatórios.",
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
