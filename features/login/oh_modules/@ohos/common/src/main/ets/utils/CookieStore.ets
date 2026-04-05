import { preferences } from '@kit.ArkData';

const COOKIE_KEY = 'sessionId';
const COOKIE_FILE_NAME = 'reader_cookie';

export class CookieStore {
  private prefs: preferences.Preferences | null = null;

  async init(): Promise<void> {
    try {
      const context = getContext(this);
      this.prefs = await preferences.getPreferences(context, {
        name: COOKIE_FILE_NAME
      });
    } catch (err) {
      console.error('CookieStore init error:', JSON.stringify(err));
    }
  }

  async setCookie(cookie: string): Promise<void> {
    try {
      if (this.prefs) {
        await this.prefs.put(COOKIE_KEY, cookie);
        await this.prefs.flush();
        console.info('CookieStore setCookie success:', cookie);
      }
    } catch (err) {
      console.error('CookieStore setCookie error:', JSON.stringify(err));
    }
  }

  getCookie(): string {
    try {
      if (this.prefs) {
        const cookie = this.prefs.getSync(COOKIE_KEY, '') as string;
        console.info('CookieStore getCookie:', cookie);
        return cookie;
      }
    } catch (err) {
      console.error('CookieStore getCookie error:', JSON.stringify(err));
    }
    return '';
  }

  async clearCookie(): Promise<void> {
    try {
      if (this.prefs) {
        await this.prefs.delete(COOKIE_KEY);
        await this.prefs.flush();
        console.info('CookieStore clearCookie success');
      }
    } catch (err) {
      console.error('CookieStore clearCookie error:', JSON.stringify(err));
    }
  }
}

export const cookieStore = new CookieStore();
