"use client";

import { useEffect, useRef, useState } from "react";
import { useProjects } from "@/hooks/useProjects";
import { useProjectStore } from "@/store/project.store";

export function GameSelector() {
  const { projects, loading } = useProjects();
  const { selectedProject, setSelectedProject } = useProjectStore();
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  // Auto-seleciona o primeiro projeto
  useEffect(() => {
    if (projects.length > 0 && !selectedProject) {
      setSelectedProject(projects[0]);
    }
  }, [projects, selectedProject, setSelectedProject]);

  // Fecha ao clicar fora
  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setOpen(false);
      }
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  if (loading) {
    return (
      <div className="h-16 rounded-2xl animate-pulse mb-4" style={{ background: "var(--phoenix-card)" }} />
    );
  }

  if (projects.length === 0) {
    return (
      <div className="flex items-center gap-3 p-4 rounded-2xl border mb-4"
        style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
        <div className="w-10 h-10 rounded-xl flex items-center justify-center text-lg"
          style={{ background: "rgba(107,107,107,0.15)" }}>🎮</div>
        <p className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>Nenhum jogo cadastrado</p>
      </div>
    );
  }

  return (
    <div ref={ref} className="relative mb-4">
      <button
        onClick={() => setOpen(!open)}
        className="w-full flex items-center justify-between p-4 rounded-2xl border transition-all"
        style={{
          background: "var(--phoenix-card)",
          borderColor: open ? "var(--phoenix-primary)" : "var(--phoenix-border)",
        }}
      >
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl flex items-center justify-center text-lg"
            style={{ background: "rgba(255,107,0,0.15)" }}>🎮</div>
          <div className="text-left">
            <p className="font-semibold text-sm" style={{ color: "var(--phoenix-text)" }}>
              {selectedProject?.name ?? "Selecionar jogo"}
            </p>
            <p className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>
              Universe ID: {selectedProject?.universeId ?? "—"}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {selectedProject && (
            <span className="text-xs px-2 py-1 rounded-lg font-medium"
              style={{ background: "rgba(34,197,94,0.15)", color: "#22C55E" }}>
              Ativo
            </span>
          )}
          <svg
            width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6B6B6B" strokeWidth="2"
            style={{ transform: open ? "rotate(180deg)" : "rotate(0deg)", transition: "transform 0.2s" }}
          >
            <polyline points="6 9 12 15 18 9"/>
          </svg>
        </div>
      </button>

      {/* Dropdown */}
      {open && (
        <div className="absolute top-full left-0 right-0 mt-1 rounded-2xl border z-50 overflow-hidden"
          style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
          {projects.map((project) => (
            <button
              key={project.id}
              onClick={() => { setSelectedProject(project); setOpen(false); }}
              className="w-full flex items-center gap-3 px-4 py-3 transition-all text-left"
              style={{
                background: selectedProject?.id === project.id ? "rgba(255,107,0,0.08)" : "transparent",
                borderBottom: "1px solid var(--phoenix-border)",
              }}
            >
              <div className="w-8 h-8 rounded-lg flex items-center justify-center text-base"
                style={{ background: "rgba(255,107,0,0.12)" }}>🎮</div>
              <div>
                <p className="text-sm font-medium" style={{ color: "var(--phoenix-text)" }}>{project.name}</p>
                <p className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>ID: {project.universeId}</p>
              </div>
              {selectedProject?.id === project.id && (
                <svg className="ml-auto" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--phoenix-primary)" strokeWidth="2.5">
                  <polyline points="20 6 9 17 4 12"/>
                </svg>
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
