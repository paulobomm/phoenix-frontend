"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { PhoenixLogo } from "@/components/ui/PhoenixLogo";
import { PhoenixTextField } from "@/components/ui/PhoenixTextField";
import { PhoenixButton } from "@/components/ui/PhoenixButton";

export default function RegisterPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validate = () => {
    const e: Record<string, string> = {};
    if (!email || !email.includes("@")) e.email = "Email inválido";
    if (!password || password.length < 6) e.password = "Mínimo 6 caracteres";
    if (password !== confirm) e.confirm = "Senhas não coincidem";
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) router.push("/login");
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[var(--phoenix-bg)] px-6 py-12 relative overflow-hidden">
      <div className="absolute top-[-120px] left-1/2 -translate-x-1/2 w-[360px] h-[360px] rounded-full"
        style={{ background: "radial-gradient(circle, rgba(255,107,0,0.07) 0%, transparent 70%)" }}
      />
      <div className="w-full max-w-md relative z-10">
        <div className="flex justify-center mb-8">
          <PhoenixLogo size={64} />
        </div>
        <div className="text-center mb-8">
          <h1 className="text-2xl font-bold text-[var(--phoenix-text)]">Create an account</h1>
          <p className="text-sm text-[var(--phoenix-text-secondary)] mt-1.5">
            Register to start managing your Roblox datastores
          </p>
        </div>
        <div className="bg-[var(--phoenix-card)] border border-[var(--phoenix-border)] rounded-2xl p-6">
          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <PhoenixTextField label="Email" placeholder="seu@email.com" value={email} onChange={setEmail} type="email" error={errors.email} />
            <PhoenixTextField label="Senha" placeholder="••••••••" value={password} onChange={setPassword} showToggle error={errors.password} />
            <PhoenixTextField label="Confirmar Senha" placeholder="••••••••" value={confirm} onChange={setConfirm} showToggle error={errors.confirm} />
            <PhoenixButton label="Create Account" type="submit" width="100%" />
          </form>
        </div>
        <p className="text-center text-sm text-[var(--phoenix-text-secondary)] mt-5">
          Already have an account?{" "}
          <Link href="/login" className="text-[var(--phoenix-primary)] font-semibold hover:underline">Sign in</Link>
        </p>
      </div>
    </div>
  );
}
