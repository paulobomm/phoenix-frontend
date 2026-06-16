"use client";

import { useState, useEffect } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { discoveryService } from "@/services/discovery.service";
import { useProjectStore } from "@/store/project.store";
import { GameSelector } from "@/components/dashboard/GameSelector";
import type { DataStore } from "@/types/project";

const tabs = ["Todos", "Standard", "Ordered"];

function timeAgo(iso: string) {
  const diff = Date.now() - new Date(iso).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return `${mins}min atrás`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `${hours}h atrás`;
  return `${Math.floor(hours / 24)}d atrás`;
}

export default function DataStoresPage() {
  const router = useRouter();
  const { selectedProject } = useProjectStore();
  const [datastores, setDatastores] = useState<DataStore[]>([]);
  const [loading, setLoading] = useState(false);
  const [discovering, setDiscovering] = useState(false);
  const [search, setSearch] = useState("");
  const [tab, setTab] = useState("Todos");

  useEffect(() => {
    if (!selectedProject) return;
    setLoading(true);
    discoveryService.listDatastores(selectedProject.id)
      .then(setDatastores)
      .catch(() => setDatastores([]))
      .finally(() => setLoading(false));
  }, [selectedProject]);

  const handleDiscover = async () => {
    if (!selectedProject) return;
    setDiscovering(true);
    try {
      await discoveryService.triggerDiscovery(selectedProject.id);
      const data = await discoveryService.listDatastores(selectedProject.id);
      setDatastores(data);
    } catch { alert("Erro ao executar discovery"); }
    finally { setDiscovering(false); }
  };

  const filtered = datastores.filter((ds) => {
    const matchSearch = ds.name.toLowerCase().includes(search.toLowerCase());
    return matchSearch;
  });

  return (
    <div className="p-6 max-w-3xl">
      {/* Header */}
      <div className="flex items-center justify-between mb-5">
        <div>
          <h1 className="text-2xl font-bold" style={{ color: "var(--phoenix-text)" }}>DataStores</h1>
          <p className="text-sm mt-0.5" style={{ color: "var(--phoenix-text-secondary)" }}>Gerencie seus dados Roblox</p>
        </div>
        <button onClick={handleDiscover} disabled={!selectedProject || discovering}
          suppressHydrationWarning
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold border disabled:opacity-50 transition-all"
          style={{ borderColor: "var(--phoenix-border)", color: "var(--phoenix-text-secondary)", background: "var(--phoenix-card)" }}>
          {discovering ? (
            <svg className="animate-spin w-4 h-4" viewBox="0 0 24 24" fill="none"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"/><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/></svg>
          ) : (
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          )}
          🔍 Player
        </button>
      </div>

      {/* Game Selector */}
      <GameSelector />

      {/* Search */}
      <div className="relative mb-4">
        <svg className="absolute left-3 top-1/2 -translate-y-1/2" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--phoenix-text-secondary)" strokeWidth="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Buscar datastore..."
          className="w-full pl-9 pr-4 py-3 rounded-xl text-sm outline-none"
          style={{ background: "var(--phoenix-card)", border: "1px solid var(--phoenix-border)", color: "var(--phoenix-text)" }}
        />
      </div>

      {/* Tabs */}
      <div className="flex border-b mb-4" style={{ borderColor: "var(--phoenix-border)" }}>
        {tabs.map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className="px-4 py-2.5 text-sm font-medium transition-all"
            style={{
              color: tab === t ? "var(--phoenix-primary)" : "var(--phoenix-text-secondary)",
              borderBottom: tab === t ? "2px solid var(--phoenix-primary)" : "2px solid transparent",
            }}>
            {t}
          </button>
        ))}
      </div>

      {/* List */}
      {!selectedProject ? (
        <div className="text-center py-16" style={{ color: "var(--phoenix-text-secondary)" }}>Selecione um jogo para ver os DataStores</div>
      ) : loading ? (
        <div className="flex flex-col gap-3">
          {[1,2,3].map(i => <div key={i} className="h-20 rounded-2xl animate-pulse" style={{ background: "var(--phoenix-card)" }} />)}
        </div>
      ) : filtered.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-center">
          <div className="text-4xl mb-3">💾</div>
          <h3 className="font-semibold mb-1" style={{ color: "var(--phoenix-text)" }}>Nenhum DataStore encontrado</h3>
          <p className="text-sm mb-4" style={{ color: "var(--phoenix-text-secondary)" }}>Execute uma descoberta para encontrar os DataStores do jogo</p>
          <button onClick={handleDiscover} disabled={discovering}
            className="px-5 py-2.5 rounded-xl text-sm font-semibold text-white"
            style={{ background: "var(--phoenix-primary)" }}>
            {discovering ? "Descobrindo..." : "Executar Discovery"}
          </button>
        </div>
      ) : (
        <div className="flex flex-col gap-3">
          {filtered.map((ds) => (
            <button key={ds.id}
              className="flex items-center gap-4 p-4 rounded-2xl border text-left transition-all hover:border-orange-500"
              style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}
              onClick={() => router.push(`/dashboard/datastores/${ds.id}?name=${ds.name}&project=${selectedProject.id}`)}>
              <div className="w-12 h-12 rounded-xl flex items-center justify-center text-xl flex-shrink-0" style={{ background: "rgba(255,107,0,0.15)" }}>💾</div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-0.5">
                  <p className="font-semibold text-sm" style={{ color: "var(--phoenix-text)" }}>{ds.name}</p>
                  <span className="text-xs px-2 py-0.5 rounded font-semibold" style={{ background: "rgba(96,165,250,0.15)", color: "#60A5FA" }}>STANDARD</span>
                </div>
                <p className="text-xs" style={{ color: "var(--phoenix-text-secondary)" }}>
                  Visto pela última vez {timeAgo(ds.lastSeenAt)}
                </p>
              </div>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--phoenix-text-secondary)" strokeWidth="2"><polyline points="9 18 15 12 9 6"/></svg>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
