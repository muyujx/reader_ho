import router from '@ohos.router';
import { addHost } from '@ohos/common';
import { FavoriteBookInfo, FavoriteBookList, getFavoriteBookListApi, delFavoriteApi } from '@ohos/bookshelf';
import { window } from '@kit.ArkUI';

const DEFAULT_FIRST_PAGE = 1;
const DEFAULT_PAGE_SIZE = 5;
const LARGE_SCREEN_WIDTH = 400;

@Component
export struct FavoritePage {
  @State page: number = 1;
  @State pageSize: number = DEFAULT_PAGE_SIZE;
  @State totalPage: number = 1;
  @State favoriteList: FavoriteBookInfo[] = [];
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State screenWidth: number = 360;

  aboutToAppear() {
    this.initScreenWidth();
    this.loadFavoriteList();
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

  loadFavoriteList() {
    this.isLoading = true;
    getFavoriteBookListApi(this.page, this.pageSize)
      .then((result: FavoriteBookList) => {
        this.totalPage = result.totalPage;
        this.favoriteList = result.content;
      })
      .catch((err: Error | Object) => {
        console.error('loadFavoriteList error:', JSON.stringify(err));
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  onRefresh() {
    this.page = 1;
    this.isRefreshing = true;
    getFavoriteBookListApi(this.page, this.pageSize)
      .then((result: FavoriteBookList) => {
        this.totalPage = result.totalPage;
        this.favoriteList = result.content;
      })
      .catch((err: Error | Object) => {
        console.error('onRefresh error:', JSON.stringify(err));
      })
      .finally(() => {
        this.isRefreshing = false;
      });
  }

  jumpToPage(pageIdx: number) {
    if (pageIdx < 1 || pageIdx > this.totalPage) {
      return;
    }
    this.page = pageIdx;
    this.loadFavoriteList();
  }

  cancelFavorite(bookId: number) {
    delFavoriteApi(bookId)
      .then(() => {
        this.loadFavoriteList();
      })
      .catch((err: Error | Object) => {
        console.error('cancelFavorite error:', JSON.stringify(err));
      });
  }

  getProgressPercent(book: FavoriteBookInfo): number {
    if (book.lastRead === 0 || book.totalPage === 0) {
      return 0;
    }
    return Math.floor((book.page / book.totalPage) * 100);
  }

  getProgressText(book: FavoriteBookInfo): string {
    if (book.lastRead === 0) {
      return `0 / ${book.totalPage} 页`;
    }
    return `${book.page} / ${book.totalPage} 页`;
  }

  getReadTimeText(minutes: number): string {
    const totalMinutes = Math.floor(minutes / 60);
    if (totalMinutes < 60) {
      return `${totalMinutes} 分钟`;
    }
    const hours = Math.floor(totalMinutes / 60);
    const mins = Math.floor(totalMinutes % 60);
    if (mins === 0) {
      return `${hours} 小时`;
    }
    return `${hours} 小时 ${mins} 分钟`;
  }

  getLastReadText(lastReadTime: number): string {
    if (lastReadTime === 0) {
      return '未阅读';
    }
    const now = Date.now();
    const diff = now - lastReadTime;
    const seconds = Math.floor(diff / 1000);
    if (seconds < 60) {
      return '刚刚';
    }
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) {
      return `${minutes} 分钟前`;
    }
    const hours = Math.floor(minutes / 60);
    if (hours < 24) {
      return `${hours} 小时前`;
    }
    const days = Math.floor(hours / 24);
    return `${days} 天前`;
  }

  @Builder
  bookListEmpty() {
    Column() {
      Image($r('app.media.ic_empty'))
        .width(80)
        .height(80)
        .opacity(0.5)
      Text('还没有收藏书籍')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  bookItem(book: FavoriteBookInfo) {
    Row() {
      Image(addHost(book.coverPic))
        .width(80)
        .height(110)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(book.bookName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Column() {
          Row() {
            Text('阅读进度:')
              .fontSize(12)
              .fontColor('#666666')
            Text(this.getProgressText(book))
              .fontSize(12)
              .fontColor('#333333')
              .margin({ left: 8 })
            Text(`${this.getProgressPercent(book)}%`)
              .fontSize(12)
              .fontColor('#333333')
              .margin({ left: 8 })
          }

          Progress({
            value: this.getProgressPercent(book),
            total: 100
          })
            .color('#00C5CD')
            .width('100%')
            .height(8)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 8 })
        .width('100%')

        Row() {
          Text('阅读时间:')
            .fontSize(12)
            .fontColor('#666666')
          Text(this.getReadTimeText(book.readingCost))
            .fontSize(12)
            .fontColor('#333333')
            .margin({ left: 8 })
        }
        .margin({ top: 6 })
        .width('100%')

        Row() {
          Text('上次阅读:')
            .fontSize(12)
            .fontColor('#666666')
          Text(this.getLastReadText(book.lastRead))
            .fontSize(12)
            .fontColor('#333333')
            .margin({ left: 8 })
        }
        .margin({ top: 6 })
        .width('100%')
      }
      .layoutWeight(1)
      .height(110)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)

      Column() {
        Blank()
        Text('取消收藏')
          .fontSize(12)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .fontColor('#FFFFFF')
          .backgroundColor('#00C5CD')
          .borderRadius(16)
          .onClick(() => {
            this.cancelFavorite(book.bookId);
          })
      }
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.End)
      .height(110)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 8 })
  }

  @Builder
  bookList() {
    Column() {
      if (!this.favoriteList || this.favoriteList.length === 0) {
        this.bookListEmpty()
      } else {
        List() {
          ForEach(this.favoriteList, (book: FavoriteBookInfo) => {
            ListItem() {
              this.bookItem(book)
            }
          })
        }
        .width('100%')
        .height('100%')
        .padding({ left: 12, right: 12, top: 8 })
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .layoutWeight(1)
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

      Text(`第 ${this.page} / ${this.totalPage} 页`)
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

  build() {
    Column() {
      this.bookList()
      this.pagination()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
