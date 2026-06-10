"use client";

export default function DashboardPage() {
  return (
    <div>
      <h2 className="text-xl font-semibold text-white mb-6">Visão Geral</h2>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-gray-800 rounded-xl p-6">
          <p className="text-gray-400 text-sm">Projetos</p>
          <p className="text-3xl font-bold text-white mt-1">—</p>
        </div>
        <div className="bg-gray-800 rounded-xl p-6">
          <p className="text-gray-400 text-sm">Snapshots</p>
          <p className="text-3xl font-bold text-white mt-1">—</p>
        </div>
        <div className="bg-gray-800 rounded-xl p-6">
          <p className="text-gray-400 text-sm">Auditoria</p>
          <p className="text-3xl font-bold text-white mt-1">—</p>
        </div>
      </div>
    </div>
  );
}
