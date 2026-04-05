const DEFAULT_SERVER_HOST: string = 'http://43.136.218.87';
let serverHost: string = DEFAULT_SERVER_HOST;

export function getServerHost(): string {
  return serverHost;
}

export function setServerHost(host: string): void {
  serverHost = host;
}

export function getFullUrl(path: string, queryParam?: string): string {
  let fullPath = path.startsWith('/') ? path : '/' + path;
  if (queryParam) {
    fullPath += '?' + queryParam;
  }
  return serverHost + fullPath;
}

export function getDefaultServerHost(): string {
  return DEFAULT_SERVER_HOST;
}