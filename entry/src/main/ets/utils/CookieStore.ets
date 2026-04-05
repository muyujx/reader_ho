import { preferences } from '@kit.ArkData';

const PREFERENCES_NAME = 'cookie_store';
const KEY_COOKIE = 'session_cookie';

class CookieStore {
  private prefs: preferences.Preferences | null = null;
  private cookie: string = '';

  async init() {
    if (this.prefs === null) {
      this.prefs = await preferences.getPreferences(getContext(), {
        name: PREFERENCES_NAME
      });
      this.cookie = (await this.prefs.get(KEY_COOKIE, '')) as string;
    }
  }

  async setCookie(cookie: string) {
    this.cookie = cookie;
    await this.init();
    await this.prefs!.put(KEY_COOKIE, cookie);
    await this.prefs!.flush();
  }

  getCookie(): string {
    return this.cookie;
  }

  async clearCookie() {
    this.cookie = '';
    await this.init();
    await this.prefs!.delete(KEY_COOKIE);
    await this.prefs!.flush();
  }
}

export const cookieStore = new CookieStore();