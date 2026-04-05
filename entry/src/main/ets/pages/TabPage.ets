import router from '@ohos.router';
import { TabConstants } from '../constants/TabConstants';
import { BookShelfPage } from './BookShelfPage';
import { DiscoverPage } from './DiscoverPage';
import { HistoryPage } from './HistoryPage';
import { MinePage } from './MinePage';
import { loginStateStore } from '../utils/LoginState';
import { userStore } from '../utils/UserStore';
import { checkLoginApi } from '../api/LoginApi';

@Entry
@Component
struct TabPage {
  @State currentTabIndex: number = 0;
  @State isLoggedIn: boolean = false;
  @State isChecking: boolean = true;

  aboutToAppear() {
    this.checkLoginState();
  }

  async checkLoginState() {
    const hasLocalUser = await userStore.isLoggedIn();
    if (!hasLocalUser) {
      this.isLoggedIn = false;
      this.isChecking = false;
      return;
    }
    
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
    if (this.isChecking) {
      Column() {
        Text('加载中...')
          .fontSize(16)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else if (!this.isLoggedIn) {
      Column() {
        Text('正在跳转登录页面...')
          .fontSize(16)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .onAppear(() => {
        router.pushUrl({ url: 'pages/LoginPage' });
      })
    } else {
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
}