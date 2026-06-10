export interface Project {
  id: string;
  name: string;
  universeId: string;
  status: "active" | "paused" | "archived";
  ownerUserId?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface CreateProjectDto {
  name: string;
  universeId: string;
  apiKey: string;
}

export interface UpdateProjectDto {
  name?: string;
  status?: "active" | "paused" | "archived";
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    totalItems: number;
    itemsPerPage: number;
    currentPage: number;
    totalPages: number;
  };
}

export interface DataStore {
  id: string;
  name: string;
  firstSeenAt: string;
  lastSeenAt: string;
}
