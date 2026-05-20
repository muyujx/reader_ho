import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';

const COOKIE_KEY = 'sessionId';
const COOKIE_FILE_NAME = 'reader_cookie';

export class CookieStore {
  private prefs: preferences.Preferences | null = null;

  async init(context: Context): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, {
        name: COOKIE_FILE_NAME
      });
      hilog.info(0x0000, 'CookieStore', 'init success, prefs: %{public}s', this.prefs ? 'ok' : 'null');
    } catch (err) {
      hilog.error(0x0000, 'CookieStore', 'init error: %{public}s', JSON.stringify(err));
    }
  }

  async setCookie(cookie: string): Promise<void> {
    try {
      if (this.prefs) {
        await this.prefs.put(COOKIE_KEY, cookie);
        await this.prefs.flush();
        hilog.info(0x0000, 'CookieStore', 'setCookie success: %{public}s', cookie);
      } else {
        hilog.error(0x0000, 'CookieStore', 'setCookie failed: prefs is null');
      }
    } catch (err) {
      hilog.error(0x0000, 'CookieStore', 'setCookie error: %{public}s', JSON.stringify(err));
    }
  }

  getCookie(): string {
    try {
      if (this.prefs) {
        const cookie = this.prefs.getSync(COOKIE_KEY, '') as string;
        hilog.info(0x0000, 'CookieStore', 'getCookie: %{public}s', cookie || '(empty)');
        return cookie;
      } else {
        hilog.error(0x0000, 'CookieStore', 'getCookie failed: prefs is null');
      }
    } catch (err) {
      hilog.error(0x0000, 'CookieStore', 'getCookie error: %{public}s', JSON.stringify(err));
    }
    return '';
  }

  async clearCookie(): Promise<void> {
    try {
      if (this.prefs) {
        await this.prefs.delete(COOKIE_KEY);
        await this.prefs.flush();
        hilog.info(0x0000, 'CookieStore', 'clearCookie success');
      }
    } catch (err) {
      hilog.error(0x0000, 'CookieStore', 'clearCookie error: %{public}s', JSON.stringify(err));
    }
  }
}

export const cookieStore = new CookieStore();
