"use client";

import { useState } from "react";
import { authService } from "@/services/auth.service";
import { useAuthStore } from "@/store/auth.store";
import type { LoginCredentials } from "@/types/auth";

export function useLogin() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { setToken } = useAuthStore();

  const login = async (credentials: LoginCredentials) => {
    try {
      setLoading(true);
      setError(null);
      const { accessToken } = await authService.login(credentials);
      setToken(accessToken);
      window.location.href = "/dashboard";
    } catch (err: any) {
      setError(
        err.response?.status === 401
          ? "E-mail ou senha inválidos"
          : "Erro ao conectar com o servidor"
      );
    } finally {
      setLoading(false);
    }
  };

  return { login, loading, error };
}
