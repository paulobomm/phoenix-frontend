import { snapshotsApi } from "./api";
import type { Snapshot } from "@/types/snapshot";

export const snapshotsService = {
  list: async (projectId: string): Promise<Snapshot[]> => {
    const { data } = await snapshotsApi.get(`/projects/${projectId}/snapshots`);
    return Array.isArray(data) ? data : data.data ?? [];
  },

  get: async (jobId: string): Promise<Snapshot> => {
    const { data } = await snapshotsApi.get(`/snapshots/${jobId}`);
    return data;
  },

  triggerManual: async (projectId: string): Promise<void> => {
    await snapshotsApi.post(`/projects/${projectId}/snapshots`);
  },
};
