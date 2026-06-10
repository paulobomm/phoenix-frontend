"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { authService } from "@/services/auth.service";

const navItems = [
  { label: "Visão Geral", href: "/dashboard" },
  { label: "Projetos", href: "/dashboard/projects" },
  { label: "Snapshots", href: "/dashboard/snapshots" },
  { label: "Auditoria", href: "/dashboard/audit" },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="min-h-screen bg-gray-950 flex">
      {/* Sidebar */}
      <aside className="w-56 bg-gray-900 border-r border-gray-800 flex flex-col">
        <div className="p-6 border-b border-gray-800">
          <h1 className="text-white font-bold text-xl">Phoenix</h1>
        </div>
        <nav className="flex-1 p-4 flex flex-col gap-1">
          {navItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={`px-3 py-2 rounded-lg text-sm transition-colors ${
                pathname === item.href
                  ? "bg-indigo-600 text-white"
                  : "text-gray-400 hover:text-white hover:bg-gray-800"
              }`}
            >
              {item.label}
            </Link>
          ))}
        </nav>
        <div className="p-4 border-t border-gray-800">
          <button
            onClick={() => authService.logout()}
            className="w-full text-sm text-gray-400 hover:text-white transition-colors text-left px-3 py-2 rounded-lg hover:bg-gray-800"
          >
            Sair
          </button>
        </div>
      </aside>

      {/* Main content */}
      <main className="flex-1 p-8 text-white overflow-auto">
        {children}
      </main>
    </div>
  );
}
