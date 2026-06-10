"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useProjects } from "@/hooks/useProjects";
import { AddGameWizard } from "@/components/games/AddGameWizard";

const statusColors: Record<string, { bg: string; text: string; label: string }> = {
  active: { bg: "rgba(34,197,94,0.15)", text: "#22C55E", label: "Ativo" },
  paused: { bg: "rgba(245,158,11,0.15)", text: "#F59E0B", label: "Pausado" },
  archived: { bg: "rgba(107,107,107,0.15)", text: "#6B6B6B", label: "Arquivado" },
};

export default function GamesPage() {
  const router = useRouter();
  const { projects: games, loading, createProject, deleteProject } = useProjects();
  const [showWizard, setShowWizard] = useState(false);

  return (
    <div className="p-6 max-w-3xl">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold" style={{ color: "var(--phoenix-text)" }}>Meus Jogos</h1>
          <p className="text-sm mt-0.5" style={{ color: "var(--phoenix-text-secondary)" }}>Gerencie seus jogos Roblox</p>
        </div>
        <button onClick={() => setShowWizard(true)}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold text-white"
          style={{ background: "var(--phoenix-primary)", boxShadow: "0 3px 12px rgba(255,107,0,0.3)" }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          Adicionar
        </button>
      </div>

      {loading ? (
        <div className="flex flex-col gap-4">
          {[1,2,3].map(i => <div key={i} className="h-36 rounded-2xl animate-pulse" style={{ background: "var(--phoenix-card)" }} />)}
        </div>
      ) : games.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-24 text-center">
          <div className="text-5xl mb-4">🎮</div>
          <h3 className="text-lg font-semibold mb-2" style={{ color: "var(--phoenix-text)" }}>Nenhum jogo cadastrado</h3>
          <p className="text-sm mb-6" style={{ color: "var(--phoenix-text-secondary)" }}>Adicione seu primeiro jogo Roblox para começar</p>
          <button onClick={() => setShowWizard(true)} className="px-5 py-2.5 rounded-xl text-sm font-semibold text-white" style={{ background: "var(--phoenix-primary)" }}>
            + Adicionar Jogo
          </button>
        </div>
      ) : (
        <div className="flex flex-col gap-4">
          {games.map((game) => {
            const status = statusColors[game.status] || statusColors.active;
            return (
              <div key={game.id} className="rounded-2xl border p-5" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-xl flex items-center justify-center text-xl" style={{ background: "rgba(255,107,0,0.15)" }}>🎮</div>
                    <div>
                      <p className="font-semibold" style={{ color: "var(--phoenix-text)" }}>{game.name}</p>
                      <div className="flex items-center gap-3 mt-0.5">
                        <span className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}># ID: {game.universeId}</span>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs px-2.5 py-1 rounded-lg font-medium" style={{ background: status.bg, color: status.text }}>{status.label}</span>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#6B6B6B" strokeWidth="2"><polyline points="6 9 12 15 18 9"/></svg>
                  </div>
                </div>
                <div className="flex items-center gap-2 mt-4 flex-wrap">
                  <button onClick={() => router.push("/dashboard/snapshots")}
                    className="px-4 py-2 rounded-xl text-sm font-semibold text-white"
                    style={{ background: "var(--phoenix-primary)" }}>
                    Ver Backups
                  </button>
                  <button onClick={() => router.push(`/dashboard/snapshots/${game.id}/restore`)}
                    className="px-4 py-2 rounded-xl text-sm font-medium border"
                    style={{ borderColor: "var(--phoenix-border)", color: "var(--phoenix-text-secondary)" }}>
                    Restore
                  </button>
                  <button onClick={() => router.push(`/dashboard/games/${game.id}`)}
                    className="px-4 py-2 rounded-xl text-sm font-medium border"
                    style={{ borderColor: "var(--phoenix-border)", color: "var(--phoenix-text-secondary)" }}>
                    Configurar
                  </button>
                  <button onClick={() => deleteProject(game.id)}
                    className="w-9 h-9 rounded-xl flex items-center justify-center border ml-auto"
                    style={{ borderColor: "rgba(239,68,68,0.3)", color: "#EF4444", background: "rgba(239,68,68,0.08)" }}>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6M14 11v6"/><path d="M9 6V4h6v2"/>
                    </svg>
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {showWizard && (
        <AddGameWizard
          onClose={() => setShowWizard(false)}
          onCreate={async (data) => {
            await createProject({ name: data.name, universeId: data.universeId, apiKey: data.apiKey });
            setShowWizard(false);
          }}
        />
      )}
    </div>
  );
}
