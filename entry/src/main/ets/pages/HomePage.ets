import { TabConstants } from '../constants/TabConstants';
import { BookShelfPage } from '@ohos/bookshelf';
import { FavoritePage } from '@ohos/favorite';
import { HistoryPage } from '@ohos/history';
import { MinePage } from '@ohos/mine';
import { loginStateStore, userStore } from '@ohos/common';
import { checkLoginApi, LoginPage } from '@ohos/login';

@Entry
@Component
struct HomePage {
  @State currentTabIndex: number = 0;
  @State isLoggedIn: boolean = false;
  @State isChecking: boolean = true;

  aboutToAppear() {
    this.checkLoginState();
  }

  async checkLoginState() {
    try {
      const res = await checkLoginApi();
      await userStore.saveUser({
        userId: res.userId,
        role: res.role,
        account: res.account
      });
      this.isLoggedIn = true;
      await loginStateStore.setLoginSuccess(true);
    } catch (err) {
      console.info('checkLoginState failed, need login:', JSON.stringify(err));
      await userStore.clearUser();
      this.isLoggedIn = false;
    }
    this.isChecking = false;
  }

  @Builder
  TabBuilder(normalIcon: ResourceStr, selectedIcon: ResourceStr, title: string, index: number) {
    Column({ space: TabConstants.PUBLIC_SPACE }) {
      Image(this.currentTabIndex === index ? selectedIcon : normalIcon)
        .width(TabConstants.TAB_ICON_WIDTH)
        .height(TabConstants.TAB_ICON_HEIGHT)
      Text(title)
        .fontSize(12)
        .fontColor(this.currentTabIndex === index ? TabConstants.SELE_COLOR : TabConstants.DEF_COLOR)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    if (this.isChecking) {
      Column() {
        Text('加载中...')
          .fontSize(16)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else if (!this.isLoggedIn) {
      LoginPage()
    } else {
      Tabs({
        barPosition: BarPosition.End,
        index: this.currentTabIndex
      }) {
        TabContent() {
          BookShelfPage()
        }
        .tabBar(this.TabBuilder($r('app.media.ic_bookshelf'), $r('app.media.ic_bookshelf_selected'), '书架', 0))

        TabContent() {
          FavoritePage()
        }
        .tabBar(this.TabBuilder($r('app.media.ic_favorite'), $r('app.media.ic_favorite_selected'), '收藏', 1))

        TabContent() {
          HistoryPage()
        }
        .tabBar(this.TabBuilder($r('app.media.ic_history'), $r('app.media.ic_history_selected'), '历史', 2))

        TabContent() {
          MinePage()
        }
        .tabBar(this.TabBuilder($r('app.media.ic_mine'), $r('app.media.ic_mine_selected'), '我的', 3))
      }
      .barHeight(TabConstants.TAB_BAR_HEIGHT)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
    }
  }
}