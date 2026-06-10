import { create } from "zustand";

interface AuthState {
  accessToken: string | null;
  setToken: (token: string) => void;
  clearToken: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  accessToken: typeof window !== "undefined"
    ? localStorage.getItem("accessToken")
    : null,

  setToken: (token) => {
    localStorage.setItem("accessToken", token);
    set({ accessToken: token });
  },

  clearToken: () => {
    localStorage.removeItem("accessToken");
    set({ accessToken: null });
  },
}));
