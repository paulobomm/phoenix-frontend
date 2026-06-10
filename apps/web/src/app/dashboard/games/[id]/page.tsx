"use client";

import { useState, useEffect } from "react";
import { useParams, useRouter } from "next/navigation";
import { projectsService } from "@/services/projects.service";
import { snapshotsService } from "@/services/snapshots.service";
import { useProjectStore } from "@/store/project.store";
import { PhoenixButton } from "@/components/ui/PhoenixButton";
import { PhoenixTextField } from "@/components/ui/PhoenixTextField";
import type { Project } from "@/types/project";

const statusOptions = [
  { value: "active", label: "Ativo", color: "#22C55E", bg: "rgba(34,197,94,0.15)" },
  { value: "paused", label: "Pausado", color: "#F59E0B", bg: "rgba(245,158,11,0.15)" },
  { value: "archived", label: "Arquivado", color: "#6B6B6B", bg: "rgba(107,107,107,0.15)" },
];

export default function GameDetailPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const { setSelectedProject } = useProjectStore();

  const [project, setProject] = useState<Project | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [backingUp, setBackingUp] = useState(false);
  const [name, setName] = useState("");
  const [status, setStatus] = useState<"active" | "paused" | "archived">("active");
  const [newApiKey, setNewApiKey] = useState("");
  const [rotatingKey, setRotatingKey] = useState(false);
  const [saved, setSaved] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  useEffect(() => {
    projectsService.get(id).then((p) => {
      setProject(p);
      setName(p.name);
      setStatus(p.status);
      setLoading(false);
    }).catch(() => setLoading(false));
  }, [id]);

  const handleSave = async () => {
    setSaving(true);
    try {
      await projectsService.update(id, { name, status });
      setProject((prev) => prev ? { ...prev, name, status } : prev);
      setSelectedProject({ ...project!, name, status });
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } catch { alert("Erro ao salvar"); }
    finally { setSaving(false); }
  };

  const handleRotateKey = async () => {
    if (!newApiKey) return;
    setRotatingKey(true);
    try {
      await projectsService.rotateKey(id, newApiKey);
      setNewApiKey("");
      alert("API Key atualizada com sucesso!");
    } catch { alert("Erro ao rotacionar API Key"); }
    finally { setRotatingKey(false); }
  };

  const handleDelete = async () => {
    setDeleting(true);
    try {
      await projectsService.delete(id);
      router.push("/dashboard/games");
    } catch { alert("Erro ao excluir projeto"); }
    finally { setDeleting(false); }
  };

  const handleBackup = async () => {
    setBackingUp(true);
    try {
      await snapshotsService.triggerManual(id);
      alert("Backup iniciado com sucesso!");
    } catch { alert("Erro ao iniciar backup"); }
    finally { setBackingUp(false); }
  };

  if (loading) return (
    <div className="p-6 flex items-center justify-center py-24">
      <svg className="animate-spin w-8 h-8" viewBox="0 0 24 24" fill="none">
        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="var(--phoenix-primary)" strokeWidth="4"/>
        <path className="opacity-75" fill="var(--phoenix-primary)" d="M4 12a8 8 0 018-8v8H4z"/>
      </svg>
    </div>
  );

  if (!project) return (
    <div className="p-6 text-center py-24" style={{ color: "var(--phoenix-text-secondary)" }}>
      Projeto não encontrado
    </div>
  );

  const statusInfo = statusOptions.find(s => s.value === status) || statusOptions[0];

  return (
    <div className="p-6 max-w-2xl">
      {/* Header */}
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => router.back()} style={{ color: "var(--phoenix-text-secondary)" }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="15 18 9 12 15 6"/></svg>
        </button>
        <div className="flex-1">
          <h1 className="text-xl font-bold" style={{ color: "var(--phoenix-text)" }}>{project.name}</h1>
          <p className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>Configurações do jogo</p>
        </div>
        <span className="text-xs px-2.5 py-1 rounded-lg font-medium" style={{ background: statusInfo.bg, color: statusInfo.color }}>
          {statusInfo.label}
        </span>
      </div>

      {/* Info Card */}
      <div className="rounded-2xl border p-5 mb-5" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
        <div className="flex flex-col items-center mb-5">
          <div className="w-16 h-16 rounded-2xl flex items-center justify-center text-3xl mb-3" style={{ background: "rgba(255,107,0,0.15)", border: "1px solid rgba(255,107,0,0.25)" }}>🎮</div>
          <h2 className="text-lg font-bold" style={{ color: "var(--phoenix-text)" }}>{project.name}</h2>
        </div>
        <div className="flex flex-col gap-2">
          {[
            { label: "Universe ID", value: project.universeId },
            { label: "Status", value: statusInfo.label },
            { label: "Criado em", value: project.createdAt ? new Date(project.createdAt).toLocaleDateString("pt-BR") : "—" },
          ].map((r) => (
            <div key={r.label} className="flex items-center justify-between py-2 border-b" style={{ borderColor: "var(--phoenix-border)" }}>
              <span className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>{r.label}</span>
              <span className="text-sm font-medium" style={{ color: "var(--phoenix-text)" }}>{r.value}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Ações Rápidas */}
      <div className="mb-5">
        <h3 className="font-semibold mb-3" style={{ color: "var(--phoenix-text)" }}>Ações Rápidas</h3>
        <div className="flex flex-col gap-2">
          {[
            { icon: "☁️", label: "Backup Manual", desc: "Criar um backup agora", color: "#FF6B00", bg: "rgba(255,107,0,0.12)", onClick: handleBackup, loading: backingUp },
            { icon: "💾", label: "Ver DataStores", desc: "Ver datastores deste jogo", color: "#60A5FA", bg: "rgba(96,165,250,0.12)", onClick: () => router.push(`/dashboard/datastores?project=${id}`) },
            { icon: "📸", label: "Ver Snapshots", desc: "Histórico de backups", color: "#22C55E", bg: "rgba(34,197,94,0.12)", onClick: () => router.push("/dashboard/snapshots") },
          ].map((action) => (
            <button key={action.label} onClick={action.onClick} disabled={action.loading}
              className="flex items-center gap-4 p-4 rounded-xl border text-left transition-all disabled:opacity-50"
              style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
              <div className="w-10 h-10 rounded-xl flex items-center justify-center text-xl" style={{ background: action.bg }}>{action.loading ? "⏳" : action.icon}</div>
              <div className="flex-1">
                <p className="font-semibold text-sm" style={{ color: "var(--phoenix-text)" }}>{action.label}</p>
                <p className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>{action.desc}</p>
              </div>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--phoenix-text-secondary)" strokeWidth="2"><polyline points="9 18 15 12 9 6"/></svg>
            </button>
          ))}
        </div>
      </div>

      {/* Editar informações */}
      <div className="rounded-2xl border p-5 mb-5" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
        <h3 className="font-semibold mb-4" style={{ color: "var(--phoenix-text)" }}>Editar Informações</h3>
        <div className="flex flex-col gap-4">
          <PhoenixTextField label="Nome do Jogo" value={name} onChange={setName} />
          <div className="flex flex-col gap-1.5">
            <label className="text-xs font-semibold uppercase tracking-wide" style={{ color: "var(--phoenix-text-secondary)" }}>Status</label>
            <div className="flex gap-2">
              {statusOptions.map((opt) => (
                <button key={opt.value} onClick={() => setStatus(opt.value as any)}
                  className="flex-1 py-2.5 rounded-xl text-sm font-medium border transition-all"
                  style={{
                    background: status === opt.value ? opt.bg : "transparent",
                    borderColor: status === opt.value ? opt.color : "var(--phoenix-border)",
                    color: status === opt.value ? opt.color : "var(--phoenix-text-secondary)",
                  }}>
                  {opt.label}
                </button>
              ))}
            </div>
          </div>
          <PhoenixButton
            label={saved ? "✓ Salvo!" : "Salvar Alterações"}
            onClick={handleSave}
            isLoading={saving}
            width="100%"
          />
        </div>
      </div>

      {/* Rotacionar API Key */}
      <div className="rounded-2xl border p-5 mb-5" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
        <h3 className="font-semibold mb-1" style={{ color: "var(--phoenix-text)" }}>Rotacionar API Key</h3>
        <p className="text-xs mb-4" style={{ color: "var(--phoenix-text-secondary)" }}>Substitua a API Key armazenada por uma nova</p>
        <div className="flex flex-col gap-3">
          <PhoenixTextField label="Nova API Key" placeholder="rbxp_..." value={newApiKey} onChange={setNewApiKey} showToggle />
          <PhoenixButton label="Atualizar API Key" onClick={handleRotateKey} isLoading={rotatingKey} width="100%" />
        </div>
      </div>

      {/* Zona de perigo */}
      <div className="rounded-2xl border p-5" style={{ background: "rgba(239,68,68,0.05)", borderColor: "rgba(239,68,68,0.25)" }}>
        <h3 className="font-semibold mb-1" style={{ color: "#EF4444" }}>Zona de Perigo</h3>
        <p className="text-xs mb-4" style={{ color: "var(--phoenix-text-secondary)" }}>Esta ação é irreversível. Todos os dados do projeto serão removidos.</p>
        {!showDeleteConfirm ? (
          <button onClick={() => setShowDeleteConfirm(true)}
            className="w-full py-3 rounded-xl text-sm font-semibold border transition-all"
            style={{ borderColor: "rgba(239,68,68,0.4)", color: "#EF4444", background: "rgba(239,68,68,0.08)" }}>
            Excluir Projeto
          </button>
        ) : (
          <div className="flex flex-col gap-2">
            <p className="text-sm text-center font-medium" style={{ color: "#EF4444" }}>Tem certeza? Esta ação não pode ser desfeita.</p>
            <div className="flex gap-2">
              <PhoenixButton label="Cancelar" onClick={() => setShowDeleteConfirm(false)} variant="outline" width="100%" />
              <button onClick={handleDelete} disabled={deleting}
                className="flex-1 py-3 rounded-xl text-sm font-semibold text-white disabled:opacity-50"
                style={{ background: "#EF4444" }}>
                {deleting ? "Excluindo..." : "Confirmar Exclusão"}
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
