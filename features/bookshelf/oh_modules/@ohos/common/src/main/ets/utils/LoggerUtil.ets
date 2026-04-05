import hilog from '@ohos.hilog';

class LoggerUtil {
  private domain: number;
  private prefix: string;
  private format: string = '%{public}s';

  constructor(domain: number = 0xFF00, prefix: string = 'Reader') {
    this.prefix = prefix;
    this.domain = domain;
  }

  debug(...args: string[]): void {
    hilog.debug(this.domain, this.prefix, this.format, args);
  }

  info(format: string = this.format, ...args: string[]): void {
    hilog.info(this.domain, this.prefix, format, args);
  }

  warn(...args: string[]): void {
    hilog.warn(this.domain, this.prefix, this.format, args);
  }

  error(...args: string[]): void {
    hilog.error(this.domain, this.prefix, this.format, args);
  }
}

export const Logger = new LoggerUtil(0xFF00, 'Reader');
