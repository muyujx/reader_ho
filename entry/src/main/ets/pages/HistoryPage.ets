import { BookHistory, ReadingHistoryItem, addHost, secondsToTimeStr, formatDate, getStartOfMonth, getEndOfMonth } from '@ohos/common';
import { listReadingHistory } from '@ohos/bookshelf';

interface DayReadingHistory {
  dayReadTime: number;
  dayReadPage: number;
  bookList: BookHistory[];
}

interface CalendarDay {
  day: number;
  dayStr: string;
  isEmpty: boolean;
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
    return this.dayMap.has(dayStr);
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
    
    for (let i = 0; i < firstDay; i++) {
      result.push({ day: 0, dayStr: '', isEmpty: true });
    }
    
    for (let d = 1; d <= daysInMonth; d++) {
      const dayStr = `${this.calendarYear}-${String(this.calendarMonth + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      result.push({ day: d, dayStr: dayStr, isEmpty: false });
    }
    
    return result;
  }

  @Builder
  monthHeader() {
    Row() {
      Button('上个月')
        .fontSize(14)
        .height(36)
        .fontColor('#00C5CD')
        .backgroundColor('#FFFFFF')
        .borderColor('#00C5CD')
        .borderWidth(1)
        .borderRadius(18)
        .onClick(() => {
          this.prevMonth();
        })

      Text(this.getMonthTitle())
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ left: 16, right: 16 })

      Button('下个月')
        .fontSize(14)
        .height(36)
        .fontColor('#00C5CD')
        .backgroundColor('#FFFFFF')
        .borderColor('#00C5CD')
        .borderWidth(1)
        .borderRadius(18)
        .onClick(() => {
          this.nextMonth();
        })

      Button('今天')
        .fontSize(14)
        .height(36)
        .fontColor('#FFFFFF')
        .backgroundColor('#00C5CD')
        .borderRadius(18)
        .margin({ left: 8 })
        .onClick(() => {
          this.goToToday();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 12, bottom: 12 })
  }

  @Builder
  monthStats() {
    Row() {
      Column() {
        Text(secondsToTimeStr(this.monthReadTime))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#00C5CD')
        Text('本月阅读时长')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(`${this.monthReadPage} 页`)
          .fontSize(20)
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
    .padding({ left: 16, right: 16, bottom: 12 })
  }

  @Builder
  weekdayHeader() {
    Row() {
      ForEach(this.getWeekdayHeaders(), (day: string) => {
        Text(day)
          .fontSize(12)
          .fontColor('#999999')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      })
    }
    .width('100%')
    .padding({ bottom: 8 })
  }

  @Builder
  calendarGrid() {
    Column() {
      this.weekdayHeader()
      
      ForEach(this.getCalendarRows(), (row: CalendarDay[]) => {
        this.calendarRow(row)
      })
    }
    .width('100%')
    .padding({ left: 12, right: 12 })
  }

  getCalendarRows(): CalendarDay[][] {
    const days = this.getCalendarDays();
    const rows: CalendarDay[][] = [];
    
    for (let i = 0; i < days.length; i += 7) {
      const row = days.slice(i, i + 7);
      while (row.length < 7) {
        row.push({ day: 0, dayStr: '', isEmpty: true });
      }
      rows.push(row);
    }
    
    return rows;
  }

  @Builder
  calendarRow(row: CalendarDay[]) {
    Row() {
      ForEach(row, (cell: CalendarDay) => {
        if (cell.isEmpty) {
          Column()
            .layoutWeight(1)
            .height(70)
        } else {
          Column() {
            Text(`${cell.day}`)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 4 })
            
            if (this.hasDayContent(cell.dayStr)) {
              Text(secondsToTimeStr(this.getDayReadTime(cell.dayStr)))
                .fontSize(10)
                .fontColor('#00C5CD')
              Text(`${this.getDayReadPage(cell.dayStr)}页`)
                .fontSize(10)
                .fontColor('#666666')
                .margin({ top: 2 })
            }
          }
          .layoutWeight(1)
          .height(70)
          .justifyContent(FlexAlign.Center)
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
        .backgroundColor('#40000000')
        .onClick(() => {
          this.closeBookList();
        })

      Column() {
        Row() {
          Text(`${this.selectedDayStr} 阅读记录`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          
          Blank()
          
          Text('✕')
            .fontSize(20)
            .fontColor('#666666')
            .padding(8)
            .onClick(() => {
              this.closeBookList();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })

        List() {
          ForEach(this.selectedDayBookList, (book: BookHistory) => {
            ListItem() {
              this.bookListItem(book)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('90%')
      .height('70%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  bookListItem(book: BookHistory) {
    Row() {
      Image(addHost(book.coverPic))
        .width(60)
        .height(80)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      Column() {
        Text(book.bookName)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 4 })

        Text(`阅读时长: ${secondsToTimeStr(book.readingCost)}`)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 8 })

        Text(`阅读页数: ${book.startPage} - ${book.endPage} 页`)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  emptyView() {
    Column() {
      Image($r('app.media.ic_empty'))
        .width(80)
        .height(80)
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

        if (this.isLoading) {
          Column() {
            Text('加载中...')
              .fontSize(16)
              .fontColor('#999999')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.dayMap.size === 0) {
          this.emptyView()
        } else {
          this.calendarGrid()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      if (this.showBookList) {
        this.bookListPopup()
      }
    }
    .width('100%')
    .height('100%')
  }
}
