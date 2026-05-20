import { preferences } from '@kit.ArkData';

const COOKIE_KEY = 'sessionId';
const COOKIE_FILE_NAME = 'reader_cookie';

export class CookieStore {
  private prefs: preferences.Preferences | null = null;

  async init(context: Context): Promise<void> {
    try {
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
      }
    } catch (err) {
      console.error('CookieStore setCookie error:', JSON.stringify(err));
    }
  }

  getCookie(): string {
    try {
      if (this.prefs) {
        return this.prefs.getSync(COOKIE_KEY, '') as string;
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
      }
    } catch (err) {
      console.error('CookieStore clearCookie error:', JSON.stringify(err));
    }
  }
}

export const cookieStore = new CookieStore();
