import { requestPost, BookInfo } from '@ohos/common';

export interface RecommendBookInfo extends BookInfo {
  description: string;
}

export interface RecommendBookList {
  content: RecommendBookInfo[];
  totalPage: number;
}

interface BookQueryParam {
  page: number;
  pageSize: number;
  searchStr: string;
  tag: number;
}

export function getRecommendBookList(page: number, pageSize: number): Promise<RecommendBookList> {
  const body: BookQueryParam = {
    page: page,
    pageSize: pageSize,
    searchStr: '',
    tag: -1
  };
  return requestPost<RecommendBookList>({
    url: '/api/book/info/search/book',
    body: body
  });
}
