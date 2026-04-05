import { preferences } from '@kit.ArkData';

const PREFERENCES_NAME = 'login_state';
const KEY_NEED_LOGIN = 'needLogin';
const KEY_LOGIN_SUCCESS = 'loginSuccess';

class LoginStateStore {
  private prefs: preferences.Preferences | null = null;

  async init() {
    if (this.prefs === null) {
      this.prefs = await preferences.getPreferences(getContext(), {
        name: PREFERENCES_NAME
      });
    }
  }

  async setNeedLogin(value: boolean) {
    await this.init();
    await this.prefs!.put(KEY_NEED_LOGIN, value);
    await this.prefs!.flush();
  }

  async getNeedLogin(): Promise<boolean> {
    await this.init();
    return (await this.prefs!.get(KEY_NEED_LOGIN, true)) as boolean;
  }

  async setLoginSuccess(value: boolean) {
    await this.init();
    await this.prefs!.put(KEY_LOGIN_SUCCESS, value);
    await this.prefs!.flush();
  }

  async getLoginSuccess(): Promise<boolean> {
    await this.init();
    return (await this.prefs!.get(KEY_LOGIN_SUCCESS, false)) as boolean;
  }
}

export const loginStateStore = new LoginStateStore();