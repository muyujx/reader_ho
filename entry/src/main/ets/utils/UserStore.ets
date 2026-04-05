import { preferences } from '@kit.ArkData';
import { UserInfo, UserRole } from '../model/UserModel';

const PREFERENCES_NAME = 'user_preferences';
const KEY_USER_ID = 'userId';
const KEY_ROLE = 'role';
const KEY_ACCOUNT = 'account';

class UserStore {
  private prefs: preferences.Preferences | null = null;

  async init() {
    if (this.prefs === null) {
      this.prefs = await preferences.getPreferences(getContext(), {
        name: PREFERENCES_NAME
      });
    }
  }

  async saveUser(user: UserInfo) {
    await this.init();
    await this.prefs!.put(KEY_USER_ID, user.userId);
    await this.prefs!.put(KEY_ROLE, user.role);
    await this.prefs!.put(KEY_ACCOUNT, user.account);
    await this.prefs!.flush();
  }

  async getUser(): Promise<UserInfo | null> {
    await this.init();
    const userId = await this.prefs!.get(KEY_USER_ID, '') as string;
    if (!userId) {
      return null;
    }
    const role = await this.prefs!.get(KEY_ROLE, UserRole.User) as number;
    const account = await this.prefs!.get(KEY_ACCOUNT, '') as string;
    return {
      userId: userId,
      role: role,
      account: account
    };
  }

  async clearUser() {
    await this.init();
    await this.prefs!.delete(KEY_USER_ID);
    await this.prefs!.delete(KEY_ROLE);
    await this.prefs!.delete(KEY_ACCOUNT);
    await this.prefs!.flush();
  }

  async isLoggedIn(): Promise<boolean> {
    const user = await this.getUser();
    return user !== null && user.userId !== '';
  }
}

export const userStore = new UserStore();