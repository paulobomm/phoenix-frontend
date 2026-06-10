"use client";

import { useState, useEffect, useCallback } from "react";
import { auditApi } from "@/services/api";
import { useProjects } from "@/hooks/useProjects";

interface AuditEvent {
  id: string;
  occurredAt: string;
  exchange: string;
  routingKey: string;
  eventType: string;
  projectId: string | null;
  payload: unknown;
  receivedAt: string;
}

export default function HistoricoPage() {
  const { projects } = useProjects();
  const [events, setEvents] = useState<AuditEvent[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [projectFilter, setProjectFilter] = useState("");
  const [typeFilter, setTypeFilter] = useState("");
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const limit = 20;

  const loadEvents = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params: Record<string, string | number> = { _page: page, _size: limit };
      if (projectFilter) params.project_id = projectFilter;
      if (typeFilter) params.type = typeFilter;
      const res = await auditApi.get("/", { params });
      const data = res.data;
      setEvents(data.data ?? []);
      setTotal(data.total ?? 0);
    } catch {
      setError("Erro ao carregar histórico.");
    } finally {
      setLoading(false);
    }
  }, [page, projectFilter, typeFilter]);

  useEffect(() => {
    void loadEvents();
  }, [loadEvents]);

  const totalPages = Math.max(1, Math.ceil(total / limit));

  const cardStyle = {
    background: "var(--phoenix-card, #18181b)",
    border: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))",
  };

  const inputStyle = {
    background: "rgba(255,255,255,0.04)",
    border: "1px solid rgba(255,255,255,0.1)",
    color: "var(--phoenix-text, #fafafa)",
    borderRadius: "10px",
    padding: "7px 11px",
    fontSize: "13px",
    outline: "none",
  };

  return (
    <div>
      <div className="mb-8">
        <h2 className="text-2xl font-bold" style={{ color: "var(--phoenix-text, #fafafa)" }}>
          Histórico
        </h2>
        <p className="text-sm mt-1" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
          Log de eventos de domínio registrados em todos os serviços.
        </p>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3 mb-5">
        <select
          value={projectFilter}
          onChange={(e) => { setProjectFilter(e.target.value); setPage(1); }}
          style={{ ...inputStyle, minWidth: 200 }}
        >
          <option value="">Todos os projetos</option>
          {projects.map((p) => (
            <option key={p.id} value={p.id} style={{ background: "#18181b" }}>{p.name}</option>
          ))}
        </select>

        <input
          type="text"
          placeholder="Filtrar por tipo (ex: project.created)"
          value={typeFilter}
          onChange={(e) => { setTypeFilter(e.target.value); setPage(1); }}
          style={{ ...inputStyle, minWidth: 260 }}
        />

        <button
          onClick={() => { setProjectFilter(""); setTypeFilter(""); setPage(1); }}
          className="px-3 py-1.5 rounded-lg text-xs"
          style={{ background: "rgba(255,255,255,0.06)", color: "var(--phoenix-text-secondary, #a1a1aa)" }}
        >
          Limpar filtros
        </button>
      </div>

      {/* Table */}
      <div className="rounded-2xl overflow-hidden" style={cardStyle}>
        {/* Header */}
        <div
          className="grid px-5 py-3 text-xs font-medium"
          style={{
            gridTemplateColumns: "160px 1fr 1fr 80px",
            color: "var(--phoenix-text-secondary, #a1a1aa)",
            borderBottom: "1px solid rgba(255,255,255,0.06)",
          }}
        >
          <span>Timestamp</span>
          <span>Tipo de Evento</span>
          <span>Rota</span>
          <span>Projeto</span>
        </div>

        {loading ? (
          <div className="py-16 text-center">
            <div className="w-6 h-6 border-2 rounded-full animate-spin mx-auto" style={{ borderColor: "rgba(255,255,255,0.1)", borderTopColor: "#ff6b00" }} />
          </div>
        ) : error ? (
          <div className="py-12 text-center">
            <p className="text-sm" style={{ color: "#ef4444" }}>{error}</p>
            <button onClick={loadEvents} className="mt-3 text-xs" style={{ color: "#ff6b00" }}>Tentar novamente</button>
          </div>
        ) : events.length === 0 ? (
          <div className="py-16 text-center">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.1)" strokeWidth="1" className="mx-auto mb-3">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
              <polyline points="14 2 14 8 20 8" />
            </svg>
            <p className="text-sm" style={{ color: "var(--phoenix-text-secondary, #71717a)" }}>Nenhum evento encontrado.</p>
          </div>
        ) : (
          <div>
            {events.map((ev) => (
              <div
                key={ev.id}
                className="grid px-5 py-3 text-xs items-center hover:bg-white/[0.02] transition-colors"
                style={{ gridTemplateColumns: "160px 1fr 1fr 80px", borderBottom: "1px solid rgba(255,255,255,0.04)" }}
              >
                <span style={{ color: "#52525b", fontFamily: "monospace" }}>
                  {new Date(ev.occurredAt).toLocaleString("pt-BR")}
                </span>
                <span
                  className="inline-flex items-center"
                  style={{ color: "var(--phoenix-primary, #ff6b00)", fontFamily: "monospace" }}
                  title={ev.eventType}
                >
                  <span className="truncate max-w-[220px]">{ev.eventType}</span>
                </span>
                <span style={{ color: "var(--phoenix-text-secondary, #a1a1aa)", fontFamily: "monospace" }}
                  title={`${ev.exchange} / ${ev.routingKey}`}
                >
                  <span className="truncate max-w-[200px] block">{ev.routingKey}</span>
                </span>
                <span style={{ color: "#52525b", fontFamily: "monospace" }}>
                  {ev.projectId ? ev.projectId.slice(0, 6) + "..." : "—"}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Pagination */}
      {!loading && total > limit && (
        <div className="flex items-center justify-between mt-4">
          <p className="text-xs" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
            {total} eventos • página {page} de {totalPages}
          </p>
          <div className="flex gap-2">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page === 1}
              className="px-3 py-1.5 rounded-lg text-xs"
              style={{
                background: "rgba(255,255,255,0.06)",
                color: page === 1 ? "#3f3f46" : "var(--phoenix-text-secondary, #a1a1aa)",
                cursor: page === 1 ? "not-allowed" : "pointer",
              }}
            >
              Anterior
            </button>
            <button
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              disabled={page === totalPages}
              className="px-3 py-1.5 rounded-lg text-xs"
              style={{
                background: "rgba(255,255,255,0.06)",
                color: page === totalPages ? "#3f3f46" : "var(--phoenix-text-secondary, #a1a1aa)",
                cursor: page === totalPages ? "not-allowed" : "pointer",
              }}
            >
              Próxima
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
