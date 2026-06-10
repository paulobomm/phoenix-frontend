"use client";

import { useState, useEffect, useCallback } from "react";
import { snapshotsService } from "@/services/snapshots.service";
import type { Snapshot } from "@/types/snapshot";

export function useSnapshots(projectId: string | null) {
  const [snapshots, setSnapshots] = useState<Snapshot[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetch = useCallback(async () => {
    if (!projectId) return;
    try {
      setLoading(true);
      setError(null);
      const data = await snapshotsService.list(projectId);
      setSnapshots(data);
    } catch {
      setError("Erro ao carregar snapshots");
    } finally {
      setLoading(false);
    }
  }, [projectId]);

  const triggerManual = async () => {
    if (!projectId) return;
    await snapshotsService.triggerManual(projectId);
    await fetch();
  };

  useEffect(() => { fetch(); }, [fetch]);

  return { snapshots, loading, error, refetch: fetch, triggerManual };
}
