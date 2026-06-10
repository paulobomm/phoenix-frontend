"use client";

import { useProjects } from "@/hooks/useProjects";
import { useProjectStore } from "@/store/project.store";
import { GameSelector } from "@/components/dashboard/GameSelector";

export default function DashboardPage() {
  const { projects } = useProjects();
  const { selectedProject } = useProjectStore();

  const stats = [
    {
      label: "Total de Jogos",
      value: projects.length.toString(),
      icon: "🎮",
      color: "#FF6B00",
    },
    {
      label: "Total de Backups",
      value: "—",
      icon: "☁️",
      color: "#60A5FA",
    },
    {
      label: "Storage Usado",
      value: "—",
      sub: "de 50 GB",
      icon: "💾",
      color: "#F59E0B",
    },
    {
      label: "Taxa de Sucesso",
      value: "—",
      sub: "últimos 30 dias",
      icon: "✅",
      color: "#22C55E",
      valueColor: "#22C55E",
    },
  ];

  return (
    <div className="p-6 max-w-5xl">
      {/* Header */}
      <div className="flex items-center justify-between mb-5">
        <div>
          <h1 className="text-2xl font-bold" style={{ color: "var(--phoenix-text)" }}>Dashboard</h1>
          <p className="text-sm mt-0.5" style={{ color: "var(--phoenix-text-secondary)" }}>Visão geral da plataforma</p>
        </div>
        <div className="w-9 h-9 rounded-full flex items-center justify-center" style={{ background: "rgba(255,107,0,0.15)" }}>🔥</div>
      </div>

      {/* Game Selector */}
      <GameSelector />

      {/* Stats */}
      <div className="grid grid-cols-2 gap-3 mb-5">
        {stats.map((s) => (
          <div key={s.label} className="rounded-2xl p-4 border" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
            <div className="flex items-center justify-between mb-2">
              <p className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>{s.label}</p>
              <div className="w-8 h-8 rounded-xl flex items-center justify-center text-sm" style={{ background: `${s.color}20` }}>{s.icon}</div>
            </div>
            <p className="text-3xl font-bold" style={{ color: s.valueColor || "var(--phoenix-text)" }}>{s.value}</p>
            {s.sub && <p className="text-xs mt-0.5" style={{ color: "var(--phoenix-text-secondary)" }}>{s.sub}</p>}
          </div>
        ))}
      </div>

      {/* Chart */}
      <div className="rounded-2xl p-5 border mb-5" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-semibold" style={{ color: "var(--phoenix-text)" }}>Atividade de Backup</h3>
          <span className="text-xs px-2 py-1 rounded-lg" style={{ background: "var(--phoenix-border)", color: "var(--phoenix-text-secondary)" }}>30 dias</span>
        </div>
        {selectedProject ? (
          <div className="h-28 flex items-end gap-0.5">
            {Array.from({ length: 30 }).map((_, i) => (
              <div key={i} className="flex-1 rounded-t-sm"
                style={{
                  height: `${20 + Math.sin(i * 0.8) * 30 + 20}%`,
                  background: i >= 25 ? "var(--phoenix-primary)" : "rgba(255,107,0,0.25)",
                }}
              />
            ))}
          </div>
        ) : (
          <div className="h-28 flex items-center justify-center">
            <p className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>Selecione um jogo para ver a atividade</p>
          </div>
        )}
        <div className="flex justify-between mt-2">
          <span className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>Mai 1</span>
          <span className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>Hoje</span>
        </div>
      </div>

      {/* Empty state quando não tem projetos */}
      {projects.length === 0 ? (
        <div className="rounded-2xl p-8 border text-center" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
          <div className="text-4xl mb-3">🎮</div>
          <h3 className="font-semibold mb-1" style={{ color: "var(--phoenix-text)" }}>Nenhum jogo cadastrado</h3>
          <p className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>
            Vá em <span style={{ color: "var(--phoenix-primary)" }}>Jogos</span> para adicionar seu primeiro jogo
          </p>
        </div>
      ) : (
        <>
          {/* Insights placeholder */}
          <div className="mb-5">
            <div className="flex items-center gap-2 mb-3">
              <span>💡</span>
              <h3 className="font-semibold" style={{ color: "var(--phoenix-text)" }}>Insights</h3>
            </div>
            <div className="rounded-xl p-4 border" style={{ background: "rgba(107,107,107,0.05)", borderColor: "var(--phoenix-border)" }}>
              <p className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>
                Os insights aparecerão aqui conforme os backups forem sendo executados.
              </p>
            </div>
          </div>

          {/* Activity placeholder */}
          <div className="rounded-2xl p-5 border" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
            <div className="flex items-center gap-2 mb-4">
              <span>🕐</span>
              <h3 className="font-semibold" style={{ color: "var(--phoenix-text)" }}>Atividade Recente</h3>
            </div>
            <div className="text-center py-8">
              <p className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>Nenhuma atividade ainda</p>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
