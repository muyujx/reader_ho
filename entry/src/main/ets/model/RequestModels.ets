export class BookSearchRequest {
  page: number;
  pageSize: number;
  search: string;
  tag: number;

  constructor(p: number, ps: number, s: string, t: number) {
    this.page = p;
    this.pageSize = ps;
    this.search = s;
    this.tag = t;
  }
}

export class PageListRequest {
  bookId: number;
  startPage: number;
  pageSize: number;

  constructor(bookId: number, startPage: number, pageSize: number) {
    this.bookId = bookId;
    this.startPage = startPage;
    this.pageSize = pageSize;
  }
}

export class SearchOnTypeRequest {
  query: string;

  constructor(query: string) {
    this.query = query;
  }
}

export class FavoriteListRequest {
  page: number;
  pageSize: number;

  constructor(p: number, ps: number) {
    this.page = p;
    this.pageSize = ps;
  }
}

export class BookIdRequest {
  bookId: number;

  constructor(bookId: number) {
    this.bookId = bookId;
  }
}

export class ChangeTagRequest {
  bookId: number;
  tagId: number;

  constructor(bookId: number, tagId: number) {
    this.bookId = bookId;
    this.tagId = tagId;
  }
}