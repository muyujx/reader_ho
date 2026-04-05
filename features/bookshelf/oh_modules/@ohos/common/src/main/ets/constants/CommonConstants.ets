export class CommonConstants {
  static readonly LOGGER_TAG: string = 'Reader';
  static readonly PREFERENCES_FILE_NAME: string = 'reader_preferences';
  static readonly SERVER_HOST: string = 'http://43.136.218.87';
  static readonly MAIN_COLOR: string = '#00C5CD';
}

export function addHost(path: string): string {
  if (path.includes('://')) {
    return path;
  }
  if (!path.startsWith('/')) {
    path = '/' + path;
  }
  return CommonConstants.SERVER_HOST + path;
}
