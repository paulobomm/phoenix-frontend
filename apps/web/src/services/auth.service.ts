import { iamApi } from "./api";
import type { AuthResponse, LoginCredentials } from "@/types/auth";

export const authService = {
  login: async (credentials: LoginCredentials): Promise<AuthResponse> => {
    const { data } = await iamApi.post<AuthResponse>("/auth/login", credentials);
    localStorage.setItem("accessToken", data.accessToken);
    return data;
  },

  logout: () => {
    localStorage.removeItem("accessToken");
    window.location.href = "/login";
  },

  getToken: (): string | null => {
    if (typeof window === "undefined") return null;
    return localStorage.getItem("accessToken");
  },

  isAuthenticated: (): boolean => {
    return !!authService.getToken();
  },
};
