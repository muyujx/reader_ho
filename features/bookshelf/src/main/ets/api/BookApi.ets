import { requestPost, BookPageResponse } from '@ohos/common';

interface BookQueryParam {
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
