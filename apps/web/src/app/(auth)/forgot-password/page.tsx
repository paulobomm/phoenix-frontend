"use client";

import { useState } from "react";
import Link from "next/link";
import { PhoenixTextField } from "@/components/ui/PhoenixTextField";
import { PhoenixButton } from "@/components/ui/PhoenixButton";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [sent, setSent] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    await new Promise((r) => setTimeout(r, 1500));
    setLoading(false);
    setSent(true);
  };

  if (sent) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[var(--phoenix-bg)] px-6">
        <div className="w-full max-w-md text-center">
          <div className="w-20 h-20 rounded-full bg-[var(--phoenix-success)] bg-opacity-10 border-2 border-[var(--phoenix-success)] border-opacity-30 flex items-center justify-center mx-auto mb-6">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="var(--phoenix-success)" strokeWidth="2.5">
              <polyline points="20 6 9 17 4 12" />
            </svg>
          </div>
          <h2 className="text-2xl font-bold text-[var(--phoenix-text)] mb-3">Email Enviado!</h2>
          <p className="text-sm text-[var(--phoenix-text-secondary)] mb-8">
            Enviamos um link para {email}.<br />Verifique sua caixa de entrada.
          </p>
          <Link href="/login">
            <PhoenixButton label="Voltar ao Login" width="100%" />
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-[var(--phoenix-bg)] px-6">
      <div className="w-full max-w-md">
        <Link href="/login" className="flex items-center gap-1 text-sm text-[var(--phoenix-text-secondary)] hover:text-[var(--phoenix-text)] mb-8 transition-colors">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <polyline points="15 18 9 12 15 6" />
          </svg>
          Voltar
        </Link>
        <div className="w-14 h-14 rounded-xl bg-[var(--phoenix-primary)] bg-opacity-10 border border-[var(--phoenix-primary)] border-opacity-30 flex items-center justify-center mb-5">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="var(--phoenix-primary)" strokeWidth="2">
            <rect x="3" y="11" width="18" height="11" rx="2" /><path d="M7 11V7a5 5 0 0110 0v4" />
          </svg>
        </div>
        <h1 className="text-2xl font-bold text-[var(--phoenix-text)] mb-2">Esqueceu sua senha?</h1>
        <p className="text-sm text-[var(--phoenix-text-secondary)] mb-8">
          Digite seu email e enviaremos um link para redefinir sua senha.
        </p>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <PhoenixTextField label="Email" placeholder="seu@email.com" value={email} onChange={setEmail} type="email" />
          <PhoenixButton label="Enviar Link" type="submit" isLoading={loading} width="100%" />
        </form>
      </div>
    </div>
  );
}
