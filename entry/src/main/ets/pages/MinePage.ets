import { userStore, cookieStore, NeedLoginError } from '@ohos/common';
import { logoutApi } from '@ohos/login';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';

interface NavItem {
  id: string;
  title: string;
  icon: Resource;
  showArrow: boolean;
}

@Component
export struct MinePage {
  @State userAccount: string = '';
  @State totalReadTime: number = 0;
  @State totalReadPages: number = 0;
  @State totalBooks: number = 0;

  private navList: NavItem[] = [
    { id: '1', title: '阅读设置', icon: $r('app.media.ic_settings'), showArrow: true },
    { id: '2', title: '清除缓存', icon: $r('app.media.ic_clear'), showArrow: true },
    { id: '3', title: '关于', icon: $r('app.media.ic_mine'), showArrow: true },
    { id: '4', title: '退出登录', icon: $r('app.media.ic_settings'), showArrow: false }
  ];

  aboutToAppear() {
    this.loadUserInfo();
  }

  async loadUserInfo() {
    const user = await userStore.getUser();
    if (user && user.account) {
      this.userAccount = user.account;
    }
  }

  async handleNavClick(item: NavItem) {
    switch (item.id) {
      case '1':
        promptAction.openToast({ message: '阅读设置' });
        break;
      case '2':
        promptAction.openToast({ message: '清除缓存' });
        break;
      case '3':
        promptAction.openToast({ message: '关于' });
        break;
      case '4':
        this.logout();
        break;
    }
  }

  async logout() {
    try {
      await logoutApi();
    } catch (err) {
      if (err instanceof NeedLoginError) {
        console.info('logoutApi: need login, will redirect to login page');
      } else {
        console.info('logoutApi error:', JSON.stringify(err));
      }
    }
    await userStore.clearUser();
    await cookieStore.clearCookie();
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  @Builder
  header() {
    Row() {
      Text('我的')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 12 })
  }

  @Builder
  userCard() {
    Column() {
      Row({ space: 16 }) {
        Column() {
          Text(this.userAccount)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          Text('阅读爱好者')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding(16)

      Divider()
        .width('100%')
        .backgroundColor('#F0F0F0')

      Row() {
        Column() {
          Text('0')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#00C5CD')
          Text('阅读时长(小时)')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('0')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#00C5CD')
          Text('阅读页数')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('0')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#00C5CD')
          Text('阅读书籍')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ left: 16, right: 16, top: 8, bottom: 12 })
  }

  @Builder
  navItemBuilder(item: NavItem) {
    Row() {
      Row({ space: 12 }) {
        Image(item.icon)
          .width(22)
          .height(22)
          .fillColor('#00C5CD')

        Text(item.title)
          .fontSize(16)
          .fontColor(item.id === '4' ? '#FF6B6B' : '#333333')
      }

      Blank()

      if (item.showArrow) {
        Image($r('app.media.ic_arrow_right'))
          .width(16)
          .height(16)
          .fillColor('#CCCCCC')
      } else {
        Text('')
          .width(16)
          .height(16)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .onClick(() => this.handleNavClick(item))
  }

  @Builder
  navListBuilder() {
    Column() {
      ForEach(this.navList, (item: NavItem, index: number) => {
        Column() {
          this.navItemBuilder(item)

          if (index < this.navList.length - 1) {
            Divider()
              .width('100%')
              .backgroundColor('#F5F5F5')
              .margin({ left: 50 })
          }
        }
      })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .clip(true)
  }

  @Builder
  contentView() {
    Column() {
      this.userCard()

      Column() {
        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')
          .padding({ left: 16, top: 16, bottom: 8 })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ left: 16, right: 16, top: 0, bottom: 12 })
      .clip(false)
      .alignItems(HorizontalAlign.Start)

      this.navListBuilder()
    }
    .width('100%')
  }

  build() {
    Column() {
      this.header()

      Scroll() {
        Column() {
          this.contentView()
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}