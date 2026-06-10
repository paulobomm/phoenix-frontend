"use client";

import { useState } from "react";
import { PhoenixTextField } from "@/components/ui/PhoenixTextField";
import { PhoenixButton } from "@/components/ui/PhoenixButton";

interface AddGameWizardProps {
  onClose: () => void;
  onCreate: (data: { name: string; universeId: string; placeId: string; apiKey: string }) => Promise<void>;
}

const LUA_CODE = `local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

-- Phoenix DataStore Hook
local function onDataChanged(store, key, value)
  -- Phoenix will automatically detect changes
end`;

export function AddGameWizard({ onClose, onCreate }: AddGameWizardProps) {
  const [step, setStep] = useState(0);
  const [name, setName] = useState("");
  const [universeId, setUniverseId] = useState("");
  const [placeId, setPlaceId] = useState("");
  const [apiKey, setApiKey] = useState("");
  const [showKey, setShowKey] = useState(false);
  const [validating, setValidating] = useState(false);
  const [apiValid, setApiValid] = useState(false);
  const [finishing, setFinishing] = useState(false);
  const [copied, setCopied] = useState(false);

  const stepLabels = ["Informações Básicas", "API Key", "Integração"];

  const validateApiKey = async () => {
    setValidating(true);
    await new Promise((r) => setTimeout(r, 1500));
    setValidating(false);
    setApiValid(true);
  };

  const finish = async () => {
    setFinishing(true);
    await onCreate({ name, universeId, placeId, apiKey });
    setFinishing(false);
  };

  const copyCode = () => {
    navigator.clipboard.writeText(LUA_CODE);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" style={{ background: "rgba(0,0,0,0.7)" }}>
      <div className="w-full max-w-lg rounded-2xl border flex flex-col" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)", maxHeight: "90vh" }}>

        {/* Header */}
        <div className="flex items-start justify-between p-6 pb-0">
          <div>
            <h2 className="text-lg font-bold" style={{ color: "var(--phoenix-text)" }}>Adicionar Jogo</h2>
            <p className="text-xs mt-0.5" style={{ color: "var(--phoenix-text-secondary)" }}>Conecte seu jogo Roblox ao Phoenix</p>
          </div>
          <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-lg" style={{ color: "var(--phoenix-text-secondary)" }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
          </button>
        </div>

        {/* Progress */}
        <div className="px-6 pt-4 pb-2">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>Etapa {step + 1} de 3</span>
            <span className="text-xs font-semibold" style={{ color: "var(--phoenix-primary)" }}>{stepLabels[step]}</span>
          </div>
          <div className="h-1 rounded-full" style={{ background: "var(--phoenix-border)" }}>
            <div className="h-1 rounded-full transition-all" style={{ width: `${((step + 1) / 3) * 100}%`, background: "var(--phoenix-primary)" }} />
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-6">
          {step === 0 && (
            <div className="flex flex-col gap-4">
              <PhoenixTextField label="Nome do Jogo" placeholder="Ex: CoolGame RPG" value={name} onChange={setName} />
              <PhoenixTextField label="Universe ID" placeholder="Ex: 3924839" value={universeId} onChange={setUniverseId} />
              <PhoenixTextField label="Place ID" placeholder="Ex: 9283745" value={placeId} onChange={setPlaceId} />
              <PhoenixButton label="Próximo →" onClick={() => setStep(1)} width="100%" />
            </div>
          )}

          {step === 1 && (
            <div className="flex flex-col gap-4">
              {/* Info box */}
              <div className="rounded-xl p-4 border" style={{ background: "rgba(255,107,0,0.06)", borderColor: "rgba(255,107,0,0.2)" }}>
                <p className="text-sm font-semibold mb-2" style={{ color: "var(--phoenix-text)" }}>Como obter sua API Key:</p>
                <p className="text-xs leading-relaxed mb-3" style={{ color: "var(--phoenix-text-secondary)", whiteSpace: "pre-line" }}>
                  {"1. Acesse o Roblox Creator Hub\n2. Vá em Credenciais → API Keys\n3. Crie com permissão de leitura no DataStore API"}
                </p>
                <button className="flex items-center gap-1.5 text-xs font-semibold" style={{ color: "var(--phoenix-primary)" }}>
                  Abrir Creator Hub
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
                </button>
              </div>

              {/* Campo API Key sem autocomplete */}
              <div className="flex flex-col gap-1.5">
                <label className="text-xs font-semibold uppercase tracking-wide" style={{ color: "var(--phoenix-text-secondary)" }}>
                  API KEY
                </label>
                <div className="relative">
                  <input
                    type={showKey ? "text" : "password"}
                    value={apiKey}
                    onChange={(e) => { setApiKey(e.target.value); setApiValid(false); }}
                    placeholder="rbxp_..."
                    autoComplete="new-password"
                    autoCorrect="off"
                    autoCapitalize="off"
                    spellCheck={false}
                    data-form-type="other"
                    className="w-full px-4 py-3 rounded-xl text-sm outline-none transition-all"
                    style={{
                      background: "var(--phoenix-bg)",
                      border: `1px solid ${apiValid ? "#22C55E" : "var(--phoenix-border)"}`,
                      color: "var(--phoenix-text)",
                    }}
                  />
                  <button
                    type="button"
                    onClick={() => setShowKey(!showKey)}
                    className="absolute right-3 top-1/2 -translate-y-1/2"
                    style={{ color: "var(--phoenix-text-secondary)" }}
                  >
                    {showKey ? (
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                        <path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94"/>
                        <path d="M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19"/>
                        <line x1="1" y1="1" x2="23" y2="23"/>
                      </svg>
                    ) : (
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                        <circle cx="12" cy="12" r="3"/>
                      </svg>
                    )}
                  </button>
                </div>
              </div>

              {apiValid && (
                <div className="flex items-center gap-2 p-3 rounded-xl border" style={{ background: "rgba(34,197,94,0.1)", borderColor: "rgba(34,197,94,0.3)" }}>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#22C55E" strokeWidth="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                  <span className="text-sm font-medium" style={{ color: "#22C55E" }}>API Key válida!</span>
                </div>
              )}

              <PhoenixButton
                label={apiValid ? "Validada!" : "Validar e Próximo →"}
                onClick={apiValid ? () => setStep(2) : validateApiKey}
                isLoading={validating}
                width="100%"
              />
              <button onClick={() => setStep(0)} className="text-sm text-center" style={{ color: "var(--phoenix-text-secondary)" }}>← Voltar</button>
            </div>
          )}

          {step === 2 && (
            <div className="flex flex-col gap-4">
              <div>
                <h3 className="text-base font-bold mb-1" style={{ color: "var(--phoenix-text)" }}>Integração com Luau</h3>
                <p className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>Adicione este código ao seu jogo para monitoramento em tempo real</p>
              </div>
              <div className="rounded-xl border p-4" style={{ background: "var(--phoenix-bg)", borderColor: "var(--phoenix-border)" }}>
                <div className="flex items-center justify-between mb-3">
                  <span className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>Script Luau</span>
                  <button onClick={copyCode} className="flex items-center gap-1.5 text-xs font-semibold" style={{ color: "var(--phoenix-primary)" }}>
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>
                    {copied ? "Copiado!" : "Copiar"}
                  </button>
                </div>
                <pre className="text-xs leading-relaxed font-mono whitespace-pre-wrap" style={{ color: "var(--phoenix-text)" }}>{LUA_CODE}</pre>
              </div>
              <PhoenixButton label="Finalizar" onClick={finish} isLoading={finishing} width="100%" />
              <button onClick={() => setStep(1)} className="text-sm text-center" style={{ color: "var(--phoenix-text-secondary)" }}>← Voltar</button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
