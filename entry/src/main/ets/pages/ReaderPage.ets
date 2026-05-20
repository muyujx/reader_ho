import { ReaderPage as ReaderPageContent } from '@ohos/reader';

@Entry
@Component
struct ReaderPage {
  build() {
    Column() {
      ReaderPageContent()
    }
    .width('100%')
    .height('100%')
  }
}
