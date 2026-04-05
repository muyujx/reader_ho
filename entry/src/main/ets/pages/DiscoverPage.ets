import { FavoritePage } from '@ohos/bookshelf';

@Component
export struct DiscoverPage {
  build() {
    Column() {
      FavoritePage()
    }
    .width('100%')
    .height('100%')
  }
}
