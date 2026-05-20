import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
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
  
  console.info('HttpUtil requestPost url:', url);
  console.info('HttpUtil requestPost body:', JSON.stringify(param.body));
  
  const httpRequest = http.createHttp();
  
  try {
    const storedCookie = cookieStore.getCookie();
    hilog.info(0x0000, 'HttpUtil', 'requestPost url: %{public}s, cookie: %{public}s', url, storedCookie || '(empty)');
    
    const response = await httpRequest.request(url, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Cookie': storedCookie
      },
      extraData: param.body ? JSON.stringify(param.body) : undefined
    });
    
    console.info('HttpUtil response:', JSON.stringify(response));
    
    const responseStr = response.result as string;
    console.info('HttpUtil response result:', responseStr);
    
    const responseModel: ResponseModel<T> = JSON.parse(responseStr);

    console.info('HttpUtil responseModel:', JSON.stringify(responseModel));

    if (responseModel.code === 100) {
      loginStateStore.setNeedLogin(true);
      return Promise.reject(new NeedLoginError(responseModel.code, responseModel.message));
    }

    if (responseModel.code !== 0) {
      return Promise.reject(new Error(responseModel.message));
    }

    const headerStr = JSON.stringify(response.header);
    console.info('HttpUtil headerStr:', headerStr);

    const setCookieMatch = headerStr.match(/\[\\?"(sessionId=[^"\\]+)\\?"\]/);
    if (setCookieMatch && setCookieMatch[1]) {
      const cookiePart = setCookieMatch[1];
      console.info('HttpUtil setCookie found:', cookiePart);
      await cookieStore.setCookie(cookiePart);
    } else {
      const simpleMatch = headerStr.match(/sessionId=([^;\\]+)/);
      if (simpleMatch && simpleMatch[1]) {
        const cookiePart = simpleMatch[1];
        console.info('HttpUtil setCookie found (simple):', cookiePart);
        await cookieStore.setCookie(cookiePart);
      } else {
        console.info('HttpUtil setCookie not found in header');
      }
    }

    return responseModel.data;
  } catch (error) {
    console.error('HttpUtil requestPost error:', JSON.stringify(error));
    return Promise.reject(error);
  } finally {
    httpRequest.destroy();
  }
}

export async function requestGet<T>(param: RequestParam): Promise<T> {
  const url = getFullUrl(param.url, param.queryParam);
  
  console.info('HttpUtil requestGet url:', url);
  
  const httpRequest = http.createHttp();
  
  try {
    const storedCookie = cookieStore.getCookie();
    hilog.info(0x0000, 'HttpUtil', 'requestGet url: %{public}s, cookie: %{public}s', url, storedCookie || '(empty)');
    
    const response = await httpRequest.request(url, {
      method: http.RequestMethod.GET,
      header: {
        'Cookie': storedCookie
      }
    });
    
    console.info('HttpUtil response:', JSON.stringify(response));
    
    const responseStr = response.result as string;
    console.info('HttpUtil response result:', responseStr);
    
    const responseModel: ResponseModel<T> = JSON.parse(responseStr);
    
    if (responseModel.code === 100) {
      loginStateStore.setNeedLogin(true);
      return Promise.reject(new Error('need login'));
    }
    
    if (responseModel.code !== 0) {
      return Promise.reject(new Error(responseModel.message));
    }
    
    const headerStr = JSON.stringify(response.header);
    console.info('HttpUtil headerStr:', headerStr);
    
    const setCookieMatch = headerStr.match(/\[\\?"(sessionId=[^"\\]+)\\?"\]/);
    if (setCookieMatch && setCookieMatch[1]) {
      const cookiePart = setCookieMatch[1];
      console.info('HttpUtil setCookie found:', cookiePart);
      await cookieStore.setCookie(cookiePart);
    } else {
      const simpleMatch = headerStr.match(/sessionId=([^;\\]+)/);
      if (simpleMatch && simpleMatch[1]) {
        const cookiePart = simpleMatch[1];
        console.info('HttpUtil setCookie found (simple):', cookiePart);
        await cookieStore.setCookie(cookiePart);
      } else {
        console.info('HttpUtil setCookie not found in header');
      }
    }
    
    return responseModel.data;
  } catch (error) {
    console.error('HttpUtil requestGet error:', JSON.stringify(error));
    return Promise.reject(error);
  } finally {
    httpRequest.destroy();
  }
}
