import { requestPost, requestGet, BookSearchParams, PageListParams, SearchOnTypeParams } from '../utils/HttpUtil';
import { BookInfo, BookShelfList, PageItem, ContentsItem, SearchOnTypeItem } from '../model/BookModel';
import {
  API_BOOK_INFO_SEARCH,
  API_BOOK_PAGE_LIST,
  API_BOOK_INFO_GET,
  API_BOOK_CONTENTS,
  API_BOOK_SEARCH_ON_TYPE
} from '../constants/Config';

export function getBookInfoList(page: number, pageSize: number, search: string, tag: number): Promise<BookShelfList> {
  const params: BookSearchParams = { page, pageSize, search, tag };
  return requestPost<BookShelfList>({
    url: API_BOOK_INFO_SEARCH,
    body: params
  });
}

export function getBookPageList(bookId: number, startPage: number, pageSize: number): Promise<PageItem[]> {
  const params: PageListParams = { bookId, startPage, pageSize };
  return requestPost<PageItem[]>({
    url: API_BOOK_PAGE_LIST,
    body: params
  });
}

export function getBookInfo(bookId: number): Promise<BookInfo> {
  return requestGet<BookInfo>({
    url: API_BOOK_INFO_GET + '?bookId=' + bookId
  });
}

export function getContents(bookId: number): Promise<ContentsItem[]> {
  return requestGet<ContentsItem[]>({
    url: API_BOOK_CONTENTS + '?bookId=' + bookId
  });
}

export function searchOnTypeApi(query: string): Promise<SearchOnTypeItem[]> {
  const params: SearchOnTypeParams = { query };
  return requestPost<SearchOnTypeItem[]>({
    url: API_BOOK_SEARCH_ON_TYPE,
    body: params
  });
}