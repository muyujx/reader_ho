import { preferences } from '@kit.ArkData';

const LOGIN_STATE_KEY = 'needLogin';
const LOGIN_STATE_FILE_NAME = 'login_state';

export class LoginStateStore {
  private prefs: preferences.Preferences | null = null;

  async init(context: Context): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, {
        name: LOGIN_STATE_FILE_NAME
      });
    } catch (err) {
      console.error('LoginStateStore init error:', JSON.stringify(err));
    }
  }

  async setNeedLogin(needLogin: boolean): Promise<void> {
    try {
      if (this.prefs) {
        await this.prefs.put(LOGIN_STATE_KEY, needLogin);
        await this.prefs.flush();
      }
    } catch (err) {
      console.error('LoginStateStore setNeedLogin error:', JSON.stringify(err));
    }
  }

  async isNeedLogin(): Promise<boolean> {
    try {
      if (this.prefs) {
        return await this.prefs.get(LOGIN_STATE_KEY, true) as boolean;
      }
    } catch (err) {
      console.error('LoginStateStore isNeedLogin error:', JSON.stringify(err));
    }
    return true;
  }

  async setLoginSuccess(success: boolean): Promise<void> {
    try {
      if (this.prefs) {
        await this.prefs.put(LOGIN_STATE_KEY, !success);
        await this.prefs.flush();
      }
    } catch (err) {
      console.error('LoginStateStore setLoginSuccess error:', JSON.stringify(err));
    }
  }
}

export const loginStateStore = new LoginStateStore();
