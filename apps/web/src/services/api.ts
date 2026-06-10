import axios from "axios";

export const iamApi = axios.create({
  baseURL: "/api/iam",
});

export const projectsApi = axios.create({
  baseURL: "/api/projects",
});

export const discoveryApi = axios.create({
  baseURL: "/api/discovery",
});

export const snapshotsApi = axios.create({
  baseURL: "/api/snapshots",
});

export const restoreApi = axios.create({
  baseURL: "/api/restore",
});

export const auditApi = axios.create({
  baseURL: "/api/audit",
});

export const adminDataApi = axios.create({
  baseURL: "/api/admin-data",
});

// Injeta o JWT em todas as APIs
[iamApi, projectsApi, discoveryApi, snapshotsApi, restoreApi, auditApi, adminDataApi].forEach((api) => {
  api.interceptors.request.use((config) => {
    if (typeof window !== "undefined") {
      const token = localStorage.getItem("accessToken");
      if (token) config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  });

  api.interceptors.response.use(
    (response) => response,
    (error) => {
      if (error.response?.status === 401) {
        if (typeof window !== "undefined") {
          localStorage.removeItem("accessToken");
          window.location.href = "/login";
        }
      }
      return Promise.reject(error);
    }
  );
});
