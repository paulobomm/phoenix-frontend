import { iamApi } from "./api";
import type { AuthResponse, LoginCredentials } from "@/types/auth";

const TOKEN_KEY = "accessToken";

export const authService = {
  login: async (credentials: LoginCredentials): Promise<AuthResponse> => {
    const { data } = await iamApi.post<AuthResponse>("/auth/login", credentials);
    // Salva no localStorage e no cookie
    localStorage.setItem(TOKEN_KEY, data.accessToken);
    document.cookie = `${TOKEN_KEY}=${data.accessToken}; path=/; max-age=86400; SameSite=Strict`;
    return data;
  },

  logout: () => {
    localStorage.removeItem(TOKEN_KEY);
    document.cookie = `${TOKEN_KEY}=; path=/; max-age=0`;
    window.location.href = "/login";
  },

  getToken: (): string | null => {
    if (typeof window === "undefined") return null;
    return localStorage.getItem(TOKEN_KEY);
  },

  isAuthenticated: (): boolean => {
    return !!authService.getToken();
  },
};
