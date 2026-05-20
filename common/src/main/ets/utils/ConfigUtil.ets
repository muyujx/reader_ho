let serverHost: string = '';

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
