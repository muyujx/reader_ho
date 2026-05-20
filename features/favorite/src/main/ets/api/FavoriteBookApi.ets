import { requestPost } from '@ohos/common';

export interface FavoriteBookInfo {
  bookName: string;
  totalPage: number;
  bigCoverPic: string;
  bookId: number;
  coverPic: string;
  tagId: number;
  page: number;
  lastRead: number;
  readingCost: number;
}

export interface FavoriteBookList {
  content: FavoriteBookInfo[];
  total: number;
  totalPage: number;
}

interface FavoriteListBody {
  page: number;
  pageSize: number;
}

interface BookIdBody {
  bookId: number;
}

export function addFavoriteApi(bookId: number): Promise<void> {
  const body: BookIdBody = {
    bookId: bookId
  };
  return requestPost<void>({
    url: '/api/favorite/add',
    body: body
  });
}

export function delFavoriteApi(bookId: number): Promise<void> {
  const body: BookIdBody = {
    bookId: bookId
  };
  return requestPost<void>({
    url: '/api/favorite/delete',
    body: body
  });
}

export function getFavoriteBookListApi(page: number, pageSize: number): Promise<FavoriteBookList> {
  const body: FavoriteListBody = {
    page: page,
    pageSize: pageSize
  };
  return requestPost<FavoriteBookList>({
    url: '/api/favorite/list',
    body: body
  });
}
