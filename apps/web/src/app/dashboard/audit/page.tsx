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

const FILTERS = [
  { key: "all", label: "Todos" },
  { key: "backup", label: "Backup" },
  { key: "restore", label: "Restore" },
  { key: "project", label: "Projetos" },
  { key: "auth", label: "Auth" },
] as const;

type FilterKey = (typeof FILTERS)[number]["key"];

function eventMeta(ev: AuditEvent) {
  const et = ev.eventType.toLowerCase();
  const rk = ev.routingKey.toLowerCase();
  if (et.includes("snapshot") || rk.includes("snapshot")) return { label: "Backup", color: "#ff6b00", bg: "rgba(255,107,0,0.1)" };
  if (et.includes("restore") || rk.includes("restore")) return { label: "Restore", color: "#f59e0b", bg: "rgba(245,158,11,0.1)" };
  if (et.includes("project") || rk.includes("project")) return { label: "Projeto", color: "#3b82f6", bg: "rgba(59,130,246,0.1)" };
  if (et.includes("auth") || et.includes("login") || et.includes("user")) return { label: "Auth", color: "#a855f7", bg: "rgba(168,85,247,0.1)" };
  if (et.includes("failed") || et.includes("error")) return { label: "Erro", color: "#ef4444", bg: "rgba(239,68,68,0.1)" };
  return { label: "Info", color: "#a1a1aa", bg: "rgba(161,161,170,0.1)" };
}

export default function AuditPage() {
  const { projects } = useProjects();
  const [events, setEvents] = useState<AuditEvent[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [projectFilter, setProjectFilter] = useState("");
  const [filter, setFilter] = useState<FilterKey>("all");
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [expanded, setExpanded] = useState<string | null>(null);
  const limit = 25;

  const loadEvents = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params: Record<string, string | number> = { _page: page, _size: limit };
      if (projectFilter) params.project_id = projectFilter;
      const res = await auditApi.get("/", { params });
      const data = res.data;
      setEvents(data.data ?? []);
      setTotal(data.meta?.totalItems ?? data.total ?? 0);
    } catch {
      setError("Erro ao carregar auditoria.");
    } finally {
      setLoading(false);
    }
  }, [page, projectFilter]);

  useEffect(() => { void loadEvents(); }, [loadEvents]);

  const filtered = events.filter((ev) => {
    const et = ev.eventType.toLowerCase();
    const rk = ev.routingKey.toLowerCase();
    if (filter === "backup") return et.includes("snapshot") || rk.includes("snapshot");
    if (filter === "restore") return et.includes("restore") || rk.includes("restore");
    if (filter === "project") return et.includes("project") || rk.includes("project");
    if (filter === "auth") return et.includes("auth") || et.includes("login") || et.includes("user");
    return true;
  });

  const totalPages = Math.max(1, Math.ceil(total / limit));
  const cardStyle = { background: "var(--phoenix-card, #18181b)", border: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))" };
  const inputStyle = { background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.1)", color: "var(--phoenix-text, #fafafa)", borderRadius: "10px", padding: "7px 11px", fontSize: "13px", outline: "none" };

  return (
    <div>
      <div className="mb-6">
        <h2 className="text-2xl font-bold" style={{ color: "var(--phoenix-text, #fafafa)" }}>Auditoria</h2>
        <p className="text-sm mt-1" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
          Registro completo de todos os eventos de domínio do sistema.
        </p>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3 mb-5 items-center">
        <select
          value={projectFilter}
          onChange={(e) => { setProjectFilter(e.target.value); setPage(1); }}
          style={{ ...inputStyle, minWidth: 200 }}
        >
          <option value="">Todos os projetos</option>
          {projects.map((p) => <option key={p.id} value={p.id} style={{ background: "#18181b" }}>{p.name}</option>)}
        </select>

        <div className="flex gap-2 flex-wrap">
          {FILTERS.map((f) => (
            <button
              key={f.key}
              onClick={() => setFilter(f.key)}
              className="px-3 py-1.5 rounded-full text-xs font-medium transition-all"
              style={{
                background: filter === f.key ? "#ff6b00" : "rgba(255,255,255,0.06)",
                color: filter === f.key ? "#fff" : "var(--phoenix-text-secondary, #a1a1aa)",
                border: filter === f.key ? "1px solid #ff6b00" : "1px solid rgba(255,255,255,0.08)",
              }}
            >{f.label}</button>
          ))}
        </div>

        <button
          onClick={loadEvents}
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
          style={{ gridTemplateColumns: "160px 1fr 180px 80px 24px", color: "var(--phoenix-text-secondary, #a1a1aa)", borderBottom: "1px solid rgba(255,255,255,0.06)" }}
        >
          <span>TIMESTAMP</span>
          <span>TIPO DE EVENTO</span>
          <span>ROUTING KEY</span>
          <span>CATEGORIA</span>
          <span />
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
        ) : filtered.length === 0 ? (
          <div className="py-16 text-center">
            <p className="text-sm" style={{ color: "var(--phoenix-text-secondary, #71717a)" }}>Nenhum evento encontrado.</p>
          </div>
        ) : (
          filtered.map((ev) => {
            const meta = eventMeta(ev);
            const isOpen = expanded === ev.id;
            return (
              <div key={ev.id} style={{ borderBottom: "1px solid rgba(255,255,255,0.04)" }}>
                <div
                  className="grid px-5 py-3 text-xs items-center hover:bg-white/[0.02] transition-colors cursor-pointer"
                  style={{ gridTemplateColumns: "160px 1fr 180px 80px 24px" }}
                  onClick={() => setExpanded(isOpen ? null : ev.id)}
                >
                  <span style={{ color: "#52525b", fontFamily: "monospace" }}>
                    {new Date(ev.occurredAt).toLocaleString("pt-BR")}
                  </span>
                  <span style={{ color: "var(--phoenix-text, #fafafa)", fontFamily: "monospace" }} className="truncate pr-4">
                    {ev.eventType}
                  </span>
                  <span style={{ color: "var(--phoenix-text-secondary, #a1a1aa)", fontFamily: "monospace" }} className="truncate pr-4">
                    {ev.routingKey}
                  </span>
                  <span className="inline-flex items-center px-2 py-0.5 rounded-md text-xs font-medium" style={{ color: meta.color, background: meta.bg }}>
                    {meta.label}
                  </span>
                  <svg
                    width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#52525b" strokeWidth="2"
                    style={{ transform: isOpen ? "rotate(180deg)" : "rotate(0)", transition: "transform 0.2s" }}
                  >
                    <polyline points="6 9 12 15 18 9" />
                  </svg>
                </div>

                {isOpen && (
                  <div className="px-5 pb-4">
                    <pre
                      className="text-xs p-3 rounded-xl overflow-auto max-h-60"
                      style={{ background: "rgba(0,0,0,0.3)", color: "#a1a1aa", fontFamily: "monospace", lineHeight: 1.6 }}
                    >
                      {JSON.stringify({ exchange: ev.exchange, routingKey: ev.routingKey, projectId: ev.projectId, occurredAt: ev.occurredAt, receivedAt: ev.receivedAt, payload: ev.payload }, null, 2)}
                    </pre>
                  </div>
                )}
              </div>
            );
          })
        )}
      </div>

      {/* Pagination */}
      {!loading && total > limit && (
        <div className="flex items-center justify-between mt-4">
          <p className="text-xs" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
            {total} eventos • página {page} de {totalPages}
          </p>
          <div className="flex gap-2">
            <button onClick={() => setPage((p) => Math.max(1, p - 1))} disabled={page === 1}
              className="px-3 py-1.5 rounded-lg text-xs"
              style={{ background: "rgba(255,255,255,0.06)", color: page === 1 ? "#3f3f46" : "#a1a1aa", cursor: page === 1 ? "not-allowed" : "pointer" }}
            >Anterior</button>
            <button onClick={() => setPage((p) => Math.min(totalPages, p + 1))} disabled={page === totalPages}
              className="px-3 py-1.5 rounded-lg text-xs"
              style={{ background: "rgba(255,255,255,0.06)", color: page === totalPages ? "#3f3f46" : "#a1a1aa", cursor: page === totalPages ? "not-allowed" : "pointer" }}
            >Próxima</button>
          </div>
        </div>
      )}
    </div>
  );
}
