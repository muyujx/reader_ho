export interface BookInfo {
  bookId: number;
  bookName: string;
  coverPic: string;
  bigCoverPic: string;
  tagId: number;
  favorite: boolean;
  totalPage: number;
}

export interface BookShelfList {
  content: BookInfo[];
  total: number;
  totalPage: number;
}

export interface PageItem {
  content: string;
  title: string;
  page: number;
  topChapter: number;
}

export interface ContentsItem {
  title: string;
  level: number;
  page: number;
  index: number;
}

export interface SearchOnTypeItem {
  id: number;
  name: string;
  highlight: string;
}

export interface BookTag {
  id: number;
  name: string;
  order: number;
}

export interface FavoriteBookList {
  content: BookInfo[];
  total: number;
  totalPage: number;
}