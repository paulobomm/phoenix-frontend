"use client";

import { useState, useEffect, useCallback } from "react";
import { restoreApi, snapshotsApi } from "@/services/api";
import { useProjects } from "@/hooks/useProjects";

type RestoreScope = "single_key" | "datastore" | "project";

interface RestoreJob {
  id: string;
  projectId: string;
  sourceSnapshotId: string;
  scope: string;
  targetDatastoreName: string | null;
  targetKey: string | null;
  status: string;
  dryRun: boolean;
  startedAt: string | null;
  completedAt: string | null;
  summaryJson: { entriesAttempted: number; entriesWritten: number; entriesFailed: number } | null;
  errors: string | null;
  createdAt: string;
}

interface SnapshotJob {
  id: string;
  status: string;
  createdAt: string;
}

const statusColors: Record<string, string> = {
  scheduled: "rgba(234,179,8,0.15)",
  running: "rgba(59,130,246,0.15)",
  completed: "rgba(34,197,94,0.15)",
  failed: "rgba(239,68,68,0.15)",
};
const statusTextColors: Record<string, string> = {
  scheduled: "#eab308",
  running: "#3b82f6",
  completed: "#22c55e",
  failed: "#ef4444",
};

export default function RestorePage() {
  const { projects } = useProjects();
  const [selectedProjectId, setSelectedProjectId] = useState("");
  const [jobs, setJobs] = useState<RestoreJob[]>([]);
  const [snapshots, setSnapshots] = useState<SnapshotJob[]>([]);
  const [loadingJobs, setLoadingJobs] = useState(false);
  const [showForm, setShowForm] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [form, setForm] = useState({
    sourceSnapshotId: "",
    scope: "project" as RestoreScope,
    targetDatastoreName: "",
    targetKey: "",
    dryRun: true,
  });

  const loadJobs = useCallback(async (projectId: string) => {
    if (!projectId) return;
    try {
      setLoadingJobs(true);
      const res = await restoreApi.get(`/projects/${projectId}/restores`);
      setJobs(res.data ?? []);
    } catch {
      setJobs([]);
    } finally {
      setLoadingJobs(false);
    }
  }, []);

  const loadSnapshots = useCallback(async (projectId: string) => {
    if (!projectId) return;
    try {
      const res = await snapshotsApi.get(`/projects/${projectId}/snapshots`);
      const data = res.data;
      const list = Array.isArray(data) ? data : (data?.data ?? []);
      setSnapshots(list.filter((s: SnapshotJob) => s.status === "completed"));
    } catch {
      setSnapshots([]);
    }
  }, []);

  useEffect(() => {
    if (projects.length > 0 && !selectedProjectId) {
      setSelectedProjectId(projects[0].id);
    }
  }, [projects, selectedProjectId]);

  useEffect(() => {
    if (selectedProjectId) {
      void loadJobs(selectedProjectId);
      void loadSnapshots(selectedProjectId);
    }
  }, [selectedProjectId, loadJobs, loadSnapshots]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.sourceSnapshotId) { setError("Selecione um snapshot."); return; }
    setSubmitting(true);
    setError(null);
    try {
      await restoreApi.post("/restores", {
        projectId: selectedProjectId,
        sourceSnapshotId: form.sourceSnapshotId,
        scope: form.scope,
        ...(form.scope !== "project" && form.targetDatastoreName
          ? { targetDatastoreName: form.targetDatastoreName }
          : {}),
        ...(form.scope === "single_key" && form.targetKey
          ? { targetKey: form.targetKey }
          : {}),
        dryRun: form.dryRun,
      });
      setShowForm(false);
      await loadJobs(selectedProjectId);
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message;
      setError(msg ?? "Erro ao solicitar restore.");
    } finally {
      setSubmitting(false);
    }
  };

  const handleApprove = async (jobId: string) => {
    try {
      await restoreApi.post(`/restores/${jobId}/approve`);
      await loadJobs(selectedProjectId);
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message;
      alert(msg ?? "Erro ao aprovar restore.");
    }
  };

  const cardStyle = {
    background: "var(--phoenix-card, #18181b)",
    border: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))",
  };

  const inputStyle = {
    background: "rgba(255,255,255,0.04)",
    border: "1px solid rgba(255,255,255,0.1)",
    color: "var(--phoenix-text, #fafafa)",
    borderRadius: "10px",
    padding: "8px 12px",
    fontSize: "14px",
    width: "100%",
    outline: "none",
  };

  return (
    <div>
      <div className="mb-8 flex items-start justify-between">
        <div>
          <h2 className="text-2xl font-bold" style={{ color: "var(--phoenix-text, #fafafa)" }}>
            Restore
          </h2>
          <p className="text-sm mt-1" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
            Restaure DataStores a partir de um snapshot.
          </p>
        </div>
        <button
          onClick={() => setShowForm((v) => !v)}
          className="px-4 py-2 rounded-xl text-sm font-medium transition-all"
          style={{
            background: "var(--phoenix-primary, #ff6b00)",
            color: "#fff",
          }}
        >
          {showForm ? "Cancelar" : "+ Solicitar Restore"}
        </button>
      </div>

      {/* Project selector */}
      <div className="mb-6">
        <label className="block text-xs font-medium mb-2" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
          Projeto
        </label>
        <select
          value={selectedProjectId}
          onChange={(e) => setSelectedProjectId(e.target.value)}
          style={{ ...inputStyle, maxWidth: 320 }}
        >
          {projects.map((p) => (
            <option key={p.id} value={p.id} style={{ background: "#18181b" }}>
              {p.name}
            </option>
          ))}
        </select>
      </div>

      {/* Request form */}
      {showForm && (
        <form
          onSubmit={handleSubmit}
          className="rounded-2xl p-6 mb-6"
          style={cardStyle}
        >
          <h3 className="font-semibold text-sm mb-4" style={{ color: "var(--phoenix-text, #fafafa)" }}>
            Nova solicitação de restore
          </h3>

          {error && (
            <div className="mb-4 p-3 rounded-xl text-sm" style={{ background: "rgba(239,68,68,0.08)", color: "#ef4444", border: "1px solid rgba(239,68,68,0.2)" }}>
              {error}
            </div>
          )}

          <div className="grid gap-4">
            <div>
              <label className="block text-xs mb-1.5" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>Snapshot de origem</label>
              <select
                required
                value={form.sourceSnapshotId}
                onChange={(e) => setForm((f) => ({ ...f, sourceSnapshotId: e.target.value }))}
                style={inputStyle}
              >
                <option value="">Selecione um snapshot concluído</option>
                {snapshots.map((s) => (
                  <option key={s.id} value={s.id} style={{ background: "#18181b" }}>
                    {s.id.slice(0, 8)}... — {new Date(s.createdAt).toLocaleString("pt-BR")}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xs mb-1.5" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>Escopo</label>
              <select
                value={form.scope}
                onChange={(e) => setForm((f) => ({ ...f, scope: e.target.value as RestoreScope }))}
                style={inputStyle}
              >
                <option value="project" style={{ background: "#18181b" }}>Projeto inteiro</option>
                <option value="datastore" style={{ background: "#18181b" }}>DataStore específico</option>
                <option value="single_key" style={{ background: "#18181b" }}>Chave específica</option>
              </select>
            </div>

            {form.scope !== "project" && (
              <div>
                <label className="block text-xs mb-1.5" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>Nome do DataStore</label>
                <input
                  type="text"
                  placeholder="ex: PlayerData"
                  value={form.targetDatastoreName}
                  onChange={(e) => setForm((f) => ({ ...f, targetDatastoreName: e.target.value }))}
                  style={inputStyle}
                />
              </div>
            )}

            {form.scope === "single_key" && (
              <div>
                <label className="block text-xs mb-1.5" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>Chave</label>
                <input
                  type="text"
                  placeholder="ex: Player_12345"
                  value={form.targetKey}
                  onChange={(e) => setForm((f) => ({ ...f, targetKey: e.target.value }))}
                  style={inputStyle}
                />
              </div>
            )}

            <label className="flex items-center gap-3 cursor-pointer">
              <input
                type="checkbox"
                checked={form.dryRun}
                onChange={(e) => setForm((f) => ({ ...f, dryRun: e.target.checked }))}
                className="w-4 h-4"
                style={{ accentColor: "#ff6b00" }}
              />
              <div>
                <span className="text-sm" style={{ color: "var(--phoenix-text, #fafafa)" }}>Dry run (simulação)</span>
                <p className="text-xs" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>Simula o restore sem escrever dados. Recomendado antes de aprovar.</p>
              </div>
            </label>
          </div>

          <div className="flex gap-3 mt-5">
            <button
              type="submit"
              disabled={submitting}
              className="px-5 py-2 rounded-xl text-sm font-medium"
              style={{ background: "var(--phoenix-primary, #ff6b00)", color: "#fff", opacity: submitting ? 0.6 : 1 }}
            >
              {submitting ? "Enviando..." : "Solicitar"}
            </button>
            <button
              type="button"
              onClick={() => setShowForm(false)}
              className="px-5 py-2 rounded-xl text-sm"
              style={{ background: "rgba(255,255,255,0.06)", color: "var(--phoenix-text-secondary, #a1a1aa)" }}
            >
              Cancelar
            </button>
          </div>
        </form>
      )}

      {/* Jobs list */}
      <div className="rounded-2xl overflow-hidden" style={cardStyle}>
        <div
          className="px-5 py-4"
          style={{ borderBottom: "1px solid rgba(255,255,255,0.06)" }}
        >
          <h3 className="font-semibold text-sm" style={{ color: "var(--phoenix-text, #fafafa)" }}>Jobs de Restore</h3>
        </div>

        {loadingJobs ? (
          <div className="py-16 text-center">
            <div className="w-6 h-6 border-2 rounded-full animate-spin mx-auto" style={{ borderColor: "rgba(255,255,255,0.1)", borderTopColor: "#ff6b00" }} />
          </div>
        ) : jobs.length === 0 ? (
          <div className="py-16 text-center">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.1)" strokeWidth="1" className="mx-auto mb-3">
              <polyline points="1 4 1 10 7 10" />
              <path d="M3.51 15a9 9 0 1 0 .49-4.51" />
            </svg>
            <p className="text-sm" style={{ color: "var(--phoenix-text-secondary, #71717a)" }}>Nenhum restore encontrado.</p>
          </div>
        ) : (
          <div className="divide-y" style={{ borderColor: "rgba(255,255,255,0.04)" }}>
            {jobs.map((job) => (
              <div key={job.id} className="px-5 py-4 flex items-start justify-between gap-4">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <span
                      className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
                      style={{ background: statusColors[job.status] ?? "rgba(255,255,255,0.08)", color: statusTextColors[job.status] ?? "#a1a1aa" }}
                    >
                      {job.status}
                    </span>
                    {job.dryRun && (
                      <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs" style={{ background: "rgba(59,130,246,0.1)", color: "#60a5fa" }}>dry run</span>
                    )}
                    <span className="text-xs" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>{job.scope}</span>
                  </div>
                  <p className="text-xs font-mono" style={{ color: "var(--phoenix-text-secondary, #71717a)" }}>
                    snapshot: {job.sourceSnapshotId.slice(0, 8)}...
                    {job.targetDatastoreName && ` • ds: ${job.targetDatastoreName}`}
                    {job.targetKey && ` • key: ${job.targetKey}`}
                  </p>
                  {job.summaryJson && (
                    <p className="text-xs mt-1" style={{ color: "#a1a1aa" }}>
                      {job.summaryJson.entriesWritten}/{job.summaryJson.entriesAttempted} entradas escritas
                      {job.summaryJson.entriesFailed > 0 && ` • ${job.summaryJson.entriesFailed} falhas`}
                    </p>
                  )}
                  {job.errors && <p className="text-xs mt-1" style={{ color: "#ef4444" }}>{job.errors}</p>}
                  <p className="text-xs mt-1.5" style={{ color: "#52525b" }}>
                    {new Date(job.createdAt).toLocaleString("pt-BR")}
                  </p>
                </div>

                {job.status === "completed" && job.dryRun && (
                  <button
                    onClick={() => handleApprove(job.id)}
                    className="shrink-0 px-3 py-1.5 rounded-lg text-xs font-medium"
                    style={{ background: "rgba(34,197,94,0.12)", color: "#22c55e", border: "1px solid rgba(34,197,94,0.2)" }}
                  >
                    Aprovar
                  </button>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
