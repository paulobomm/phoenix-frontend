export interface Snapshot {
  id: string;
  projectId: string;
  status: "pending" | "running" | "completed" | "failed";
  type: "manual" | "scheduled";
  keystoreCount?: number;
  sizeBytes?: number;
  durationMs?: number;
  createdAt: string;
  completedAt?: string;
}

export interface RestoreJob {
  id: string;
  projectId: string;
  sourceSnapshotId: string;
  scope: string;
  status: string;
  dryRun: boolean;
  createdAt: string;
}

export type RestoreScope = "full" | "datastore" | "single_key";
