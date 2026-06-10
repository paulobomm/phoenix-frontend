"use client";

import { useState, useEffect, useCallback } from "react";
import { projectsService } from "@/services/projects.service";
import type { Project, CreateProjectDto } from "@/types/project";

export function useProjects() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchProjects = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await projectsService.list();
      setProjects(data);
    } catch {
      setError("Erro ao carregar projetos");
    } finally {
      setLoading(false);
    }
  }, []);

  const createProject = async (dto: CreateProjectDto) => {
    const project = await projectsService.create(dto);
    setProjects((prev) => [...prev, project]);
    return project;
  };

  const deleteProject = async (id: string) => {
    await projectsService.delete(id);
    setProjects((prev) => prev.filter((p) => p.id !== id));
  };

  useEffect(() => { fetchProjects(); }, [fetchProjects]);

  return { projects, loading, error, createProject, deleteProject, refetch: fetchProjects };
}
