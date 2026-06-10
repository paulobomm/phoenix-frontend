"use client";

import { authService } from "@/services/auth.service";

export default function DashboardPage() {
  return (
    <div className="min-h-screen bg-gray-950 text-white p-8">
      <div className="max-w-4xl mx-auto">
        <div className="flex items-center justify-between mb-8">
          <h1 className="text-2xl font-bold">Dashboard</h1>
          <button
            onClick={() => authService.logout()}
            className="text-sm text-gray-400 hover:text-white transition-colors"
          >
            Sair
          </button>
        </div>
        <p className="text-gray-400">Bem-vindo ao Phoenix! ✨</p>
      </div>
    </div>
  );
}
