import { BookTag } from '../model/BookModel';

@Component
export struct TagSelector {
  @Prop tags: BookTag[] = [];
  @Prop currentTag: number = -1;
  onTagChange?: (tag: number) => void;

  build() {
    Column() {
      Text('选择标签')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 16 })

      Column({ space: 8 }) {
        ForEach(this.tags, (tag: BookTag) => {
          Text(tag.name)
            .fontSize(14)
            .height(40)
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontColor(this.currentTag === tag.id ? '#FFFFFF' : '#333333')
            .backgroundColor(this.currentTag === tag.id ? '#00C5CD' : '#F5F5F5')
            .borderRadius(8)
            .onClick(() => {
              if (this.onTagChange !== undefined) {
                this.onTagChange(tag.id);
              }
            })
        })
      }
      .width('100%')
    }
    .width(200)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}
