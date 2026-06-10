import { projectsApi } from "./api";
import type { Project, CreateProjectDto, PaginatedResponse } from "@/types/project";

export const projectsService = {
  list: async (): Promise<Project[]> => {
    const { data } = await projectsApi.get<PaginatedResponse<Project>>("/projects");
    return data.data;
  },

  create: async (dto: CreateProjectDto): Promise<Project> => {
    const { data } = await projectsApi.post<Project>("/projects", dto);
    return data;
  },

  delete: async (id: string): Promise<void> => {
    await projectsApi.delete(`/projects/${id}`);
  },
};
