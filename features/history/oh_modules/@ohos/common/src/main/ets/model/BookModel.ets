export interface BookInfo {
  bookId: number;
  bookName: string;
  author: string;
  coverPic: string;
  tagId: number;
  favorite: boolean;
}

export interface BookTag {
  id: number;
  name: string;
}

export interface BookContent {
  chapterId: number;
  chapterName: string;
  content: string;
}

export interface ChapterList {
  bookId: number;
  chapters: BookContent[];
}

export interface BookDetail {
  bookInfo: BookInfo;
  introduction: string;
  chapterList: BookContent[];
}

export interface BookPageResponse {
  content: BookInfo[];
  totalPage: number;
  totalElements: number;
}
