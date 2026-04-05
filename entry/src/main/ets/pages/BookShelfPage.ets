import { BookShelfConstants } from '../constants/BookShelfConstants';
import { BookInfo, BookTag } from '../model/BookModel';
import { getBookInfoList, searchOnTypeApi } from '../api/BookApi';
import { getAllTag, changeBookTagApi, addFavoriteApi, delFavoriteApi } from '../api/FavoriteBookApi';
import { Tags } from '../components/Tags';
import { TagSelector } from '../components/TagSelector';

const PAGE_LIST_INDEX = 'page_list_index';
const PAGE_TAG_LOCAL = 'page_tag_local';
const PAGE_LIST_SEARCH = 'page_list_search';

const DEFAULT_FIRST_PAGE = 1;
const DEFAULT_TAG = -1;
const DEFAULT_SEARCH_STR = '';

@Component
export struct BookShelfPage {
  @State page: number = 1;
  @State pageSize: number = 18;
  @State pagerCount: number = 7;
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
  @State isLoading: boolean = false;
  @State searchSuggestions: string[] = [];
  @State searchSuggestionHighlights: string[] = [];

  aboutToAppear() {
    this.page = DEFAULT_FIRST_PAGE;
    this.tag = DEFAULT_TAG;
    this.searchText = DEFAULT_SEARCH_STR;
    this.pageSize = 18;
    this.pagerCount = 7;
    this.loadBookList(false);
    this.loadTags();
  }

  loadBookList(showLoading: boolean = true) {
    if (showLoading) {
      this.isLoading = true;
    }
    getBookInfoList(this.page, this.pageSize, this.searchText, this.tag)
      .then((result) => {
        this.totalPage = result.totalPage;
        this.bookList = result.content;
      })
      .catch((err: Error | Object) => {
        console.error('loadBookList error:', JSON.stringify(err));
      })
      .finally(() => {
        if (showLoading) {
          this.isLoading = false;
        }
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
        .then(() => {
        })
        .finally(() => {
          this.loadBookList();
        });
    } else {
      addFavoriteApi(book.bookId)
        .then(() => {
        })
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

  @Builder
  searchBar() {
    Column() {
      TextInput({ placeholder: '根据书名或作者名搜索', text: this.searchText })
        .height(40)
        .width('100%')
        .borderRadius(10)
        .backgroundColor('#FFFFFF')
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.searchText = value;
        })
        .onSubmit(() => {
          this.onSearch();
        })
    }
    .width(300)
    .height(50)
    .padding({ top: 10 })
  }

  @Builder
  bookGrid() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.bookList.length === 0) {
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
        Scroll() {
          Grid() {
            ForEach(this.bookList, (book: BookInfo) => {
              GridItem() {
                this.bookItem(book)
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
          .columnsGap(12)
          .rowsGap(20)
          .padding({ left: 12, right: 12 })
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
      }
    }
  }

  @Builder
  bookItem(book: BookInfo) {
    Column() {
      Column() {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Column() {
            Image(book.coverPic)
              .width('100%')
              .height('100%')
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          }
          .width('100%')
          .height('100%')

          Row() {
            Text(this.getTagName(book.tagId))
              .fontSize(10)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .padding({ left: 4, right: 4, top: 2, bottom: 2 })
              .backgroundColor('#FFFFFF')
              .borderRadius({ topRight: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .height(160)
        .borderRadius(8)
      }
      .width('100%')
      .height(160)

      Text(book.bookName)
        .fontSize(12)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 8 })
    }
    .width('100%')
    .onClick(() => {
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
        .margin({ top: 10 })

        Column() {
          this.bookGrid()
        }
        .layoutWeight(1)
        .width('100%')

        Row() {
          Text('上一页')
            .fontSize(14)
            .padding(8)
            .enabled(this.page > 1)
            .onClick(() => {
              this.jumpToPage(this.page - 1);
            })

          Text(`${this.page} / ${this.totalPage}`)
            .fontSize(14)
            .padding(8)

          Text('下一页')
            .fontSize(14)
            .padding(8)
            .enabled(this.page < this.totalPage)
            .onClick(() => {
              this.jumpToPage(this.page + 1);
            })
        }
        .margin({ bottom: 10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      this.tagSelectorPanel()
    }
    .width('100%')
    .height('100%')
  }
}