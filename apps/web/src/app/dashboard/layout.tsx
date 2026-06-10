"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { authService } from "@/services/auth.service";

const navItems = [
  { label: "Visão Geral", href: "/dashboard", icon: "🏠" },
  { label: "Jogos", href: "/dashboard/games", icon: "🎮" },
  { label: "Backups", href: "/dashboard/snapshots", icon: "☁️" },
  { label: "DataStores", href: "/dashboard/datastores", icon: "💾" },
  { label: "Restore", href: "/dashboard/restore", icon: "🔄" },
  { label: "Histórico", href: "/dashboard/logs", icon: "🕐" },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="min-h-screen flex" style={{ background: "var(--phoenix-bg)" }}>
      <aside className="w-56 flex flex-col border-r flex-shrink-0" style={{ background: "var(--phoenix-card)", borderColor: "var(--phoenix-border)" }}>
        <div className="p-5 border-b flex items-center gap-3" style={{ borderColor: "var(--phoenix-border)" }}>
          <div className="w-8 h-8 rounded-lg flex items-center justify-center text-base" style={{ background: "rgba(255,107,0,0.15)", border: "1px solid rgba(255,107,0,0.3)" }}>🔥</div>
          <span className="font-black text-sm tracking-widest" style={{ color: "var(--phoenix-text)" }}>PHOENIX</span>
        </div>
        <nav className="flex-1 p-3 flex flex-col gap-0.5">
          {navItems.map((item) => {
            const isActive = pathname === item.href || (item.href !== "/dashboard" && pathname.startsWith(item.href));
            return (
              <Link key={item.href} href={item.href}
                className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all"
                style={{
                  background: isActive ? "rgba(255,107,0,0.1)" : "transparent",
                  color: isActive ? "var(--phoenix-primary)" : "var(--phoenix-text-secondary)",
                  borderLeft: isActive ? "2px solid var(--phoenix-primary)" : "2px solid transparent",
                }}>
                <span>{item.icon}</span>
                {item.label}
              </Link>
            );
          })}
        </nav>
        <div className="p-3 border-t" style={{ borderColor: "var(--phoenix-border)" }}>
          <button onClick={() => authService.logout()}
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium"
            style={{ color: "var(--phoenix-text-secondary)" }}>
            <span>🚪</span> Sair
          </button>
        </div>
      </aside>
      <main className="flex-1 overflow-auto">{children}</main>
    </div>
  );
}
