import { requestPost, UserInfo, LoginResponse } from '@ohos/common';

interface LoginBody {
  account: string;
  password: string;
  clientType: number;
}

export function loginApi(account: string, password: string): Promise<LoginResponse> {
  const body: LoginBody = {
    account: account,
    password: password,
    clientType: 1
  };
  return requestPost<LoginResponse>({
    url: '/api/login',
    body: body
  });
}

export function registerApi(account: string, password: string): Promise<LoginResponse> {
  const body: LoginBody = {
    account: account,
    password: password,
    clientType: 1
  };
  return requestPost<LoginResponse>({
    url: '/api/register',
    body: body
  });
}

export function checkLoginApi(): Promise<UserInfo> {
  return requestPost<UserInfo>({
    url: '/api/check_login'
  });
}

export function logoutApi(): Promise<void> {
  return requestPost<void>({
    url: '/api/logout'
  });
}