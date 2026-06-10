"use client";

import { useState } from "react";
import Link from "next/link";
import { useLogin } from "@/hooks/useLogin";
import { PhoenixLogo } from "@/components/ui/PhoenixLogo";
import { PhoenixTextField } from "@/components/ui/PhoenixTextField";
import { PhoenixButton } from "@/components/ui/PhoenixButton";

export default function LoginPage() {
  const { login, loading, error } = useLogin();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await login({ email, password });
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[var(--phoenix-bg)] px-6 py-12 relative overflow-hidden">
      {/* Glow background */}
      <div className="absolute top-[-120px] left-1/2 -translate-x-1/2 w-[360px] h-[360px] rounded-full"
        style={{ background: "radial-gradient(circle, rgba(255,107,0,0.07) 0%, transparent 70%)" }}
      />

      <div className="w-full max-w-md relative z-10">
        {/* Logo */}
        <div className="flex justify-center mb-8">
          <PhoenixLogo size={64} />
        </div>

        {/* Title */}
        <div className="text-center mb-8">
          <h1 className="text-2xl font-bold text-[var(--phoenix-text)]">Sign in to your account</h1>
          <p className="text-sm text-[var(--phoenix-text-secondary)] mt-1.5">
            Gerencie seus Roblox DataStores com segurança
          </p>
        </div>

        {/* Form card */}
        <div className="bg-[var(--phoenix-card)] border border-[var(--phoenix-border)] rounded-2xl p-6">
          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <PhoenixTextField
              label="Email"
              placeholder="seu@email.com"
              value={email}
              onChange={setEmail}
              type="email"
            />
            <PhoenixTextField
              label="Senha"
              placeholder="••••••••"
              value={password}
              onChange={setPassword}
              showToggle
            />
            <div className="flex justify-end">
              <Link href="/forgot-password"
                className="text-xs text-[var(--phoenix-primary)] font-medium hover:underline">
                Esqueci minha senha
              </Link>
            </div>
            {error && (
              <p className="text-xs text-[var(--phoenix-error)] text-center">{error}</p>
            )}
            <PhoenixButton
              label="Sign In"
              type="submit"
              isLoading={loading}
              width="100%"
            />
          </form>
        </div>

        {/* Divider */}
        <div className="flex items-center gap-3 my-5">
          <div className="flex-1 h-px bg-[var(--phoenix-border)]" />
          <span className="text-xs text-[var(--phoenix-text-secondary)]">ou</span>
          <div className="flex-1 h-px bg-[var(--phoenix-border)]" />
        </div>

        {/* Auth0 button */}
        <button className="w-full flex items-center justify-center gap-2 border border-[var(--phoenix-border)] rounded-xl py-3 text-sm text-[var(--phoenix-text)] hover:border-[var(--phoenix-primary)] transition-colors">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
            <path d="M7 11V7a5 5 0 0110 0v4" />
          </svg>
          Continue with Auth0
        </button>

        {/* Register link */}
        <p className="text-center text-sm text-[var(--phoenix-text-secondary)] mt-5">
          Don't have an account?{" "}
          <Link href="/register" className="text-[var(--phoenix-primary)] font-semibold hover:underline">
            Sign up
          </Link>
        </p>

        {/* Demo hint */}
        <div className="mt-5 flex items-center gap-2 bg-[var(--phoenix-primary)] bg-opacity-8 border border-[var(--phoenix-primary)] border-opacity-20 rounded-xl p-3"
          style={{ background: "rgba(255,107,0,0.08)" }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="var(--phoenix-primary)">
            <circle cx="12" cy="12" r="10" /><line x1="12" y1="8" x2="12" y2="12" stroke="white" strokeWidth="2" /><line x1="12" y1="16" x2="12.01" y2="16" stroke="white" strokeWidth="2" />
          </svg>
          <p className="text-xs text-[var(--phoenix-primary)]">
            Use: admin@phoenix.gg / ChangeMe123!
          </p>
        </div>
      </div>
    </div>
  );
}
