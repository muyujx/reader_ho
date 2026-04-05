import { http } from '@kit.NetworkKit';
import { fileIo } from '@kit.CoreFileKit';

const IMAGE_CACHE_DIR = 'image_cache';

function getPathFromUrl(url: string): string {
  const startIndex = url.indexOf('/', url.indexOf('://') + 3);
  if (startIndex < 0) {
    return '/' + url;
  }
  return url.substring(startIndex);
}

function createDirRecursive(dirPath: string): void {
  const parts = dirPath.split('/');
  let current = '';
  for (const part of parts) {
    if (part) {
      current += '/' + part;
      try {
        fileIo.listFileSync(current);
      } catch {
        fileIo.mkdirSync(current);
      }
    }
  }
}

export class ImageCacheUtil {
  private cacheDir: string = '';

  async init(): Promise<void> {
    const context = getContext(this);
    this.cacheDir = context.cacheDir + '/' + IMAGE_CACHE_DIR;
    try {
      fileIo.listFileSync(this.cacheDir);
    } catch {
      fileIo.mkdirSync(this.cacheDir);
    }
  }

  private getCacheFilePath(url: string): string {
    const path = getPathFromUrl(url);
    return this.cacheDir + path;
  }

  private async isCached(url: string): Promise<boolean> {
    try {
      const filePath = this.getCacheFilePath(url);
      return fileIo.accessSync(filePath);
    } catch {
      return false;
    }
  }

  private async saveToCache(url: string, data: ArrayBuffer): Promise<string> {
    const filePath = this.getCacheFilePath(url);
    const dirPath = filePath.substring(0, filePath.lastIndexOf('/'));
    createDirRecursive(dirPath);
    const mode: number = 0o100 | 0o200;
    const file = fileIo.openSync(filePath, mode);
    fileIo.writeSync(file.fd, data);
    fileIo.closeSync(file);
    return filePath;
  }

  private async loadFromCache(url: string): Promise<string | null> {
    try {
      const filePath = this.getCacheFilePath(url);
      if (fileIo.accessSync(filePath)) {
        return filePath;
      }
    } catch {
      return null;
    }
    return null;
  }

  async preloadImage(url: string): Promise<void> {
    if (!url) {
      return;
    }
    const cached = await this.isCached(url);
    if (cached) {
      return;
    }
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url);
      if (response.responseCode === 200) {
        const data = response.result as ArrayBuffer;
        await this.saveToCache(url, data);
      }
      httpRequest.destroy();
    } catch (err) {
      console.error('preloadImage error:', JSON.stringify(err));
    }
  }

  async getCachedImagePath(url: string): Promise<string | null> {
    if (!url) {
      return null;
    }
    const cachedPath = await this.loadFromCache(url);
    if (cachedPath) {
      return cachedPath;
    }
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url);
      if (response.responseCode === 200) {
        const data = response.result as ArrayBuffer;
        const filePath = await this.saveToCache(url, data);
        httpRequest.destroy();
        return filePath;
      }
      httpRequest.destroy();
    } catch (err) {
      console.error('getCachedImagePath error:', JSON.stringify(err));
    }
    return null;
  }

  async clearCache(): Promise<void> {
    try {
      const files = fileIo.listFileSync(this.cacheDir);
      const len = files.length;
      for (let i = 0; i < len; i++) {
        const fullPath = this.cacheDir + '/' + files[i];
        const stat = fileIo.statSync(fullPath);
        if (stat.isDirectory()) {
          this.clearSubDir(fullPath);
        } else {
          fileIo.unlinkSync(fullPath);
        }
      }
    } catch (err) {
      console.error('clearCache error:', JSON.stringify(err));
    }
  }

  private clearSubDir(dirPath: string): void {
    try {
      const files = fileIo.listFileSync(dirPath);
      const len = files.length;
      for (let i = 0; i < len; i++) {
        const fullPath = dirPath + '/' + files[i];
        const stat = fileIo.statSync(fullPath);
        if (stat.isDirectory()) {
          this.clearSubDir(fullPath);
        } else {
          fileIo.unlinkSync(fullPath);
        }
      }
      fileIo.rmdirSync(dirPath);
    } catch (err) {
      console.error('clearSubDir error:', JSON.stringify(err));
    }
  }
}

export const imageCacheUtil = new ImageCacheUtil();