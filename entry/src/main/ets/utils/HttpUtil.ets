import { http } from '@kit.NetworkKit';
import { SERVER_HOST } from '../constants/Config';
import { loginStateStore } from './LoginState';
import { cookieStore } from './CookieStore';

export interface ResponseModel<T> {
  data: T;
  code: number;
  message: string;
}

export interface BookSearchParams {
  page: number;
  pageSize: number;
  search: string;
  tag: number;
}

export interface PageListParams {
  bookId: number;
  startPage: number;
  pageSize: number;
}

export interface SearchOnTypeParams {
  query: string;
}

export interface FavoriteListParams {
  page: number;
  pageSize: number;
}

export interface BookIdParams {
  bookId: number;
}

export interface ChangeTagParams {
  bookId: number;
  tagId: number;
}

export interface RequestParam {
  url: string;
  body?: Object;
  queryParam?: string;
}

export async function requestPost<T>(param: RequestParam): Promise<T> {
  const path = param.url.startsWith('/') ? param.url : '/' + param.url;
  const url = SERVER_HOST + path;
  
  console.info('HttpUtil requestPost url:', url);
  console.info('HttpUtil requestPost body:', JSON.stringify(param.body));
  
  const httpRequest = http.createHttp();
  
  try {
    await cookieStore.init();
    const storedCookie = cookieStore.getCookie();
    
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
    console.error('HttpUtil requestPost error:', JSON.stringify(error));
    return Promise.reject(error);
  } finally {
    httpRequest.destroy();
  }
}

export async function requestGet<T>(param: RequestParam): Promise<T> {
  let path = param.url.startsWith('/') ? param.url : '/' + param.url;
  if (param.queryParam) {
    path += '?' + param.queryParam;
  }
  const url = SERVER_HOST + path;
  
  console.info('HttpUtil requestGet url:', url);
  
  const httpRequest = http.createHttp();
  
  try {
    await cookieStore.init();
    const storedCookie = cookieStore.getCookie();
    
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