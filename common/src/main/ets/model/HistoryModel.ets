export interface BookHistory {
  bookName: string;
  coverPic: string;
  readingCost: number;
  startPage: number;
  endPage: number;
}

export interface ReadingHistoryItem {
  dayStr: string;
  bookList: BookHistory[];
}
