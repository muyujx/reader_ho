import { BookShelfConstants } from '../constants/BookShelfConstants';

@Component
export struct BookShelfPage {
  @State searchText: string = '';
  @State selectedTag: number = -1;
  @State tags: string[] = ['全部', '小说', '科技', '历史', '文学'];
  @State bookList: string[] = [];

  @Builder
  searchBar() {
    Row() {
      Image($r('app.media.ic_search'))
        .width(20)
        .height(20)
        .fillColor('#999999')

      TextInput({ placeholder: '搜索书名或作者', text: this.searchText })
        .height(BookShelfConstants.SEARCH_HEIGHT)
        .layoutWeight(1)
        .fontSize(14)
        .backgroundColor('#F5F5F5')
        .borderRadius(BookShelfConstants.BORDER_RADIUS)
        .padding({ left: 8 })
        .onChange((value: string) => {
          this.searchText = value;
        })

      if (this.searchText.length > 0) {
        Image($r('app.media.ic_clear'))
          .width(18)
          .height(18)
          .fillColor('#999999')
          .onClick(() => {
            this.searchText = '';
          })
      }
    }
    .padding({ left: BookShelfConstants.MAIN_PADDING, right: BookShelfConstants.MAIN_PADDING })
    .height(BookShelfConstants.SEARCH_HEIGHT + 16)
  }

  @Builder
  tagBar() {
    Scroll() {
      Row({ space: BookShelfConstants.TAG_MARGIN }) {
        ForEach(this.tags, (tag: string, index: number) => {
          Text(tag)
            .fontSize(14)
            .padding({
              left: BookShelfConstants.TAG_MARGIN * 2,
              right: BookShelfConstants.TAG_MARGIN * 2,
              top: BookShelfConstants.TAG_MARGIN / 2,
              bottom: BookShelfConstants.TAG_MARGIN / 2
            })
            .backgroundColor(this.selectedTag === index ? '#00C5CD' : '#F0F0F0')
            .fontColor(this.selectedTag === index ? '#FFFFFF' : '#333333')
            .borderRadius(BookShelfConstants.TAG_HEIGHT / 2)
            .onClick(() => {
              this.selectedTag = index;
            })
        })
      }
      .padding({ left: BookShelfConstants.MAIN_PADDING, right: BookShelfConstants.MAIN_PADDING })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .height(BookShelfConstants.TAG_HEIGHT + BookShelfConstants.PUBLIC_SPACE)
    .width('100%')
  }

  @Builder
  bookGrid() {
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
        Text('点击下方按钮导入书籍')
          .fontSize(14)
          .fontColor('#CCCCCC')
          .margin({ top: 8 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      Grid() {
        ForEach(this.bookList, (book: string) => {
          GridItem() {
            Column() {
              Column()
                .width('100%')
                .height(BookShelfConstants.BOOK_COVER_HEIGHT)
                .backgroundColor('#E0E0E0')
                .borderRadius(8)

              Text(book)
                .fontSize(12)
                .margin({ top: 8 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(BookShelfConstants.PUBLIC_SPACE)
      .rowsGap(BookShelfConstants.PUBLIC_SPACE)
      .padding(BookShelfConstants.MAIN_PADDING)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  addButton() {
    Row() {
      Image($r('app.media.ic_add'))
        .width(24)
        .height(24)
        .fillColor('#FFFFFF')
      Text('导入书籍')
        .fontSize(16)
        .fontColor('#FFFFFF')
        .margin({ left: 8 })
    }
    .width('100%')
    .height(50)
    .backgroundColor('#00C5CD')
    .borderRadius(BookShelfConstants.BORDER_RADIUS)
    .justifyContent(FlexAlign.Center)
    .padding({ left: BookShelfConstants.MAIN_PADDING, right: BookShelfConstants.MAIN_PADDING })
    .onClick(() => {
    })
  }

  build() {
    Column() {
      this.searchBar()
      this.tagBar()
      this.bookGrid()
        .layoutWeight(1)
      this.addButton()
        .margin({
          left: BookShelfConstants.MAIN_PADDING,
          right: BookShelfConstants.MAIN_PADDING,
          bottom: BookShelfConstants.MAIN_PADDING
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}