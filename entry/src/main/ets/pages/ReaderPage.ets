import router from '@ohos.router';
import { addHost } from '@ohos/common';
import { getBookDetail, getBookPageList, getContents, PageItem, BookInfo, ContentsItem, updateReadingProgressApi } from '@ohos/bookshelf';
import display from '@ohos.display';
import web_webview from '@ohos.web.webview';

const COVER_PAGE = 1;
const FIRST_PAGE = 2;

@Entry
@Component
export struct ReaderPage {
  @State bookId: number = 0;
  @State bookInfo: BookInfo = {
    bookId: 0,
    bookName: '',
    author: '',
    coverPic: '',
    tagId: 0,
    favorite: false
  };
  @State curPageItem: PageItem = {
    content: '',
    title: '',
    page: 0,
    topChapter: 0
  };
  @State totalPage: number = 1;
  @State currentPage: number = 1;
  @State showContents: boolean = false;
  @State isLoading: boolean = true;
  @State touchStartX: number = 0;
  @State isSwiping: boolean = false;
  @State contents: ContentsItem[] = [];
  @State curChapterIndex: number = -1;
  private screenWidth: number = 360;
  private webController: web_webview.WebviewController = new web_webview.WebviewController();
  @State webSrc: string = '';
  private readingStartTime: number = 0;
  private readingTimer: number = -1;

  aboutToAppear() {
    try {
      const displayData = display.getDefaultDisplaySync();
      this.screenWidth = displayData.width;
    } catch (e) {
      this.screenWidth = 360;
    }
    const params = router.getParams() as Record<string, number>;
    if (params && params.bookId) {
      this.bookId = params.bookId;
      this.loadBookInfo();
      this.loadContents();
    } else {
      router.back();
    }
  }

  aboutToDisappear() {
    this.stopReadingTimerAndSave();
  }

  startReadingTimer() {
    this.readingStartTime = Date.now();
    if (this.readingTimer !== -1) {
      clearInterval(this.readingTimer);
    }
    this.readingTimer = setInterval(() => {
      // 计时器每分钟保存一次
    }, 60000);
  }

  stopReadingTimerAndSave() {
    if (this.readingTimer !== -1) {
      clearInterval(this.readingTimer);
      this.readingTimer = -1;
    }
    if (this.bookId > 0 && this.currentPage > COVER_PAGE && this.readingStartTime > 0) {
      const readingCost = Math.floor((Date.now() - this.readingStartTime) / 1000);
      if (readingCost > 0) {
        updateReadingProgressApi(this.bookId, this.currentPage, readingCost)
          .catch((err: Error) => {
            console.error('updateReadingProgressApi error:', JSON.stringify(err));
          });
      }
    }
  }

  async loadBookInfo() {
    try {
      this.bookInfo = await getBookDetail(this.bookId);
      this.totalPage = this.bookInfo.totalPage || 1;
      await this.loadPage(COVER_PAGE);
    } catch (err) {
      console.error('loadBookInfo error:', JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  async loadContents() {
    try {
      this.contents = await getContents(this.bookId);
    } catch (err) {
      console.error('loadContents error:', JSON.stringify(err));
    }
  }

  formatHtmlContent(html: string): string {
    if (!html) {
      return '';
    }
    const scale = this.screenWidth / 660;
    const head = `<meta name="viewport" content="width=660"><script>document.addEventListener('touchmove',function(e){e.preventDefault();},{passive:false});</script><style>body{margin:0;padding:0;width:660px;-webkit-transform:scale(${scale.toFixed(2)});-webkit-transform-origin:0 0;transform:scale(${scale.toFixed(2)});transform-origin:0 0;overflow-x:hidden;}</style>`;
    let result = `<!DOCTYPE html><html><head>${head}</head><body>${html}</body></html>`;
    return result.replace(/src="([^"]*)"/g, (match: string, src: string) => {
      if (!src.startsWith('data:') && !src.startsWith('http://') && !src.startsWith('https://')) {
        return `src="${addHost(src)}"`;
      }
      return match;
    });
  }

  async loadPage(page: number) {
    if (page < FIRST_PAGE && page !== COVER_PAGE) {
      page = FIRST_PAGE;
    }
    if (this.totalPage > 0 && page > this.totalPage) {
      page = this.totalPage;
    }

    if (page === this.curPageItem.page) {
      return;
    }

    if (page === COVER_PAGE) {
      this.curPageItem = {
        content: '',
        title: '封面',
        page: COVER_PAGE,
        topChapter: 0
      };
      this.currentPage = COVER_PAGE;
      this.updateCurChapter();
      this.stopReadingTimerAndSave();
      return;
    }

    try {
      const pages = await getBookPageList(this.bookId, page, 1);
      if (pages && pages.length > 0) {
        this.curPageItem = pages[0];
        this.currentPage = page;
        const newSrc = `data:text/html,${encodeURIComponent(this.formatHtmlContent(this.curPageItem.content))}`;
        this.webSrc = newSrc;
        this.updateCurChapter();
        this.startReadingTimer();
        setTimeout(() => {
          try {
            this.webController.loadUrl(newSrc);
          } catch (e) {
            console.error('loadUrl error:', JSON.stringify(e));
          }
        }, 50);
      }
    } catch (err) {
      console.error('loadPage error:', JSON.stringify(err));
    }
  }

  updateCurChapter() {
    if (this.contents.length === 0) {
      return;
    }
    for (let i = this.contents.length - 1; i >= 0; i--) {
      if (this.currentPage >= this.contents[i].startPage) {
        this.curChapterIndex = i;
        return;
      }
    }
  }

  nextPage() {
    this.saveReadingProgress();
    this.loadPage(this.currentPage + 1);
  }

  prePage() {
    this.saveReadingProgress();
    this.loadPage(this.currentPage - 1);
  }

  saveReadingProgress() {
    if (this.bookId > 0 && this.currentPage > COVER_PAGE && this.readingStartTime > 0) {
      const readingCost = Math.floor((Date.now() - this.readingStartTime) / 1000);
      if (readingCost > 0) {
        updateReadingProgressApi(this.bookId, this.currentPage, readingCost)
          .catch((err: Error) => {
            console.error('saveReadingProgress error:', JSON.stringify(err));
          });
      }
    }
    this.readingStartTime = Date.now();
  }

  toggleContents() {
    this.showContents = !this.showContents;
  }

  goToChapter(item: ContentsItem) {
    this.loadPage(item.startPage);
    this.showContents = false;
  }

  handleTouchStart(event: TouchEvent) {
    if (event.touches && event.touches.length > 0) {
      this.touchStartX = event.touches[0].x;
    }
    this.isSwiping = false;
  }

  handleTouchEnd(event: TouchEvent) {
    if (event.changedTouches && event.changedTouches.length > 0) {
      const endX = event.changedTouches[0].x;
      const diffX = endX - this.touchStartX;
      this.isSwiping = Math.abs(diffX) > 50;
      if (this.isSwiping) {
        if (diffX > 0) {
          this.prePage();
        } else {
          this.nextPage();
        }
      }
    }
  }

  @Builder
  topBar() {
    Row() {
      Text('目录')
        .fontSize(14)
        .fontColor('#00C5CD')
        .onClick(() => {
          this.toggleContents();
        })

      Blank()

      Text(this.curPageItem.title || '')
        .fontSize(14)
        .fontColor('#666666')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Blank()

      Text(`${this.currentPage} / ${this.totalPage}`)
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }

  @Builder
  coverView() {
    Column() {
      this.topBar()

      Column() {
        Image(addHost(this.bookInfo.coverPic))
          .width('80%')
          .aspectRatio(0.7)
          .objectFit(ImageFit.Contain)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  pageContent() {
    Column() {
      this.topBar()

      Web({
        src: this.webSrc,
        controller: this.webController
      })
        .width('100%')
        .layoutWeight(1)
        .onControllerAttached(() => {
          this.webController.setScrollable(false);
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  contentsPanel() {
    Column() {
      Row() {
        Text(this.bookInfo.bookName)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Text('关闭')
          .fontSize(14)
          .fontColor('#00C5CD')
          .onClick(() => {
            this.toggleContents();
          })
      }
      .width('100%')
      .padding(16)

      Divider().width('100%')

      List() {
        ForEach(this.contents, (item: ContentsItem, index: number) => {
          ListItem() {
            Row() {
              Text(item.label)
                .fontSize(14)
                .fontColor(index === this.curChapterIndex ? '#00C5CD' : '#333333')
                .fontWeight(index === 0 ? FontWeight.Bold : FontWeight.Normal)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)

              Text(`${item.startPage}`)
                .fontSize(12)
                .fontColor('#999999')
            }
            .width('100%')
            .padding({ left: 16 + item.level * 20, right: 16, top: 12, bottom: 12 })
            .onClick(() => {
              this.goToChapter(item);
            })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('80%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .position({ x: 0, y: 0 })
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.OPACITY.animation({ duration: 200 }).combine(TransitionEffect.translate({ x: -300 })),
      TransitionEffect.OPACITY.animation({ duration: 200 }).combine(TransitionEffect.translate({ x: 0 }))
    ))
  }

  build() {
    Stack() {
      if (this.isLoading) {
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
      } else {
        if (this.currentPage === COVER_PAGE) {
          this.coverView()
        } else {
          this.pageContent()
        }
      }

      if (this.showContents) {
        this.contentsPanel()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .onClick((event: ClickEvent) => {
      if (!this.isSwiping && !this.showContents) {
        this.toggleContents();
      }
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.handleTouchStart(event);
      } else if (event.type === TouchType.Up) {
        this.handleTouchEnd(event);
      }
    })
  }
}