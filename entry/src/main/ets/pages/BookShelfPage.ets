import { BookInfo, BookTag } from '../model/BookModel';
import { getBookInfoList, searchOnTypeApi } from '../api/BookApi';
import { getAllTag, changeBookTagApi, addFavoriteApi, delFavoriteApi } from '../api/FavoriteBookApi';
import { Tags } from '../components/Tags';
import { TagSelector } from '../components/TagSelector';
import { addHost } from '../constants/Config';
import { window } from '@kit.ArkUI';

const DEFAULT_FIRST_PAGE = 1;
const DEFAULT_TAG = -1;
const DEFAULT_SEARCH_STR = '';
const LARGE_SCREEN_WIDTH = 400;
const BOOK_ITEM_HEIGHT = 180;

@Component
export struct BookShelfPage {
  @State page: number = 1;
  @State pageSize: number = 9;
  @State totalPage: number = 1;
  @State bookList: BookInfo[] = [];
  @State searchText: string = '';
  @State tag: number = -1;
  @State tags: BookTag[] = [];
  @State tagMap: Map<number, BookTag> = new Map();
  @State currentTag: number = -1;
  @State tagBookId: number = -1;
  @State maskShow: boolean = false;
  @State titlePopoverDisable: boolean = false;
  @State isRefreshing: boolean = false;
  @State screenWidth: number = 360;

  aboutToAppear() {
    this.page = DEFAULT_FIRST_PAGE;
    this.tag = DEFAULT_TAG;
    this.searchText = DEFAULT_SEARCH_STR;
    this.pageSize = 9;
    this.initScreenWidth();
    this.loadBookList(false);
    this.loadTags();
  }

  initScreenWidth() {
    try {
      const win = window.getLastWindow(getContext(this));
      win.then((windowClass: window.Window) => {
        const rect = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        const widthPx = rect.topRect.width;
        this.screenWidth = widthPx / 160 * 60;
        if (this.screenWidth < 100) {
          this.screenWidth = 360;
        }
      });
    } catch (err) {
      this.screenWidth = 360;
    }
  }

  isLargeScreen(): boolean {
    return this.screenWidth >= LARGE_SCREEN_WIDTH;
  }

  onRefresh() {
    this.page = 1;
    this.isRefreshing = true;
    const bookPromise = getBookInfoList(this.page, this.pageSize, this.searchText, this.tag);
    const tagPromise = getAllTag();
    
    bookPromise
      .then((bookResult) => {
        this.totalPage = bookResult.totalPage;
        this.bookList = bookResult.content;
      })
      .catch((err: Error | Object) => {
        console.error('onRefresh error:', JSON.stringify(err));
      });
    
    tagPromise
      .then((tagResult) => {
        this.tags = tagResult;
        this.tagMap.clear();
        for (let tagItem of tagResult) {
          this.tagMap.set(tagItem.id, tagItem);
        }
      })
      .catch((err: Error | Object) => {
        console.error('loadTags error:', JSON.stringify(err));
      });
    
    Promise.all([bookPromise, tagPromise])
      .finally(() => {
        this.isRefreshing = false;
      });
  }

  loadBookList(showLoading: boolean = true) {
    getBookInfoList(this.page, this.pageSize, this.searchText, this.tag)
      .then((result) => {
        this.totalPage = result.totalPage;
        this.bookList = result.content;
      })
      .catch((err: Error | Object) => {
        console.error('loadBookList error:', JSON.stringify(err));
      });
  }

  loadTags() {
    getAllTag()
      .then((result) => {
        this.tags = result;
        for (let tagItem of result) {
          this.tagMap.set(tagItem.id, tagItem);
        }
      })
      .catch((err: Error | Object) => {
        console.error('loadTags error:', JSON.stringify(err));
      });
  }

  jumpToPage(pageIdx: number) {
    if (pageIdx < 1 || (this.totalPage !== 0 && pageIdx > this.totalPage)) {
      return;
    }
    this.page = pageIdx;
    this.loadBookList();
  }

  onSearch() {
    if (this.searchText.length > 0) {
      this.tag = DEFAULT_TAG;
    }
    this.jumpToPage(1);
  }

  onTagChange(curTag: number) {
    if (curTag === this.tag) {
      return;
    }
    this.tag = curTag;
    this.jumpToPage(1);
  }

  onTagSelectorChange(tagId: number) {
    changeBookTagApi(this.tagBookId, tagId).then(() => {
      this.loadBookList();
    })
    this.maskCancel();
  }

  chooseTag(book: BookInfo, targetIndex: number) {
    this.titlePopoverDisable = true;
    this.maskShow = true;
    this.currentTag = book.tagId;
    this.tagBookId = book.bookId;
  }

  maskCancel() {
    this.maskShow = false;
    this.titlePopoverDisable = false;
  }

  changeFavorite(book: BookInfo) {
    if (book.favorite) {
      delFavoriteApi(book.bookId)
        .finally(() => {
          this.loadBookList();
        });
    } else {
      addFavoriteApi(book.bookId)
        .finally(() => {
          this.loadBookList();
        });
    }
  }

  getTagName(tagId: number): string {
    if (tagId === -1) {
      return '未分类';
    }
    const tagItem = this.tagMap.get(tagId);
    return tagItem ? tagItem.name : '';
  }

  getPageNumbers(): number[] {
    const pages: number[] = [];
    if (this.totalPage <= 5) {
      for (let i = 1; i <= this.totalPage; i++) {
        pages.push(i);
      }
      return pages;
    }
    const start = Math.max(1, this.page - 1);
    const end = Math.min(this.totalPage, this.page + 2);
    for (let i = start; i <= end; i++) {
      pages.push(i);
    }
    return pages;
  }

  @Builder
  searchBar() {
    Row() {
      TextInput({ placeholder: '根据书名或作者名搜索', text: this.searchText })
        .height(40)
        .layoutWeight(1)
        .borderRadius(20)
        .backgroundColor('#F5F5F5')
        .padding({ left: 16, right: 16 })
        .fontSize(14)
        .onChange((value: string) => {
          this.searchText = value;
        })
        .onSubmit(() => {
          this.onSearch();
        })

      Button('搜索')
        .height(40)
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor('#00C5CD')
        .borderRadius(20)
        .padding({ left: 20, right: 20 })
        .onClick(() => {
          this.onSearch();
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 12 })
  }

  getColumnsTemplate(): string {
    return this.isLargeScreen() ? '1fr 1fr 1fr' : '1fr 1fr';
  }

  getRowsCount(): number {
    return 3;
  }

  @Builder
  bookGrid() {
    Column() {
      Refresh({ refreshing: this.isRefreshing }) {
        Column() {
          if (this.bookList.length === 0) {
            Column() {
              Image($r('app.media.ic_empty'))
                .width(80)
                .height(80)
                .opacity(0.5)
              Text('书架为空')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 16 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          } else {
            Grid() {
              ForEach(this.getDisplayBooks(), (book: BookInfo, index: number) => {
                GridItem() {
                  this.bookItem(book)
                }
              })
            }
            .columnsTemplate(this.getColumnsTemplate())
            .rowsTemplate('1fr 1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .padding({ left: 16, right: 16 })
            .width('100%')
            .height('100%')
          }
        }
        .width('100%')
      }
      .onRefreshing(() => {
        this.onRefresh();
      })
    }
    .width('100%')
    .layoutWeight(1)
  }

  getDisplayBooks(): BookInfo[] {
    return this.bookList.slice(0, this.pageSize);
  }

  getBookRows(): BookInfo[][] {
    const rows: BookInfo[][] = [];
    for (let i = 0; i < this.bookList.length; i += 3) {
      const row: BookInfo[] = [];
      for (let j = 0; j < 3 && i + j < this.bookList.length; j++) {
        row.push(this.bookList[i + j]);
      }
      rows.push(row);
    }
    return rows;
  }

  @Builder
  bookItem(book: BookInfo) {
    Column() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Image(addHost(book.coverPic))
          .width('100%')
          .height('100%')
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .clip(true)

        if (book.tagId !== -1) {
          Text(this.getTagName(book.tagId))
            .fontSize(10)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor('#00C5CD')
            .fontColor('#FFFFFF')
            .borderRadius({ topRight: 8, bottomLeft: 8 })
        }
      }
      .width('100%')
      .height('85%')
      .clip(true)

      Text(book.bookName)
        .fontSize(11)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 2, right: 2 })
    .onClick(() => {
    })
  }

  @Builder
  pagination() {
    Row() {
      Button('上一页')
        .fontSize(14)
        .height(36)
        .fontColor(this.page > 1 ? '#00C5CD' : '#999999')
        .backgroundColor('#FFFFFF')
        .borderColor(this.page > 1 ? '#00C5CD' : '#E0E0E0')
        .borderWidth(1)
        .borderRadius(18)
        .enabled(this.page > 1)
        .onClick(() => {
          this.jumpToPage(this.page - 1);
        })

      Text(this.page + ' / ' + this.totalPage)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ left: 16, right: 16 })

      Button('下一页')
        .fontSize(14)
        .height(36)
        .fontColor(this.page < this.totalPage ? '#00C5CD' : '#999999')
        .backgroundColor('#FFFFFF')
        .borderColor(this.page < this.totalPage ? '#00C5CD' : '#E0E0E0')
        .borderWidth(1)
        .borderRadius(18)
        .enabled(this.page < this.totalPage)
        .onClick(() => {
          this.jumpToPage(this.page + 1);
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 8, bottom: 12 })
  }

  @Builder
  pageButton(pageNum: number) {
    Text(pageNum.toString())
      .fontSize(12)
      .height(32)
      .width(36)
      .fontColor(this.page === pageNum ? '#FFFFFF' : '#666666')
      .backgroundColor(this.page === pageNum ? '#00C5CD' : '#FFFFFF')
      .borderColor(this.page === pageNum ? '#00C5CD' : '#E0E0E0')
      .borderWidth(1)
      .borderRadius(16)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        this.jumpToPage(pageNum);
      })
  }

  @Builder
  tagSelectorPanel() {
    if (this.maskShow) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#40000000')
          .onClick(() => {
            this.maskCancel();
          })

        Column() {
          TagSelector({
            tags: this.tags,
            currentTag: this.currentTag,
            onTagChange: (tagId: number) => {
              this.onTagSelectorChange(tagId);
            }
          })
        }
        .position({ x: 100, y: 200 })
      }
      .width('100%')
      .height('100%')
    }
  }

  build() {
    Stack() {
      Column() {
        this.searchBar()

        Tags({
          tags: this.tags,
          currentTag: this.tag,
          onTagChange: (tagId: number) => {
            this.onTagChange(tagId);
          }
        })

        this.bookGrid()

        this.pagination()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      if (this.maskShow) {
        this.tagSelectorPanel()
      }
    }
    .width('100%')
    .height('100%')
  }
}
