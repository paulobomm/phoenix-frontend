import { restoreApi } from "./api";
import type { RestoreJob, RestoreScope } from "@/types/snapshot";

export const restoreService = {
  request: async (dto: {
    projectId: string;
    sourceSnapshotId: string;
    scope: RestoreScope;
    targetDatastoreName?: string;
    targetKey?: string;
    dryRun?: boolean;
  }): Promise<RestoreJob> => {
    const { data } = await restoreApi.post("/restores", dto);
    return data;
  },

  list: async (projectId: string): Promise<RestoreJob[]> => {
    const { data } = await restoreApi.get(`/projects/${projectId}/restores`);
    return Array.isArray(data) ? data : data.data ?? [];
  },

  get: async (id: string): Promise<RestoreJob> => {
    const { data } = await restoreApi.get(`/restores/${id}`);
    return data;
  },

  approve: async (id: string): Promise<void> => {
    await restoreApi.post(`/restores/${id}/approve`);
  },
};
