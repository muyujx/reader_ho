/**
 * 推荐页面 - 双列瀑布流展示书籍列表
 * 使用 Repeat 组件实现虚拟滚动和组件复用，优化列表性能
 * 数据来源与书架页面相同 (/api/book/info/search/book)，额外展示书籍描述
 */
import { addHost } from '@ohos/common';
import { RecommendBookInfo, getRecommendBookList } from '../api/RecommendApi';
import router from '@ohos.router';
import { LengthMetrics } from '@kit.ArkUI';

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

  /** 首次加载数据 */
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

  /** 下拉刷新 - 重置到第一页 */
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

  /** 触底加载更多 - 追加下一页数据 */
  loadMore() {
    if (this.currentPage >= this.totalPage || this.isLoading) {
      return;
    }
    this.isLoading = true;
    getRecommendBookList(this.currentPage + 1, DEFAULT_PAGE_SIZE)
      .then((result) => {
        this.currentPage++;
        this.totalPage = result.totalPage;
        this.bookList = this.bookList.concat(result.content || []);
      })
      .catch((err: Error) => {
        console.error('RecommendPage loadMore error:', JSON.stringify(err));
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  /** 点击卡片跳转到阅读器 */
  openBook(book: RecommendBookInfo) {
    router.pushUrl({ url: 'pages/ReaderPage', params: { bookId: book.bookId } });
  }

  /**
   * 书籍卡片组件
   * 包含封面、书名、作者、描述
   * 高度由内容自适应，形成瀑布流效果
   */
  @Builder
  bookCard(item: RecommendBookInfo) {
    Column() {
      Image(addHost(item.coverPic))
        .width('100%')
        .aspectRatio(0.7)
        .borderRadius({ topLeft: 8, topRight: 8 })
        .objectFit(ImageFit.Cover)

      Column() {
        Text(item.bookName)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(item.author)
          .fontSize(11)
          .fontColor('#999999')
          .margin({ top: 2 })
          .width('100%')

        if (item.description) {
          Text(item.description)
            .fontSize(11)
            .fontColor('#666666')
            .lineHeight(18)
            .width('100%')
            .margin({ top: 6 })
        }
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 6, bottom: 10 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .onClick(() => {
      this.openBook(item);
    })
  }

  /** 空数据占位 */
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

  /** 加载中占位 */
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
      } else if (!this.bookList || this.bookList.length === 0) {
        this.emptyView()
      } else {
        Refresh({ refreshing: this.isRefreshing }) {
          // Repeat 虚拟滚动 + WaterFlow 瀑布流布局
          WaterFlow() {
            Repeat<RecommendBookInfo>(this.bookList)
              .each((ri: RepeatItem<RecommendBookInfo>) => {
                FlowItem() {
                  this.bookCard(ri.item)
                }
                .width('100%')
              })
              .key((item: RecommendBookInfo) => item.bookId.toString())
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(6)
          .rowsGap(6)
          .padding({ left: 6, right: 6, top: 8, bottom: 8 })
          .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(80) })
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
