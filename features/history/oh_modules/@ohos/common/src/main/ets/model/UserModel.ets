export interface UserInfo {
  userId: number;
  role: number;
  account: string;
}

export interface LoginRequest {
  account: string;
  password: string;
}

export interface LoginResponse {
  userId: number;
  role: number;
  account: string;
}

export interface RegisterRequest {
  account: string;
  password: string;
}
