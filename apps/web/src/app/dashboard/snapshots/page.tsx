"use client";

import { useState, useEffect, useCallback } from "react";
import { snapshotsApi } from "@/services/api";
import { useProjects } from "@/hooks/useProjects";

interface SnapshotJob {
  id: string;
  projectId: string;
  scheduleId: string | null;
  status: "pending" | "running" | "completed" | "failed";
  startedAt: string | null;
  completedAt: string | null;
  error: string | null;
  statsJson: Record<string, unknown> | null;
  createdAt: string;
}

const FILTERS = [
  { key: "all", label: "Todos" },
  { key: "auto", label: "Automático" },
  { key: "manual", label: "Manual" },
  { key: "completed", label: "Completos" },
  { key: "failed", label: "Falhos" },
] as const;

type FilterKey = (typeof FILTERS)[number]["key"];

export default function SnapshotsPage() {
  const { projects } = useProjects();
  const [selectedProject, setSelectedProject] = useState("");
  const [jobs, setJobs] = useState<SnapshotJob[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<FilterKey>("all");
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const limit = 20;

  // auto-select first project
  useEffect(() => {
    if (projects.length > 0 && !selectedProject) {
      setSelectedProject(projects[0].id);
    }
  }, [projects, selectedProject]);

  const loadJobs = useCallback(async () => {
    if (!selectedProject) return;
    setLoading(true);
    setError(null);
    try {
      const params: Record<string, string | number> = { page, limit };
      const res = await snapshotsApi.get(`/v1/projects/${selectedProject}/jobs`, { params });
      const data = res.data;
      setJobs(data.data ?? data ?? []);
      setTotal(data.meta?.totalItems ?? data.total ?? (data.data ?? data).length);
    } catch {
      setError("Erro ao carregar snapshots.");
    } finally {
      setLoading(false);
    }
  }, [selectedProject, page]);

  useEffect(() => { void loadJobs(); }, [loadJobs]);

  const filtered = jobs.filter((j) => {
    if (filter === "auto") return j.scheduleId !== null;
    if (filter === "manual") return j.scheduleId === null;
    if (filter === "completed") return j.status === "completed";
    if (filter === "failed") return j.status === "failed";
    return true;
  });

  const totalPages = Math.max(1, Math.ceil(total / limit));

  const cardStyle = {
    background: "var(--phoenix-card, #18181b)",
    border: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))",
  };

  const StatusBadge = ({ status }: { status: SnapshotJob["status"] }) => {
    const map: Record<string, { label: string; color: string; bg: string }> = {
      completed: { label: "Completo", color: "#22c55e", bg: "rgba(34,197,94,0.1)" },
      failed: { label: "Falhou", color: "#ef4444", bg: "rgba(239,68,68,0.1)" },
      running: { label: "Em progresso", color: "#f59e0b", bg: "rgba(245,158,11,0.1)" },
      pending: { label: "Aguardando", color: "#a1a1aa", bg: "rgba(161,161,170,0.1)" },
    };
    const s = map[status] ?? map.pending;
    return (
      <span
        className="inline-flex items-center px-2 py-0.5 rounded-md text-xs font-medium"
        style={{ color: s.color, background: s.bg }}
      >
        {s.label}
      </span>
    );
  };

  const TypeBadge = ({ scheduleId }: { scheduleId: string | null }) => (
    <span
      className="inline-flex items-center px-2 py-0.5 rounded-md text-xs font-medium"
      style={{
        color: scheduleId ? "#ff6b00" : "#a1a1aa",
        background: scheduleId ? "rgba(255,107,0,0.1)" : "rgba(161,161,170,0.1)",
      }}
    >
      {scheduleId ? "Automático" : "Manual"}
    </span>
  );

  return (
    <div>
      <div className="mb-6 flex items-start justify-between gap-4 flex-wrap">
        <div>
          <h2 className="text-2xl font-bold" style={{ color: "var(--phoenix-text, #fafafa)" }}>
            Backups
          </h2>
          <p className="text-sm mt-1" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
            Histórico de snapshots automáticos e manuais dos seus DataStores.
          </p>
        </div>

        {/* Project selector */}
        <select
          value={selectedProject}
          onChange={(e) => { setSelectedProject(e.target.value); setPage(1); }}
          style={{
            background: "rgba(255,255,255,0.04)",
            border: "1px solid rgba(255,255,255,0.1)",
            color: "var(--phoenix-text, #fafafa)",
            borderRadius: "10px",
            padding: "7px 12px",
            fontSize: "13px",
            outline: "none",
            minWidth: 200,
          }}
        >
          <option value="" style={{ background: "#18181b" }}>Selecionar projeto...</option>
          {projects.map((p) => (
            <option key={p.id} value={p.id} style={{ background: "#18181b" }}>{p.name}</option>
          ))}
        </select>
      </div>

      {/* Filter pills */}
      <div className="flex gap-2 mb-5 flex-wrap">
        {FILTERS.map((f) => (
          <button
            key={f.key}
            onClick={() => setFilter(f.key)}
            className="px-4 py-1.5 rounded-full text-xs font-medium transition-all"
            style={{
              background: filter === f.key ? "#ff6b00" : "rgba(255,255,255,0.06)",
              color: filter === f.key ? "#fff" : "var(--phoenix-text-secondary, #a1a1aa)",
              border: filter === f.key ? "1px solid #ff6b00" : "1px solid rgba(255,255,255,0.08)",
            }}
          >
            {f.label}
          </button>
        ))}

        <button
          onClick={loadJobs}
          className="ml-auto flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs"
          style={{ background: "rgba(255,107,0,0.1)", color: "#ff6b00", border: "1px solid rgba(255,107,0,0.2)" }}
        >
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <polyline points="23 4 23 10 17 10" /><polyline points="1 20 1 14 7 14" />
            <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15" />
          </svg>
          Atualizar
        </button>
      </div>

      {/* Table */}
      <div className="rounded-2xl overflow-hidden" style={cardStyle}>
        <div
          className="grid px-5 py-3 text-xs font-medium"
          style={{
            gridTemplateColumns: "180px 100px 80px 80px 110px 100px",
            color: "var(--phoenix-text-secondary, #a1a1aa)",
            borderBottom: "1px solid rgba(255,255,255,0.06)",
          }}
        >
          <span>DATA</span>
          <span>TIPO</span>
          <span>TAMANHO</span>
          <span>KEYS</span>
          <span>STATUS</span>
          <span>AÇÕES</span>
        </div>

        {loading ? (
          <div className="py-16 text-center">
            <div className="w-6 h-6 border-2 rounded-full animate-spin mx-auto" style={{ borderColor: "rgba(255,255,255,0.1)", borderTopColor: "#ff6b00" }} />
          </div>
        ) : error ? (
          <div className="py-12 text-center">
            <p className="text-sm" style={{ color: "#ef4444" }}>{error}</p>
            <button onClick={loadJobs} className="mt-3 text-xs" style={{ color: "#ff6b00" }}>Tentar novamente</button>
          </div>
        ) : !selectedProject ? (
          <div className="py-16 text-center">
            <p className="text-sm" style={{ color: "var(--phoenix-text-secondary, #71717a)" }}>Selecione um projeto para ver os backups.</p>
          </div>
        ) : filtered.length === 0 ? (
          <div className="py-16 text-center">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.1)" strokeWidth="1" className="mx-auto mb-3">
              <polyline points="23 4 23 10 17 10" /><polyline points="1 20 1 14 7 14" />
              <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15" />
            </svg>
            <p className="text-sm" style={{ color: "var(--phoenix-text-secondary, #71717a)" }}>Nenhum backup encontrado.</p>
          </div>
        ) : (
          filtered.map((job) => {
            const stats = job.statsJson as Record<string, number> | null;
            const keys = stats?.keysProcessed ?? stats?.keys ?? null;
            return (
              <div
                key={job.id}
                className="grid px-5 py-3.5 items-center text-xs hover:bg-white/[0.02] transition-colors"
                style={{
                  gridTemplateColumns: "180px 100px 80px 80px 110px 100px",
                  borderBottom: "1px solid rgba(255,255,255,0.04)",
                }}
              >
                <span style={{ color: "var(--phoenix-text-secondary, #a1a1aa)", fontFamily: "monospace" }}>
                  {new Date(job.createdAt).toLocaleString("pt-BR")}
                </span>
                <TypeBadge scheduleId={job.scheduleId} />
                <span style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>—</span>
                <span style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
                  {keys !== null ? keys.toLocaleString() : "—"}
                </span>
                <StatusBadge status={job.status} />
                <div className="flex items-center gap-3">
                  <button title="Ver detalhes" style={{ color: "#a1a1aa" }} className="hover:text-white transition-colors">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" /><circle cx="12" cy="12" r="3" /></svg>
                  </button>
                  <button title="Restaurar" style={{ color: "#a1a1aa" }} className="hover:text-orange-400 transition-colors">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="1 4 1 10 7 10" /><path d="M3.51 15a9 9 0 1 0 .49-4.51" /></svg>
                  </button>
                  <button title="Download" style={{ color: "#a1a1aa" }} className="hover:text-white transition-colors">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" /><polyline points="7 10 12 15 17 10" /><line x1="12" y1="15" x2="12" y2="3" /></svg>
                  </button>
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Pagination */}
      {!loading && total > limit && (
        <div className="flex items-center justify-between mt-4">
          <p className="text-xs" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
            {total} snapshots • página {page} de {totalPages}
          </p>
          <div className="flex gap-2">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page === 1}
              className="px-3 py-1.5 rounded-lg text-xs"
              style={{ background: "rgba(255,255,255,0.06)", color: page === 1 ? "#3f3f46" : "#a1a1aa", cursor: page === 1 ? "not-allowed" : "pointer" }}
            >Anterior</button>
            <button
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              disabled={page === totalPages}
              className="px-3 py-1.5 rounded-lg text-xs"
              style={{ background: "rgba(255,255,255,0.06)", color: page === totalPages ? "#3f3f46" : "#a1a1aa", cursor: page === totalPages ? "not-allowed" : "pointer" }}
            >Próxima</button>
          </div>
        </div>
      )}
    </div>
  );
}
