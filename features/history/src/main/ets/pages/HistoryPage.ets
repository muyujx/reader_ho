import { BookHistory, ReadingHistoryItem, addHost, secondsToTimeStr, formatDate, getStartOfMonth, getEndOfMonth } from '@ohos/common';
import { listReadingHistory } from '../api/HistoryApi';

interface DayReadingHistory {
  dayReadTime: number;
  dayReadPage: number;
  bookList: BookHistory[];
}

interface CalendarDay {
  day: number;
  dayStr: string;
  isEmpty: boolean;
  isToday: boolean;
}

@Component
export struct HistoryPage {
  @State calendarYear: number = new Date().getFullYear();
  @State calendarMonth: number = new Date().getMonth();
  @State dayMap: Map<string, DayReadingHistory> = new Map();
  @State monthReadTime: number = 0;
  @State monthReadPage: number = 0;
  @State isLoading: boolean = false;
  @State showBookList: boolean = false;
  @State selectedDayBookList: BookHistory[] = [];
  @State selectedDayStr: string = '';

  private today: Date = new Date();

  aboutToAppear() {
    this.loadHistory();
  }

  loadHistory() {
    const currentDate = new Date(this.calendarYear, this.calendarMonth, 1);
    const start = getStartOfMonth(currentDate);
    const end = getEndOfMonth(currentDate);

    this.isLoading = true;
    listReadingHistory(formatDate(start), formatDate(end))
      .then((result: ReadingHistoryItem[]) => {
        this.dayMap.clear();
        this.monthReadTime = 0;
        this.monthReadPage = 0;

        for (let i = 0; i < result.length; i++) {
          const item = result[i];
          let dayTotalTime = 0;
          let dayTotalPage = 0;

          for (let j = 0; j < item.bookList.length; j++) {
            const book = item.bookList[j];
            dayTotalTime += book.readingCost;
            dayTotalPage += (book.endPage - book.startPage + 1);
          }

          this.dayMap.set(item.dayStr, {
            dayReadTime: dayTotalTime,
            dayReadPage: dayTotalPage,
            bookList: item.bookList
          });

          this.monthReadTime += dayTotalTime;
          this.monthReadPage += dayTotalPage;
        }
      })
      .catch((err: Error | Object) => {
        console.error('loadHistory error:', JSON.stringify(err));
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  prevMonth() {
    if (this.calendarMonth === 0) {
      this.calendarYear--;
      this.calendarMonth = 11;
    } else {
      this.calendarMonth--;
    }
    this.loadHistory();
  }

  nextMonth() {
    if (this.calendarMonth === 11) {
      this.calendarYear++;
      this.calendarMonth = 0;
    } else {
      this.calendarMonth++;
    }
    this.loadHistory();
  }

  goToToday() {
    const now = new Date();
    this.calendarYear = now.getFullYear();
    this.calendarMonth = now.getMonth();
    this.loadHistory();
  }

  hasDayContent(dayStr: string): boolean {
    const day = this.dayMap.get(dayStr);
    return day != undefined && (day.dayReadPage > 0 || day.dayReadTime > 0);
  }

  getDayReadTime(dayStr: string): number {
    const day = this.dayMap.get(dayStr);
    return day ? day.dayReadTime : 0;
  }

  getDayReadPage(dayStr: string): number {
    const day = this.dayMap.get(dayStr);
    return day ? day.dayReadPage : 0;
  }

  clickDay(dayStr: string) {
    if (this.hasDayContent(dayStr)) {
      const dayData = this.dayMap.get(dayStr);
      if (dayData) {
        this.selectedDayStr = dayStr;
        this.selectedDayBookList = dayData.bookList;
        this.showBookList = true;
      }
    }
  }

  closeBookList() {
    this.showBookList = false;
  }

  getMonthTitle(): string {
    return `${this.calendarYear}年${this.calendarMonth + 1}月`;
  }

  getWeekdayHeaders(): string[] {
    return ['日', '一', '二', '三', '四', '五', '六'];
  }

  getCalendarDays(): CalendarDay[] {
    const firstDay = new Date(this.calendarYear, this.calendarMonth, 1).getDay();
    const daysInMonth = new Date(this.calendarYear, this.calendarMonth + 1, 0).getDate();
    const result: CalendarDay[] = [];
    const todayStr = `${this.today.getFullYear()}-${String(this.today.getMonth() + 1).padStart(2, '0')}-${String(this.today.getDate()).padStart(2, '0')}`;

    for (let i = 0; i < firstDay; i++) {
      result.push({ day: 0, dayStr: '', isEmpty: true, isToday: false });
    }

    for (let d = 1; d <= daysInMonth; d++) {
      const dayStr = `${this.calendarYear}-${String(this.calendarMonth + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      result.push({ day: d, dayStr: dayStr, isEmpty: false, isToday: dayStr === todayStr });
    }

    return result;
  }

  @Builder
  monthHeader() {
    Column() {
      Row() {
        Text(this.getMonthTitle())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })

      Row() {
        Button('上个月')
          .fontSize(14)
          .height(32)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .borderRadius(16)
          .onClick(() => {
            this.prevMonth();
          })

        Button('今天')
          .fontSize(14)
          .height(32)
          .fontColor('#FFFFFF')
          .backgroundColor('#00C5CD')
          .borderRadius(16)
          .margin({ left: 12, right: 12 })
          .onClick(() => {
            this.goToToday();
          })

        Button('下个月')
          .fontSize(14)
          .height(32)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .borderRadius(16)
          .onClick(() => {
            this.nextMonth();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
  }

  @Builder
  monthStats() {
    Row() {
      Column() {
        Text(secondsToTimeStr(this.monthReadTime))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#00C5CD')
        Text('本月阅读时长')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Divider()
        .width(1)
        .height(40)
        .backgroundColor('#E5E5E5')

      Column() {
        Text(`${this.monthReadPage} 页`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#00C5CD')
        Text('本月阅读页数')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  weekdayHeader() {
    Row() {
      ForEach(this.getWeekdayHeaders(), (day: string, index: number) => {
        Text(day)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(index === 0 || index === 6 ? '#FF6B6B' : '#666666')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      })
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 12, bottom: 8 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  calendarGrid() {
    Column() {
      this.weekdayHeader()

      Column() {
        ForEach(this.getCalendarRows(), (row: CalendarDay[], rowIndex: number) => {
          this.calendarRow(row, rowIndex)
        })
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding({ left: 8, right: 8, bottom: 16 })
  }

  getCalendarRows(): CalendarDay[][] {
    const days = this.getCalendarDays();
    const rows: CalendarDay[][] = [];

    for (let i = 0; i < days.length; i += 7) {
      const row = days.slice(i, i + 7);
      while (row.length < 7) {
        row.push({ day: 0, dayStr: '', isEmpty: true, isToday: false });
      }
      rows.push(row);
    }

    return rows;
  }

  @Builder
  calendarRow(row: CalendarDay[], rowIndex: number) {
    Row() {
      ForEach(row, (cell: CalendarDay, colIndex: number) => {
        if (cell.isEmpty) {
          Column()
            .layoutWeight(1)
            .height(90)
        } else {
          Column() {
            Text(`${cell.day}`)
              .fontSize(16)
              .fontWeight(cell.isToday ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(cell.isToday ? '#00C5CD' : '#333333')

            if (this.hasDayContent(cell.dayStr)) {
              Column() {
                Text(secondsToTimeStr(this.getDayReadTime(cell.dayStr)))
                  .fontSize(10)
                  .fontColor('#00C5CD')
                Text(`${this.getDayReadPage(cell.dayStr)}页`)
                  .fontSize(10)
                  .fontColor('#666666')
                  .margin({ top: 2 })
              }
              .margin({ top: 4 })
            }
          }
          .layoutWeight(1)
          .height(90)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .borderRadius(8)
          .backgroundColor(cell.isToday ? '#E0F7FA' : '#FAFAFA')
          .onClick(() => {
            this.clickDay(cell.dayStr);
          })
        }
      })
    }
    .width('100%')
  }

  @Builder
  bookListPopup() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.closeBookList();
        })

      Column() {
        Row() {
          Text(`${this.selectedDayStr}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Blank()

          Text('✕')
            .fontSize(24)
            .fontColor('#999999')
            .padding(8)
            .onClick(() => {
              this.closeBookList();
            })
        }
        .width('100%')
        .padding({ left: 20, right: 12, top: 16, bottom: 16 })

        Divider().width('100%').backgroundColor('#F0F0F0')

        List() {
          ForEach(this.selectedDayBookList, (book: BookHistory) => {
            ListItem() {
              this.bookCard(book)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12 })
      }
      .width('90%')
      .height('75%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  bookCard(book: BookHistory) {
    Row() {
      Image(addHost(book.coverPic))
        .width(80)
        .height(110)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(book.bookName)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Column() {
          Text(`阅读时长: ${secondsToTimeStr(book.readingCost)}`)
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 8 })

          Text(`阅读进度: 第${book.startPage}页 - 第${book.endPage}页`)
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 6 })

          Text(`阅读页数: ${book.endPage - book.startPage + 1}页`)
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 6 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .margin({ left: 16 })
      .height(110)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  @Builder
  emptyView() {
    Column() {
      Image($r('app.media.ic_empty'))
        .width(100)
        .height(100)
        .opacity(0.5)
      Text('本月暂无阅读记录')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack() {
      Column() {
        this.monthHeader()
        this.monthStats()
        this.calendarGrid()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

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
        .backgroundColor('rgba(255, 255, 255, 0.9)')
      }

      if (this.showBookList) {
        this.bookListPopup()
      }
    }
    .width('100%')
    .height('100%')
  }
}