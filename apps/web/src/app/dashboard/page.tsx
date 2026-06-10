"use client";

import { useProjects } from "@/hooks/useProjects";

function StatCard({
  label,
  value,
  loading,
  accent,
}: {
  label: string;
  value: string | number;
  loading?: boolean;
  accent?: string;
}) {
  return (
    <div
      className="rounded-2xl p-6"
      style={{
        background: "var(--phoenix-card, #18181b)",
        border: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))",
      }}
    >
      <p className="text-sm" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
        {label}
      </p>
      {loading ? (
        <div
          className="mt-2 h-9 w-16 rounded-lg animate-pulse"
          style={{ background: "rgba(255,255,255,0.06)" }}
        />
      ) : (
        <p
          className="text-3xl font-bold mt-1"
          style={{ color: accent || "var(--phoenix-text, #fafafa)" }}
        >
          {value}
        </p>
      )}
    </div>
  );
}

export default function DashboardPage() {
  const { projects, loading } = useProjects();

  const activeCount = projects.filter((p) => p.status === "active").length;
  const inactiveCount = projects.filter((p) => p.status !== "active").length;

  return (
    <div>
      <div className="mb-8">
        <h2 className="text-2xl font-bold" style={{ color: "var(--phoenix-text, #fafafa)" }}>
          Visão Geral
        </h2>
        <p className="text-sm mt-1" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
          Bem-vindo ao Phoenix — gerencie seus Roblox DataStores com segurança.
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
        <StatCard
          label="Total de Projetos"
          value={loading ? "" : projects.length}
          loading={loading}
          accent="var(--phoenix-primary, #ff6b00)"
        />
        <StatCard
          label="Projetos Ativos"
          value={loading ? "" : activeCount}
          loading={loading}
          accent="#22c55e"
        />
        <StatCard
          label="Projetos Inativos"
          value={loading ? "" : inactiveCount}
          loading={loading}
        />
      </div>

      {/* Recent projects */}
      <div
        className="rounded-2xl p-6"
        style={{
          background: "var(--phoenix-card, #18181b)",
          border: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))",
        }}
      >
        <h3 className="font-semibold mb-4" style={{ color: "var(--phoenix-text, #fafafa)" }}>
          Projetos Recentes
        </h3>

        {loading && (
          <div className="flex flex-col gap-3">
            {[1, 2, 3].map((i) => (
              <div
                key={i}
                className="h-12 rounded-xl animate-pulse"
                style={{ background: "rgba(255,255,255,0.04)" }}
              />
            ))}
          </div>
        )}

        {!loading && projects.length === 0 && (
          <div className="text-center py-10">
            <p style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
              Nenhum projeto conectado ainda.
            </p>
            <a
              href="/dashboard/projects"
              className="inline-block mt-3 text-sm font-medium"
              style={{ color: "var(--phoenix-primary, #ff6b00)" }}
            >
              Conectar primeiro jogo →
            </a>
          </div>
        )}

        {!loading && projects.length > 0 && (
          <div className="flex flex-col gap-2">
            {projects.slice(0, 5).map((project) => (
              <div
                key={project.id}
                className="flex items-center justify-between px-4 py-3 rounded-xl"
                style={{ background: "rgba(255,255,255,0.03)" }}
              >
                <div>
                  <p className="text-sm font-medium" style={{ color: "var(--phoenix-text, #fafafa)" }}>
                    {project.name}
                  </p>
                  <p className="text-xs mt-0.5" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
                    Universe ID: {project.universeId}
                  </p>
                </div>
                <span
                  className="text-xs px-2.5 py-1 rounded-full font-medium"
                  style={{
                    background:
                      project.status === "active"
                        ? "rgba(34,197,94,0.12)"
                        : "rgba(255,255,255,0.06)",
                    color:
                      project.status === "active"
                        ? "#22c55e"
                        : "var(--phoenix-text-secondary, #a1a1aa)",
                  }}
                >
                  {project.status}
                </span>
              </div>
            ))}
            {projects.length > 5 && (
              <a
                href="/dashboard/projects"
                className="text-center text-sm mt-1"
                style={{ color: "var(--phoenix-primary, #ff6b00)" }}
              >
                Ver todos ({projects.length}) →
              </a>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
