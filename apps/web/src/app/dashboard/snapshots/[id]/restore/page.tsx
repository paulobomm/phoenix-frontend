"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { useProjectStore } from "@/store/project.store";
import { restoreService } from "@/services/restore.service";
import { PhoenixButton } from "@/components/ui/PhoenixButton";
import type { RestoreScope } from "@/types/snapshot";

const steps = ["Origem", "Destino", "Confirmação", "Progresso", "Conclusão"];

export default function RestoreWizardPage() {
  const { id: snapshotId } = useParams<{ id: string }>();
  const router = useRouter();
  const { selectedProject } = useProjectStore();

  const [step, setStep] = useState(0);
  const [scope, setScope] = useState<RestoreScope>("full");
  const [destination, setDestination] = useState<"same" | "new">("same");
  const [dryRun, setDryRun] = useState(false);
  const [restoreJob, setRestoreJob] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [done, setDone] = useState(false);

  const handleRestore = async () => {
    if (!selectedProject) return;
    setLoading(true);
    try {
      const job = await restoreService.request({
        projectId: selectedProject.id,
        sourceSnapshotId: snapshotId,
        scope,
        dryRun,
      });
      setRestoreJob(job);
      setStep(3);
      setTimeout(() => { setStep(4); setDone(true); }, 2000);
    } catch (e) {
      alert("Erro ao iniciar restore");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 max-w-2xl">
      {/* Header */}
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => router.back()} style={{ color: "var(--phoenix-text-secondary)" }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="15 18 9 12 15 6"/></svg>
        </button>
        <h1 className="text-xl font-bold" style={{ color: "var(--phoenix-text)" }}>Restaurar Backup</h1>
      </div>

      {/* Step indicators */}
      <div className="flex items-center gap-2 mb-8">
        {steps.map((s, i) => (
          <div key={s} className="flex items-center gap-2">
            <div className="flex flex-col items-center gap-1">
              <div className="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold transition-all"
                style={{
                  background: i < step ? "var(--phoenix-primary)" : i === step ? "var(--phoenix-primary)" : "var(--phoenix-card)",
                  color: i <= step ? "white" : "var(--phoenix-text-secondary)",
                  border: i > step ? "1px solid var(--phoenix-border)" : "none",
                }}>
                {i < step ? (
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3"><polyline points="20 6 9 17 4 12"/></svg>
                ) : i + 1}
              </div>
              <span className="text-xs whitespace-nowrap" style={{ color: i === step ? "var(--phoenix-primary)" : "var(--phoenix-text-secondary)" }}>{s}</span>
            </div>
            {i < steps.length - 1 && (
              <div className="h-0.5 w-8 mb-4 flex-shrink-0" style={{ background: i < step ? "var(--phoenix-primary)" : "var(--phoenix-border)" }} />
            )}
          </div>
        ))}
      </div>

      {/* Step 0 - Origem */}
      {step === 0 && (
        <div className="flex flex-col gap-4">
          <div>
            <h2 className="text-lg font-bold mb-1" style={{ color: "var(--phoenix-text)" }}>Selecione o snapshot de origem</h2>
            <p className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>Escolha o backup que deseja restaurar</p>
          </div>
          <div className="rounded-xl border p-4" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
            <p className="text-xs mb-2" style={{ color: "var(--phoenix-text-secondary)" }}>Snapshot</p>
            <div className="flex items-center justify-between p-3 rounded-lg border" style={{ borderColor: "var(--phoenix-primary)", background: "rgba(255,107,0,0.05)" }}>
              <span className="text-sm font-medium" style={{ color: "var(--phoenix-text)" }}>Snapshot selecionado</span>
              <span className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>ID: {snapshotId?.slice(0, 8)}...</span>
            </div>
          </div>

          {/* Escopo */}
          <div className="flex flex-col gap-2">
            {[
              { value: "full", label: "Restore Completo", desc: "Restaurar todas as keys do snapshot" },
              { value: "datastore", label: "Restore por DataStore", desc: "Selecionar um DataStore específico" },
              { value: "single_key", label: "Restore Seletivo", desc: "Selecionar keys específicas para restaurar" },
            ].map((opt) => (
              <button key={opt.value} onClick={() => setScope(opt.value as RestoreScope)}
                className="flex items-center gap-3 p-4 rounded-xl border text-left transition-all"
                style={{
                  background: scope === opt.value ? "rgba(255,107,0,0.08)" : "var(--phoenix-card)",
                  borderColor: scope === opt.value ? "var(--phoenix-primary)" : "var(--phoenix-border)",
                }}>
                <div className="w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0"
                  style={{ borderColor: scope === opt.value ? "var(--phoenix-primary)" : "var(--phoenix-border)" }}>
                  {scope === opt.value && <div className="w-2.5 h-2.5 rounded-full" style={{ background: "var(--phoenix-primary)" }} />}
                </div>
                <div>
                  <p className="font-semibold text-sm" style={{ color: scope === opt.value ? "var(--phoenix-primary)" : "var(--phoenix-text)" }}>{opt.label}</p>
                  <p className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>{opt.desc}</p>
                </div>
              </button>
            ))}
          </div>
          <PhoenixButton label="Próximo →" onClick={() => setStep(1)} width="100%" />
        </div>
      )}

      {/* Step 1 - Destino */}
      {step === 1 && (
        <div className="flex flex-col gap-4">
          <div>
            <h2 className="text-lg font-bold mb-1" style={{ color: "var(--phoenix-text)" }}>Selecione o destino</h2>
            <p className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>Escolha onde os dados serão restaurados</p>
          </div>
          {[
            { value: "same", icon: "🔄", label: "Mesmo DataStore", desc: "Restaurar diretamente no datastore original" },
            { value: "new", icon: "➕", label: "Novo DataStore", desc: "Criar uma cópia em um datastore separado" },
          ].map((opt) => (
            <button key={opt.value} onClick={() => setDestination(opt.value as "same" | "new")}
              className="flex items-center gap-4 p-5 rounded-xl border text-left transition-all"
              style={{
                background: destination === opt.value ? "rgba(255,107,0,0.08)" : "var(--phoenix-card)",
                borderColor: destination === opt.value ? "var(--phoenix-primary)" : "var(--phoenix-border)",
              }}>
              <div className="w-10 h-10 rounded-xl flex items-center justify-center text-xl"
                style={{ background: destination === opt.value ? "rgba(255,107,0,0.15)" : "rgba(107,107,107,0.1)" }}>{opt.icon}</div>
              <div className="flex-1">
                <p className="font-semibold" style={{ color: destination === opt.value ? "var(--phoenix-primary)" : "var(--phoenix-text)" }}>{opt.label}</p>
                <p className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>{opt.desc}</p>
              </div>
              <div className="w-5 h-5 rounded-full border-2 flex items-center justify-center"
                style={{ borderColor: destination === opt.value ? "var(--phoenix-primary)" : "var(--phoenix-border)" }}>
                {destination === opt.value && <div className="w-2.5 h-2.5 rounded-full" style={{ background: "var(--phoenix-primary)" }} />}
              </div>
            </button>
          ))}

          {/* Dry run toggle */}
          <div className="flex items-center justify-between p-4 rounded-xl border" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
            <div>
              <p className="text-sm font-medium" style={{ color: "var(--phoenix-text)" }}>Modo Dry Run</p>
              <p className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>Simula o restore sem alterar os dados</p>
            </div>
            <button onClick={() => setDryRun(!dryRun)}
              className="w-12 h-6 rounded-full transition-all relative"
              style={{ background: dryRun ? "var(--phoenix-primary)" : "var(--phoenix-border)" }}>
              <div className="w-5 h-5 rounded-full bg-white absolute top-0.5 transition-all"
                style={{ left: dryRun ? "calc(100% - 22px)" : "2px" }} />
            </button>
          </div>

          <div className="flex gap-3">
            <PhoenixButton label="← Voltar" onClick={() => setStep(0)} variant="outline" width="100%" />
            <PhoenixButton label="Próximo →" onClick={() => setStep(2)} width="100%" />
          </div>
        </div>
      )}

      {/* Step 2 - Confirmação */}
      {step === 2 && (
        <div className="flex flex-col gap-4">
          <div>
            <h2 className="text-lg font-bold mb-1" style={{ color: "var(--phoenix-text)" }}>Confirmação</h2>
            <p className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>Revise os detalhes antes de prosseguir</p>
          </div>
          <div className="rounded-xl border p-5 flex flex-col gap-3" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
            {[
              { label: "Snapshot", value: `ID: ${snapshotId?.slice(0, 8)}...` },
              { label: "Escopo", value: scope === "full" ? "Restore Completo" : scope === "datastore" ? "Por DataStore" : "Seletivo" },
              { label: "Destino", value: destination === "same" ? "Mesmo DataStore" : "Novo DataStore" },
              { label: "Dry Run", value: dryRun ? "Sim (simulação)" : "Não (real)" },
            ].map((r) => (
              <div key={r.label} className="flex items-center justify-between">
                <span className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>{r.label}</span>
                <span className="text-sm font-semibold" style={{ color: "var(--phoenix-text)" }}>{r.value}</span>
              </div>
            ))}
          </div>

          {!dryRun && (
            <div className="flex items-start gap-3 p-4 rounded-xl border" style={{ background: "rgba(245,158,11,0.08)", borderColor: "rgba(245,158,11,0.25)" }}>
              <span className="text-lg">⚠️</span>
              <p className="text-sm" style={{ color: "#F59E0B" }}>
                Esta operação irá substituir os dados atuais. Todos os dados serão restaurados para o estado deste snapshot.
              </p>
            </div>
          )}

          <div className="flex gap-3">
            <PhoenixButton label="← Voltar" onClick={() => setStep(1)} variant="outline" width="100%" />
            <PhoenixButton label="Próximo →" onClick={handleRestore} isLoading={loading} width="100%" />
          </div>
        </div>
      )}

      {/* Step 3 - Progresso */}
      {step === 3 && (
        <div className="flex flex-col items-center justify-center py-16 gap-4">
          <svg className="animate-spin w-12 h-12" viewBox="0 0 24 24" fill="none">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="var(--phoenix-primary)" strokeWidth="4"/>
            <path className="opacity-75" fill="var(--phoenix-primary)" d="M4 12a8 8 0 018-8v8H4z"/>
          </svg>
          <p className="text-lg font-semibold" style={{ color: "var(--phoenix-text)" }}>Executando restore...</p>
          <p className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>Aguarde enquanto os dados são restaurados</p>
        </div>
      )}

      {/* Step 4 - Conclusão */}
      {step === 4 && done && (
        <div className="flex flex-col items-center justify-center py-12 gap-5 text-center">
          <div className="w-20 h-20 rounded-full flex items-center justify-center" style={{ background: "rgba(34,197,94,0.15)" }}>
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#22C55E" strokeWidth="2.5"><polyline points="20 6 9 17 4 12"/></svg>
          </div>
          <div>
            <h2 className="text-2xl font-bold mb-2" style={{ color: "var(--phoenix-text)" }}>Restore Concluído!</h2>
            <p className="text-sm" style={{ color: "var(--phoenix-text-secondary)" }}>
              Os dados foram restaurados com sucesso para o estado do snapshot selecionado.
            </p>
          </div>
          <div className="flex flex-col gap-3 w-full max-w-sm">
            <PhoenixButton label="Ver Backups" onClick={() => router.push("/dashboard/snapshots")} width="100%" />
            <PhoenixButton label="Ir para Dashboard" onClick={() => router.push("/dashboard")} variant="outline" width="100%" />
          </div>
        </div>
      )}
    </div>
  );
}
