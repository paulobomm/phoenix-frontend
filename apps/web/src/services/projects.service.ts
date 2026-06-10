import { projectsApi } from "./api";
import type { Project, CreateProjectDto, UpdateProjectDto, PaginatedResponse } from "@/types/project";

export const projectsService = {
  list: async (): Promise<Project[]> => {
    const { data } = await projectsApi.get<PaginatedResponse<Project>>("/projects");
    return data.data;
  },

  get: async (id: string): Promise<Project> => {
    const { data } = await projectsApi.get<Project>(`/projects/${id}`);
    return data;
  },

  create: async (dto: CreateProjectDto): Promise<Project> => {
    const { data } = await projectsApi.post<Project>("/projects", dto);
    return data;
  },

  update: async (id: string, dto: UpdateProjectDto): Promise<void> => {
    await projectsApi.put(`/projects/${id}`, dto);
  },

  rotateKey: async (id: string, apiKey: string): Promise<void> => {
    await projectsApi.post(`/projects/${id}/rotate-key`, { apiKey });
  },

  delete: async (id: string): Promise<void> => {
    await projectsApi.delete(`/projects/${id}`);
  },
};
