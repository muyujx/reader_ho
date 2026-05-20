import { hilog } from '@kit.PerformanceAnalysisKit';
import { setServerHost } from './ConfigUtil';

const SERVER_CONFIG_FILE = 'config.json';
const DOMAIN = 0x0000;

export class ServerConfigStore {
  async loadServerConfig(context: Context): Promise<void> {
    try {
      const resMgr = context.resourceManager;
      hilog.info(DOMAIN, 'ServerConfig', 'loadServerConfig start');
      const rawData: Uint8Array = await resMgr.getRawFileContent(SERVER_CONFIG_FILE);
      let configStr: string = '';
      for (let i: number = 0; i < rawData.length; i++) {
        configStr += String.fromCharCode(rawData[i]);
      }
      hilog.info(DOMAIN, 'ServerConfig', 'config content: %{public}s', configStr);
      const config: Record<string, string> = JSON.parse(configStr);
      if (config.serverHost) {
        setServerHost(config.serverHost);
      } else {
        hilog.error(DOMAIN, 'ServerConfig', 'serverHost field is empty or missing');
      }
    } catch (err) {
      hilog.error(DOMAIN, 'ServerConfig', 'loadServerConfig error: %{public}s', JSON.stringify(err));
    }
  }
}

export const serverConfigStore: ServerConfigStore = new ServerConfigStore();
