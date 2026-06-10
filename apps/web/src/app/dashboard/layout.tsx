"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { authService } from "@/services/auth.service";
import { PhoenixLogo } from "@/components/ui/PhoenixLogo";

const navItems = [
  {
    label: "Visão Geral",
    href: "/dashboard",
    icon: (
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <rect x="3" y="3" width="7" height="7" />
        <rect x="14" y="3" width="7" height="7" />
        <rect x="14" y="14" width="7" height="7" />
        <rect x="3" y="14" width="7" height="7" />
      </svg>
    ),
  },
  {
    label: "Projetos",
    href: "/dashboard/projects",
    icon: (
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
      </svg>
    ),
  },
  {
    label: "Snapshots",
    href: "/dashboard/snapshots",
    icon: (
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <polyline points="23 4 23 10 17 10" />
        <polyline points="1 20 1 14 7 14" />
        <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15" />
      </svg>
    ),
  },
  {
    label: "Auditoria",
    href: "/dashboard/audit",
    icon: (
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
        <polyline points="14 2 14 8 20 8" />
        <line x1="16" y1="13" x2="8" y2="13" />
        <line x1="16" y1="17" x2="8" y2="17" />
        <polyline points="10 9 9 9 8 9" />
      </svg>
    ),
  },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="min-h-screen flex" style={{ background: "var(--phoenix-bg, #09090b)" }}>
      {/* Sidebar */}
      <aside
        className="w-60 flex flex-col"
        style={{
          background: "var(--phoenix-card, #18181b)",
          borderRight: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))",
        }}
      >
        {/* Logo */}
        <div
          className="p-5 flex items-center gap-3"
          style={{ borderBottom: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))" }}
        >
          <PhoenixLogo size={28} />
          <span className="font-bold text-lg" style={{ color: "var(--phoenix-text, #fafafa)" }}>
            Phoenix
          </span>
        </div>

        {/* Nav */}
        <nav className="flex-1 p-3 flex flex-col gap-1">
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all"
                style={{
                  background: isActive ? "rgba(255,107,0,0.12)" : "transparent",
                  color: isActive
                    ? "var(--phoenix-primary, #ff6b00)"
                    : "var(--phoenix-text-secondary, #a1a1aa)",
                  border: isActive
                    ? "1px solid rgba(255,107,0,0.2)"
                    : "1px solid transparent",
                }}
              >
                {item.icon}
                {item.label}
              </Link>
            );
          })}
        </nav>

        {/* Footer */}
        <div
          className="p-3"
          style={{ borderTop: "1px solid var(--phoenix-border, rgba(255,255,255,0.08))" }}
        >
          <button
            onClick={() => authService.logout()}
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm transition-all"
            style={{ color: "var(--phoenix-text-secondary, #a1a1aa)" }}
            onMouseEnter={(e) => {
              (e.currentTarget as HTMLButtonElement).style.color = "var(--phoenix-error, #ef4444)";
              (e.currentTarget as HTMLButtonElement).style.background = "rgba(239,68,68,0.08)";
            }}
            onMouseLeave={(e) => {
              (e.currentTarget as HTMLButtonElement).style.color = "var(--phoenix-text-secondary, #a1a1aa)";
              (e.currentTarget as HTMLButtonElement).style.background = "transparent";
            }}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
              <polyline points="16 17 21 12 16 7" />
              <line x1="21" y1="12" x2="9" y2="12" />
            </svg>
            Sair
          </button>
        </div>
      </aside>

      {/* Main */}
      <main
        className="flex-1 overflow-auto p-8"
        style={{ color: "var(--phoenix-text, #fafafa)" }}
      >
        {children}
      </main>
    </div>
  );
}
