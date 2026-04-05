import { getDefaultServerHost, setServerHost } from './ConfigUtil';

const SERVER_CONFIG_FILE = 'config.json';

export interface ServerConfig {
  serverHost: string;
}

export class ServerConfigStore {
  async loadServerConfig(): Promise<string> {
    try {
      const context = getContext(this);
      const resMgr = context.resourceManager;
      const configUint8Array: Uint8Array = await resMgr.getRawFileContent(SERVER_CONFIG_FILE);
      const configArray: Uint8Array = new Uint8Array(configUint8Array);
      let configStr: string = '';
      for (let i: number = 0; i < configArray.length; i++) {
        configStr += String.fromCharCode(configArray[i]);
      }
      const config: ServerConfig = JSON.parse(configStr);
      if (config.serverHost) {
        setServerHost(config.serverHost);
        return config.serverHost;
      }
    } catch (err) {
      console.error('ServerConfigStore loadServerConfig error:', JSON.stringify(err));
    }
    return getDefaultServerHost();
  }
}

export const serverConfigStore = new ServerConfigStore();