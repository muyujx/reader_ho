import { requestPost, requestGet, BookInfo, BookPageResponse } from '@ohos/common';

export interface BookQueryParam {
  page: number;
  pageSize: number;
  searchStr?: string;
  tag?: number;
}

export function getBookInfoList(page: number, pageSize: number, searchStr: string = '', tag: number = -1): Promise<BookPageResponse> {
  const body: BookQueryParam = {
    page: page,
    pageSize: pageSize,
    searchStr: searchStr,
    tag: tag
  };
  return requestPost<BookPageResponse>({
    url: '/api/book/info/search/book',
    body: body
  });
}

export function getBookDetail(bookId: number): Promise<BookInfo> {
  return requestGet<BookInfo>({
    url: '/api/book/info/get/book/info',
    queryParam: `bookId=${bookId}`
  });
}
