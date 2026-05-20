import { addHost } from '@ohos/common';
import { RecommendBookInfo, getRecommendBookList } from '../api/RecommendApi';
import router from '@ohos.router';

const DEFAULT_PAGE_SIZE = 10;

@Component
export struct RecommendPage {
  @State bookList: RecommendBookInfo[] = [];
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State currentPage: number = 1;
  @State totalPage: number = 1;

  aboutToAppear() {
    this.loadData();
  }

  loadData() {
    this.isLoading = true;
    getRecommendBookList(this.currentPage, DEFAULT_PAGE_SIZE)
      .then((result) => {
        this.totalPage = result.totalPage || 1;
        this.bookList = result.content || [];
      })
      .catch((err: Error) => {
        console.error('RecommendPage loadData error:', JSON.stringify(err));
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  onRefresh() {
    this.isRefreshing = true;
    this.currentPage = 1;
    getRecommendBookList(this.currentPage, DEFAULT_PAGE_SIZE)
      .then((result) => {
        this.totalPage = result.totalPage || 1;
        this.bookList = result.content || [];
      })
      .catch((err: Error) => {
        console.error('RecommendPage onRefresh error:', JSON.stringify(err));
      })
      .finally(() => {
        this.isRefreshing = false;
      });
  }

  loadMore() {
    if (this.currentPage >= this.totalPage || this.isLoading) {
      return;
    }
    this.isLoading = true;
    getRecommendBookList(this.currentPage + 1, DEFAULT_PAGE_SIZE)
      .then((result) => {
        this.currentPage++;
        this.totalPage = result.totalPage;
        this.bookList = this.bookList.concat(result.content);
      })
      .catch((err: Error) => {
        console.error('RecommendPage loadMore error:', JSON.stringify(err));
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  openBook(book: RecommendBookInfo) {
    router.pushUrl({ url: 'pages/ReaderPage', params: { bookId: book.bookId } });
  }

  getCardHeight(book: RecommendBookInfo): number {
    const descLen: number = book.description ? book.description.length : 0;
    if (descLen > 80) {
      return 320;
    } else if (descLen > 40) {
      return 280;
    }
    return 240;
  }

  @Builder
  bookCard(book: RecommendBookInfo) {
    Column() {
      Image(addHost(book.coverPic))
        .width('100%')
        .aspectRatio(0.7)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      Text(book.bookName)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ top: 8 })

      Text(book.author)
        .fontSize(12)
        .fontColor('#999999')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ top: 4 })

      if (book.description) {
        Text(book.description)
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 6 })
      }
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .onClick(() => {
      this.openBook(book);
    })
  }

  @Builder
  emptyView() {
    Column() {
      Image($r('app.media.ic_empty'))
        .width(80)
        .height(80)
        .opacity(0.5)
      Text('暂无推荐')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  loadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#00C5CD')
      Text('加载中...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      if (this.isLoading && this.bookList.length === 0) {
        this.loadingView()
      } else if (this.bookList.length === 0) {
        this.emptyView()
      } else {
        Refresh({ refreshing: this.isRefreshing }) {
          WaterFlow() {
            ForEach(this.bookList, (book: RecommendBookInfo) => {
              FlowItem() {
                this.bookCard(book)
              }
              .width('50%')
            })
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(8)
          .rowsGap(8)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .width('100%')
          .height('100%')
          .onReachEnd(() => {
            this.loadMore();
          })
        }
        .onRefreshing(() => {
          this.onRefresh();
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
