import { setServerHost } from './ConfigUtil';

const SERVER_CONFIG_FILE = 'config.json';

export class ServerConfigStore {
  async loadServerConfig(context: Context): Promise<void> {
    try {
      const resMgr = context.resourceManager;
      const rawData: Uint8Array = await resMgr.getRawFileContent(SERVER_CONFIG_FILE);
      let configStr: string = '';
      for (let i: number = 0; i < rawData.length; i++) {
        configStr += String.fromCharCode(rawData[i]);
      }
      const config: Record<string, string> = JSON.parse(configStr);
      if (config.serverHost) {
        setServerHost(config.serverHost);
      }
    } catch (err) {
      console.error('ServerConfigStore loadServerConfig error:', JSON.stringify(err));
    }
  }
}

export const serverConfigStore = new ServerConfigStore();
