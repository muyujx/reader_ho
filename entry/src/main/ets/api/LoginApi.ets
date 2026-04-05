import { requestPost } from '../utils/HttpUtil';
import { UserRole } from '../model/UserModel';

export interface LoginResponse {
  userId: string;
  role: UserRole;
  account: string;
}

export interface LoginParams {
  account: string;
  password: string;
  clientType: number;
}

export interface RegisterParams {
  account: string;
  password: string;
}

export interface EmptyParams {
}

export function loginApi(account: string, password: string): Promise<LoginResponse> {
  const params: LoginParams = {
    account: account,
    password: password,
    clientType: 1
  };
  return requestPost<LoginResponse>({
    url: '/api/login',
    body: params
  });
}

export function registerApi(account: string, password: string): Promise<LoginResponse> {
  const params: RegisterParams = {
    account: account,
    password: password
  };
  return requestPost<LoginResponse>({
    url: '/api/register',
    body: params
  });
}

export function checkLoginApi(): Promise<LoginResponse> {
  return requestPost<LoginResponse>({
    url: '/api/check_login'
  });
}

export function logoutApi(): Promise<void> {
  const params: EmptyParams = {};
  return requestPost<void>({
    url: '/api/logout',
    body: params
  });
}