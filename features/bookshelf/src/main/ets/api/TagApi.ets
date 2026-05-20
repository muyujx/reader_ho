import { requestPost, requestGet, BookTag } from '@ohos/common';

interface ChangeBookTagBody {
  bookId: number;
  tagId: number;
}

export function getAllTag(): Promise<BookTag[]> {
  return requestGet<BookTag[]>({
    url: '/api/book/tag/get/all'
  });
}

export function changeBookTagApi(bookId: number, tagId: number): Promise<void> {
  const body: ChangeBookTagBody = {
    bookId: bookId,
    tagId: tagId
  };
  return requestPost<void>({
    url: '/api/book/tag/change',
    body: body
  });
}
