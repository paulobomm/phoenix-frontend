export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthResponse {
  accessToken: string;
}

export interface JwtPayload {
  sub: string;
  email: string;
  permissions: string[];
}
