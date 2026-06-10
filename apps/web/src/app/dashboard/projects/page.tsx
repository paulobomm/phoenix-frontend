"use client";

import { useState } from "react";
import { useProjects } from "@/hooks/useProjects";

export default function ProjectsPage() {
  const { projects, loading, error, createProject, deleteProject } = useProjects();
  const [showForm, setShowForm] = useState(false);
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [creating, setCreating] = useState(false);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setCreating(true);
      await createProject({ name, description });
      setName("");
      setDescription("");
      setShowForm(false);
    } catch {
      alert("Erro ao criar projeto");
    } finally {
      setCreating(false);
    }
  };

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-semibold text-white">Projetos</h2>
        <button
          onClick={() => setShowForm(!showForm)}
          className="bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium px-4 py-2 rounded-lg transition-colors"
        >
          {showForm ? "Cancelar" : "+ Novo Projeto"}
        </button>
      </div>

      {showForm && (
        <form onSubmit={handleCreate} className="bg-gray-800 rounded-xl p-6 mb-6 flex flex-col gap-4">
          <h3 className="text-white font-medium">Novo Projeto</h3>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Nome do projeto"
            required
            className="bg-gray-700 text-white rounded-lg px-4 py-2 outline-none focus:ring-2 focus:ring-indigo-500"
          />
          <input
            type="text"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Descrição (opcional)"
            className="bg-gray-700 text-white rounded-lg px-4 py-2 outline-none focus:ring-2 focus:ring-indigo-500"
          />
          <button
            type="submit"
            disabled={creating}
            className="bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 text-white font-medium py-2 rounded-lg transition-colors"
          >
            {creating ? "Criando..." : "Criar Projeto"}
          </button>
        </form>
      )}

      {loading && <p className="text-gray-400">Carregando projetos...</p>}
      {error && <p className="text-red-400">{error}</p>}

      {!loading && !error && projects.length === 0 && (
        <div className="text-center py-16 text-gray-500">
          <p className="text-lg">Nenhum projeto encontrado</p>
          <p className="text-sm mt-1">Crie seu primeiro projeto!</p>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {projects.map((project) => (
          <div key={project.id} className="bg-gray-800 rounded-xl p-5 flex flex-col gap-3">
            <div className="flex items-start justify-between">
              <h3 className="text-white font-medium">{project.name}</h3>
              <span className={`text-xs px-2 py-1 rounded-full ${
                project.status === "active"
                  ? "bg-green-900 text-green-300"
                  : "bg-gray-700 text-gray-400"
              }`}>
                {project.status}
              </span>
            </div>
            {project.description && (
              <p className="text-gray-400 text-sm">{project.description}</p>
            )}
            <div className="flex items-center justify-between mt-auto pt-3 border-t border-gray-700">
              <span className="text-xs text-gray-500">
                {new Date(project.createdAt).toLocaleDateString("pt-BR")}
              </span>
              <button
                onClick={() => deleteProject(project.id)}
                className="text-xs text-red-400 hover:text-red-300 transition-colors"
              >
                Excluir
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
