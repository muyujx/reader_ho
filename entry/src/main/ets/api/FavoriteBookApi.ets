import { requestPost, requestGet, FavoriteListParams, BookIdParams, ChangeTagParams } from '../utils/HttpUtil';
import { BookTag, FavoriteBookList } from '../model/BookModel';
import {
  API_FAVORITE_LIST,
  API_FAVORITE_ADD,
  API_FAVORITE_DELETE,
  API_BOOK_TAG_GET_ALL,
  API_BOOK_TAG_CHANGE
} from '../constants/Config';

export function getFavoriteBookListApi(page: number, pageSize: number): Promise<FavoriteBookList> {
  const params: FavoriteListParams = { page, pageSize };
  return requestPost<FavoriteBookList>({
    url: API_FAVORITE_LIST,
    body: params
  });
}

export function addFavoriteApi(bookId: number): Promise<void> {
  const params: BookIdParams = { bookId };
  return requestPost<void>({
    url: API_FAVORITE_ADD,
    body: params
  });
}

export function delFavoriteApi(bookId: number): Promise<void> {
  const params: BookIdParams = { bookId };
  return requestPost<void>({
    url: API_FAVORITE_DELETE,
    body: params
  });
}

export function getAllTag(): Promise<BookTag[]> {
  return requestGet<BookTag[]>({
    url: API_BOOK_TAG_GET_ALL
  });
}

export function changeBookTagApi(bookId: number, tagId: number): Promise<void> {
  const params: ChangeTagParams = { bookId, tagId };
  return requestPost<void>({
    url: API_BOOK_TAG_CHANGE,
    body: params
  });
}