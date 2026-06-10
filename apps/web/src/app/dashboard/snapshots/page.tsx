"use client";

import { useState } from "react";
import { useProjectStore } from "@/store/project.store";
import { useSnapshots } from "@/hooks/useSnapshots";
import { GameSelector } from "@/components/dashboard/GameSelector";
import Link from "next/link";

const filters = ["Todos", "Automático", "Manual", "Completos", "Falhos"];

function formatDate(iso: string) {
  const d = new Date(iso);
  const months = ["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"];
  return `${d.getDate().toString().padStart(2,"0")} ${months[d.getMonth()]} ${d.getFullYear()}, ${d.getHours().toString().padStart(2,"0")}:${d.getMinutes().toString().padStart(2,"0")}`;
}

function formatSize(bytes?: number) {
  if (!bytes) return "—";
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
}

export default function SnapshotsPage() {
  const { selectedProject } = useProjectStore();
  const { snapshots, loading, error, triggerManual } = useSnapshots(selectedProject?.id ?? null);
  const [filter, setFilter] = useState("Todos");
  const [triggering, setTriggering] = useState(false);

  const filtered = snapshots.filter((s) => {
    if (filter === "Automático") return s.type === "scheduled";
    if (filter === "Manual") return s.type === "manual";
    if (filter === "Completos") return s.status === "completed";
    if (filter === "Falhos") return s.status === "failed";
    return true;
  });

  const handleManual = async () => {
    setTriggering(true);
    try { await triggerManual(); } finally { setTriggering(false); }
  };

  return (
    <div className="p-6 max-w-5xl">
      {/* Header */}
      <div className="flex items-center justify-between mb-5">
        <div>
          <h1 className="text-2xl font-bold" style={{ color: "var(--phoenix-text)" }}>Backups</h1>
          <p className="text-sm mt-0.5" style={{ color: "var(--phoenix-text-secondary)" }}>Histórico de backups dos seus jogos</p>
        </div>
        <button
          onClick={handleManual}
          disabled={!selectedProject || triggering}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold text-white disabled:opacity-50 transition-all"
          style={{ background: "var(--phoenix-primary)", boxShadow: "0 3px 12px rgba(255,107,0,0.3)" }}
        >
          {triggering ? (
            <svg className="animate-spin w-4 h-4" viewBox="0 0 24 24" fill="none"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"/><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/></svg>
          ) : (
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="16 3 21 3 21 8"/><line x1="4" y1="20" x2="21" y2="3"/><polyline points="21 16 21 21 16 21"/><line x1="15" y1="15" x2="21" y2="21"/></svg>
          )}
          Backup Manual
        </button>
      </div>

      {/* Game Selector */}
      <GameSelector />

      {/* Filters */}
      <div className="flex items-center gap-2 mb-5 flex-wrap">
        {filters.map((f) => (
          <button key={f} onClick={() => setFilter(f)}
            className="px-4 py-1.5 rounded-full text-sm font-medium transition-all"
            style={{
              background: filter === f ? "var(--phoenix-primary)" : "var(--phoenix-card)",
              color: filter === f ? "white" : "var(--phoenix-text-secondary)",
              border: `1px solid ${filter === f ? "var(--phoenix-primary)" : "var(--phoenix-border)"}`,
            }}
          >
            {f}
          </button>
        ))}
      </div>

      {/* Table */}
      {!selectedProject ? (
        <div className="text-center py-16" style={{ color: "var(--phoenix-text-secondary)" }}>
          Selecione um jogo para ver os backups
        </div>
      ) : loading ? (
        <div className="flex flex-col gap-2">
          {[1,2,3,4,5].map(i => <div key={i} className="h-14 rounded-xl animate-pulse" style={{ background: "var(--phoenix-card)" }} />)}
        </div>
      ) : error ? (
        <div className="text-center py-16" style={{ color: "var(--phoenix-error)" }}>{error}</div>
      ) : filtered.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-center">
          <div className="text-4xl mb-3">☁️</div>
          <h3 className="font-semibold mb-1" style={{ color: "var(--phoenix-text)" }}>Nenhum backup encontrado</h3>
          <p className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>Execute um backup para começar a proteger seus dados</p>
        </div>
      ) : (
        <div>
          {/* Header row */}
          <div className="grid grid-cols-12 gap-2 px-4 py-2 mb-1 text-xs font-semibold uppercase tracking-wide" style={{ color: "var(--phoenix-text-secondary)" }}>
            <div className="col-span-3">Data</div>
            <div className="col-span-2">Tipo</div>
            <div className="col-span-2">Tamanho</div>
            <div className="col-span-1">Keys</div>
            <div className="col-span-2">Status</div>
            <div className="col-span-2 text-right">Ações</div>
          </div>

          <div className="flex flex-col gap-1.5">
            {filtered.map((snap) => {
              const isAuto = snap.type === "scheduled";
              const isOk = snap.status === "completed";
              return (
                <div key={snap.id} className="grid grid-cols-12 gap-2 items-center px-4 py-3 rounded-xl border"
                  style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
                  <div className="col-span-3 text-sm" style={{ color: "var(--phoenix-text)" }}>{formatDate(snap.createdAt)}</div>
                  <div className="col-span-2">
                    <span className="text-xs px-2 py-1 rounded-md font-semibold"
                      style={{ background: isAuto ? "rgba(255,107,0,0.12)" : "rgba(107,107,107,0.15)", color: isAuto ? "var(--phoenix-primary)" : "var(--phoenix-text-secondary)" }}>
                      {isAuto ? "Automático" : "Manual"}
                    </span>
                  </div>
                  <div className="col-span-2 text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>{formatSize(snap.sizeBytes)}</div>
                  <div className="col-span-1 text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>{snap.keystoreCount ?? "—"}</div>
                  <div className="col-span-2">
                    <span className="text-xs px-2 py-1 rounded-md font-semibold"
                      style={{ background: isOk ? "rgba(34,197,94,0.12)" : snap.status === "failed" ? "rgba(239,68,68,0.12)" : "rgba(245,158,11,0.12)", color: isOk ? "#22C55E" : snap.status === "failed" ? "#EF4444" : "#F59E0B" }}>
                      {isOk ? "Completo" : snap.status === "failed" ? "Falhou" : snap.status === "running" ? "Executando" : "Pendente"}
                    </span>
                  </div>
                  <div className="col-span-2 flex items-center justify-end gap-3">
                    <Link href={`/dashboard/snapshots/${snap.id}`}>
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--phoenix-text-secondary)" strokeWidth="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    </Link>
                    <Link href={`/dashboard/snapshots/${snap.id}/restore`}>
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--phoenix-primary)" strokeWidth="2"><path d="M3 12a9 9 0 109-9H3"/><polyline points="3 3 3 12 12 12"/></svg>
                    </Link>
                    <button>
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--phoenix-text-secondary)" strokeWidth="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}
