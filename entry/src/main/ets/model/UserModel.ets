export enum UserRole {
  User = 0,
  Admin = 1,
}

export interface UserInfo {
  userId: string;
  role: UserRole;
  account: string;
}