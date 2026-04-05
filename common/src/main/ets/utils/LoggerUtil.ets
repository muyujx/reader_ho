import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../constants/CommonConstants';

export class Logger {
  static info(domain: number, tag: string, message: string, ...args: Object[]): void {
    hilog.info(domain, tag, message, args);
  }

  static error(domain: number, tag: string, message: string, ...args: Object[]): void {
    hilog.error(domain, tag, message, args);
  }

  static warn(domain: number, tag: string, message: string, ...args: Object[]): void {
    hilog.warn(domain, tag, message, args);
  }

  static debug(domain: number, tag: string, message: string, ...args: Object[]): void {
    hilog.debug(domain, tag, message, args);
  }
}