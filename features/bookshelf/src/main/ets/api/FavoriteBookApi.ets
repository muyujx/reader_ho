import { requestPost, requestGet, BookTag } from '@ohos/common';

interface ChangeBookTagBody {
  bookId: number;
  tagId: number;
}

interface AddFavoriteBody {
  bookId: number;
}

export function getAllTag(): Promise<BookTag[]> {
  return requestGet<BookTag[]>({
    url: '/api/book/tag/get/all'
  });
}

export function changeBookTagApi(bookId: number, tagId: number): Promise<void> {
  const body: ChangeBookTagBody = {
    bookId,
    tagId
  };
  return requestPost<void>({
    url: '/api/book/tag/change',
    body: body
  });
}

export function addFavoriteApi(bookId: number): Promise<void> {
  const body: AddFavoriteBody = {
    bookId: bookId
  };
  return requestPost<void>({
    url: '/api/favorite/add',
    body: body
  });
}

export function delFavoriteApi(bookId: number): Promise<void> {
  const body: AddFavoriteBody = {
    bookId: bookId
  };
  return requestPost<void>({
    url: '/api/favorite/delete',
    body: body
  });
}
