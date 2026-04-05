import { requestPost, requestGet, BookInfo as CommonBookInfo, BookPageResponse } from '@ohos/common';

export interface BookInfo extends CommonBookInfo {
  totalPage?: number;
  bigCoverPic?: string;
}

export interface BookQueryParam {
  page: number;
  pageSize: number;
  searchStr?: string;
  tag?: number;
}

export interface PageItem {
  content: string;
  title: string;
  page: number;
  topChapter: number;
}

export interface ContentsItem {
  level: number;
  startPage: number;
  label: string;
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

export interface BookPageParam {
  bookId: number;
  startPage: number;
  pageSize: number;
}

export interface UpdateProgressParam {
  bookId: number;
  readingCost: number;
  page: number;
}

export function getBookPageList(bookId: number, startPage: number, pageSize: number): Promise<PageItem[]> {
  const body: BookPageParam = {
    bookId: bookId,
    startPage: startPage,
    pageSize: pageSize
  };
  return requestPost<PageItem[]>({
    url: '/api/book/page/html/page',
    body: body
  });
}

export function getContents(bookId: number): Promise<ContentsItem[]> {
  return requestGet<ContentsItem[]>({
    url: `/api/book/info/get/contents?bookId=${bookId}`
  });
}

export function updateReadingProgressApi(bookId: number, page: number, readingCost: number): Promise<void> {
  const body: UpdateProgressParam = {
    bookId,
    readingCost,
    page
  };
  return requestPost<void>({
    url: '/api/book/progress/update',
    body: body
  });
}
