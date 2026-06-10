import { useState } from "react";
import { useRouter } from "next/navigation";
import { authService } from "@/services/auth.service";
import { useAuthStore } from "@/store/auth.store";
import type { LoginCredentials } from "@/types/auth";

export function useLogin() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { setToken } = useAuthStore();
  const router = useRouter();

  const login = async (credentials: LoginCredentials) => {
    try {
      setLoading(true);
      setError(null);
      const { accessToken } = await authService.login(credentials);
      setToken(accessToken);
      router.push("/dashboard");
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
