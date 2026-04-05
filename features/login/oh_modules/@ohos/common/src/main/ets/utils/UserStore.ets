import { preferences } from '@kit.ArkData';

const USER_KEY = 'user';
const USER_FILE_NAME = 'user_store';

export interface UserInfo {
  userId: number;
  role: number;
  account: string;
}

export class UserStore {
  private prefs: preferences.Preferences | null = null;

  async init(): Promise<void> {
    try {
      const context = getContext(this);
      this.prefs = await preferences.getPreferences(context, {
        name: USER_FILE_NAME
      });
    } catch (err) {
      console.error('UserStore init error:', JSON.stringify(err));
    }
  }

  async saveUser(user: UserInfo): Promise<void> {
    try {
      if (this.prefs) {
        await this.prefs.put(USER_KEY, JSON.stringify(user));
        await this.prefs.flush();
        console.info('UserStore saveUser success:', JSON.stringify(user));
      } else {
        console.error('UserStore saveUser skipped: prefs is null');
      }
    } catch (err) {
      console.error('UserStore saveUser error:', JSON.stringify(err));
    }
  }

  async getUser(): Promise<UserInfo | null> {
    try {
      if (this.prefs) {
        const userStr = await this.prefs.get(USER_KEY, '') as string;
        if (userStr) {
          return JSON.parse(userStr) as UserInfo;
        }
      }
    } catch (err) {
      console.error('UserStore getUser error:', JSON.stringify(err));
    }
    return null;
  }

  async isLoggedIn(): Promise<boolean> {
    const user = await this.getUser();
    return user !== null && user.userId !== undefined && user.userId > 0;
  }

  async clearUser(): Promise<void> {
    try {
      if (this.prefs) {
        await this.prefs.delete(USER_KEY);
        await this.prefs.flush();
        console.info('UserStore clearUser success');
      }
    } catch (err) {
      console.error('UserStore clearUser error:', JSON.stringify(err));
    }
  }
}

export const userStore = new UserStore();
