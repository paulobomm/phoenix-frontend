import { discoveryApi } from "./api";
import type { DataStore } from "@/types/project";

export const discoveryService = {
  listDatastores: async (projectId: string): Promise<DataStore[]> => {
    const { data } = await discoveryApi.get(`/projects/${projectId}/datastores`);
    return Array.isArray(data) ? data : [];
  },

  triggerDiscovery: async (projectId: string): Promise<void> => {
    await discoveryApi.post(`/projects/${projectId}/discovery-runs`);
  },
};
