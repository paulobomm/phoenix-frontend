"use client";

import { useState } from "react";
import { useProjects } from "@/hooks/useProjects";
import { PhoenixButton } from "@/components/ui/PhoenixButton";
import { PhoenixTextField } from "@/components/ui/PhoenixTextField";

export default function ProjectsPage() {
  const { projects, loading, error, createProject, deleteProject } = useProjects();
  const [showForm, setShowForm] = useState(false);
  const [name, setName] = useState("");
  const [universeId, setUniverseId] = useState("");
  const [apiKey, setApiKey] = useState("");
  const [creating, setCreating] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError(null);
    try {
      setCreating(true);
      await createProject({ name, universeId, apiKey });
      setName("");
      setUniverseId("");
      setApiKey("");
      setShowForm(false);
    } catch {
      setFormError("Erro ao conectar projeto. Verifique os dados e tente novamente.");
    } finally {
      setCreating(false);
    }
  };

  return (
    <div>
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold" style={{ color: "var(--phoenix-text, #fafafa)" }}>
            Projetos
          </h2>
          <p className="text-sm mt-1" style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}>
            Conecte seus jogos Roblox via Universe ID e Open Cloud API Key.
          </p>
        </div>
        <PhoenixButton
          label={showForm ? "Cancelar" : "+ Conectar Jogo"}
          onClick={() => { setShowForm(!showForm); setFormError(null); }}
          width="auto"
        />
      </div>

      {/* Create form */}
      {showForm && (
        <form
          onSubmit={handleCreate}
          className="rounded-2xl p-6 mb-6 flex flex-col gap-4"
          style={{
            background: "var(--phoenix-card, #18181b)",
            border: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))",
          }}
        >
          <h3 className="font-semibold" style={{ color: "var(--phoenix-text, #fafafa)" }}>
            Conectar Novo Jogo
          </h3>
          <PhoenixTextField
            label="Nome do Projeto"
            placeholder="Ex: My Epic Game"
            value={name}
            onChange={setName}
          />
          <PhoenixTextField
            label="Universe ID"
            placeholder="Ex: 123456789"
            value={universeId}
            onChange={setUniverseId}
          />
          <PhoenixTextField
            label="Open Cloud API Key"
            placeholder="opencloud_..."
            value={apiKey}
            onChange={setApiKey}
            showToggle
          />
          <div
            className="flex items-start gap-2 rounded-xl p-3"
            style={{
              background: "rgba(255,107,0,0.06)",
              border: "1px solid rgba(255,107,0,0.15)",
            }}
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="var(--phoenix-primary, #ff6b00)" className="mt-0.5 shrink-0">
              <circle cx="12" cy="12" r="10" />
              <line x1="12" y1="8" x2="12" y2="12" stroke="white" strokeWidth="2" />
              <line x1="12" y1="16" x2="12.01" y2="16" stroke="white" strokeWidth="2" />
            </svg>
            <p className="text-xs" style={{ color: "var(--phoenix-primary, #ff6b00)" }}>
              A API Key é criptografada em repouso e nunca é retornada pela API.
            </p>
          </div>
          {formError && (
            <p className="text-xs" style={{ color: "var(--phoenix-error, #ef4444)" }}>
              {formError}
            </p>
          )}
          <PhoenixButton
            label="Conectar Jogo"
            type="submit"
            isLoading={creating}
            width="100%"
          />
        </form>
      )}

      {/* State feedback */}
      {loading && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1, 2, 3].map((i) => (
            <div
              key={i}
              className="rounded-2xl h-40 animate-pulse"
              style={{ background: "var(--phoenix-card, #18181b)" }}
            />
          ))}
        </div>
      )}

      {error && (
        <p className="text-sm" style={{ color: "var(--phoenix-error, #ef4444)" }}>
          {error}
        </p>
      )}

      {!loading && !error && projects.length === 0 && (
        <div
          className="text-center py-20 rounded-2xl"
          style={{
            background: "var(--phoenix-card, #18181b)",
            border: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))",
          }}
        >
          <svg
            width="48"
            height="48"
            viewBox="0 0 24 24"
            fill="none"
            stroke="rgba(255,255,255,0.15)"
            strokeWidth="1"
            className="mx-auto mb-4"
          >
            <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
          </svg>
          <p
            className="text-lg font-medium"
            style={{ color: "var(--phoenix-text, #fafafa)" }}
          >
            Nenhum projeto conectado
          </p>
          <p
            className="text-sm mt-1"
            style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}
          >
            Clique em &quot;+ Conectar Jogo&quot; para começar.
          </p>
        </div>
      )}

      {/* Project cards */}
      {!loading && !error && projects.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {projects.map((project) => (
            <div
              key={project.id}
              className="rounded-2xl p-5 flex flex-col gap-3 group"
              style={{
                background: "var(--phoenix-card, #18181b)",
                border: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))",
              }}
            >
              <div className="flex items-start justify-between gap-2">
                <h3
                  className="font-semibold"
                  style={{ color: "var(--phoenix-text, #fafafa)" }}
                >
                  {project.name}
                </h3>
                <span
                  className="text-xs px-2.5 py-1 rounded-full font-medium shrink-0"
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

              <div
                className="flex items-center gap-2 rounded-lg px-3 py-2"
                style={{ background: "rgba(255,255,255,0.03)" }}
              >
                <svg
                  width="12"
                  height="12"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="var(--phoenix-text-secondary, #a1a1aa)"
                  strokeWidth="2"
                  className="shrink-0"
                >
                  <circle cx="12" cy="12" r="10" />
                  <line x1="2" y1="12" x2="22" y2="12" />
                  <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
                </svg>
                <span
                  className="text-xs font-mono"
                  style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}
                >
                  {project.universeId}
                </span>
              </div>

              <div
                className="flex items-center justify-between mt-auto pt-3"
                style={{ borderTop: "1px solid var(--phoenix-border, rgba(255,255,255,0.06))" }}
              >
                <span
                  className="text-xs"
                  style={{ color: "var(--phoenix-text-secondary, #71717a)" }}
                >
                  {new Date(project.createdAt).toLocaleDateString("pt-BR")}
                </span>
                <button
                  onClick={() => deleteProject(project.id)}
                  className="text-xs transition-colors"
                  style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}
                  onMouseEnter={(e) => {
                    (e.currentTarget as HTMLButtonElement).style.color = "var(--phoenix-error, #ef4444)";
                  }}
                  onMouseLeave={(e) => {
                    (e.currentTarget as HTMLButtonElement).style.color = "var(--phoenix-text-secondary, #a1a1aa)";
                  }}
                >
                  Desconectar
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
