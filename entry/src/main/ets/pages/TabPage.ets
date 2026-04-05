import { TabConstants } from '../constants/TabConstants';
import { BookShelfPage } from './BookShelfPage';
import { DiscoverPage } from './DiscoverPage';
import { HistoryPage } from './HistoryPage';
import { MinePage } from './MinePage';

@Entry
@Component
struct TabPage {
  @State currentTabIndex: number = 0;

  @Builder
  TabBuilder(icon: ResourceStr, title: string, index: number) {
    Column({ space: TabConstants.PUBLIC_SPACE }) {
      Image(icon)
        .width(TabConstants.TAB_ICON_WIDTH)
        .height(TabConstants.TAB_ICON_HEIGHT)
        .fillColor(this.currentTabIndex === index ? TabConstants.SELE_COLOR : TabConstants.DEF_COLOR)
      Text(title)
        .fontSize(12)
        .fontColor(this.currentTabIndex === index ? TabConstants.SELE_COLOR : TabConstants.DEF_COLOR)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({
      barPosition: BarPosition.End,
      index: this.currentTabIndex
    }) {
      TabContent() {
        BookShelfPage()
      }
      .tabBar(this.TabBuilder($r('app.media.ic_bookshelf'), '书架', 0))

      TabContent() {
        DiscoverPage()
      }
      .tabBar(this.TabBuilder($r('app.media.ic_discover'), '发现', 1))

      TabContent() {
        HistoryPage()
      }
      .tabBar(this.TabBuilder($r('app.media.ic_history'), '历史', 2))

      TabContent() {
        MinePage()
      }
      .tabBar(this.TabBuilder($r('app.media.ic_mine'), '我的', 3))
    }
    .barHeight(TabConstants.TAB_BAR_HEIGHT)
    .onChange((index: number) => {
      this.currentTabIndex = index;
    })
  }
}