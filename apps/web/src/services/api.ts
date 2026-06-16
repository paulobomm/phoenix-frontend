import axios from "axios";

const TOKEN_KEY = "accessToken";

const getToken = () =>
  typeof window !== "undefined" ? localStorage.getItem(TOKEN_KEY) : null;

const createApi = (baseURL: string) => {
  const api = axios.create({ baseURL });

  api.interceptors.request.use((config) => {
    const token = getToken();
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
  });

  api.interceptors.response.use(
    (res) => res,
    (error) => {
      if (error.response?.status === 401 && typeof window !== "undefined") {
        localStorage.removeItem(TOKEN_KEY);
        document.cookie = `${TOKEN_KEY}=; path=/; max-age=0`;
        window.location.href = "/login";
      }
      return Promise.reject(error);
    }
  );

  return api;
};

export const iamApi = createApi("/api/iam");
export const projectsApi = createApi("/api/projects");
export const discoveryApi = createApi("/api/discovery");
export const snapshotsApi = createApi("/api/snapshots");
export const restoreApi = createApi("/api/restore");
export const auditApi = createApi("/api/audit");
export const adminDataApi = createApi("/api/admin-data");
