import { http } from '@kit.NetworkKit';
import { loginStateStore } from './LoginState';
import { cookieStore } from './CookieStore';
import { getFullUrl } from './ConfigUtil';

export interface RequestParam {
  url: string;
  body?: object;
  queryParam?: string;
}

export interface ResponseModel<T> {
  code: number;
  data: T;
  message: string;
}

export class NeedLoginError extends Error {
  code: number;
  constructor(code: number, message: string = 'need login') {
    super(message);
    this.code = code;
    this.name = 'NeedLoginError';
  }
}

export async function requestPost<T>(param: RequestParam): Promise<T> {
  const url = getFullUrl(param.url);
  const httpRequest = http.createHttp();

  try {
    const storedCookie = cookieStore.getCookie();

    const response = await httpRequest.request(url, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Cookie': storedCookie
      },
      extraData: JSON.stringify(param.body)
    });

    const responseStr = response.result as string;
    const responseModel: ResponseModel<T> = JSON.parse(responseStr);

    if (responseModel.code === 100) {
      loginStateStore.setNeedLogin(true);
      return Promise.reject(new NeedLoginError(responseModel.code, responseModel.message));
    }

    if (responseModel.code !== 0) {
      return Promise.reject(new Error(responseModel.message));
    }

    const headerStr = JSON.stringify(response.header);
    const setCookieMatch = headerStr.match(/\[\\?"(sessionId=[^"\\]+)\\?"\]/);
    if (setCookieMatch && setCookieMatch[1]) {
      const cookiePart = setCookieMatch[1];
      await cookieStore.setCookie(cookiePart);
    } else {
      const simpleMatch = headerStr.match(/sessionId=([^;\\]+)/);
      if (simpleMatch && simpleMatch[1]) {
        const cookiePart = simpleMatch[1];
        await cookieStore.setCookie(cookiePart);
      }
    }

    return responseModel.data;
  } catch (error) {
    return Promise.reject(error);
  } finally {
    httpRequest.destroy();
  }
}

export async function requestGet<T>(param: RequestParam): Promise<T> {
  const url = getFullUrl(param.url, param.queryParam);
  const httpRequest = http.createHttp();

  try {
    const storedCookie = cookieStore.getCookie();

    const response = await httpRequest.request(url, {
      method: http.RequestMethod.GET,
      header: {
        'Cookie': storedCookie
      }
    });

    const responseStr = response.result as string;
    const responseModel: ResponseModel<T> = JSON.parse(responseStr);

    if (responseModel.code === 100) {
      loginStateStore.setNeedLogin(true);
      return Promise.reject(new NeedLoginError(responseModel.code, responseModel.message));
    }

    if (responseModel.code !== 0) {
      return Promise.reject(new Error(responseModel.message));
    }

    const headerStr = JSON.stringify(response.header);
    const setCookieMatch = headerStr.match(/\[\\?"(sessionId=[^"\\]+)\\?"\]/);
    if (setCookieMatch && setCookieMatch[1]) {
      const cookiePart = setCookieMatch[1];
      await cookieStore.setCookie(cookiePart);
    } else {
      const simpleMatch = headerStr.match(/sessionId=([^;\\]+)/);
      if (simpleMatch && simpleMatch[1]) {
        const cookiePart = simpleMatch[1];
        await cookieStore.setCookie(cookiePart);
      }
    }

    return responseModel.data;
  } catch (error) {
    return Promise.reject(error);
  } finally {
    httpRequest.destroy();
  }
}
