import { BookTag } from '../model/BookModel';

@Component
export struct Tags {
  @Prop tags: BookTag[] = [];
  @Prop currentTag: number = -1;
  onTagChange?: (tag: number) => void;

  build() {
    Column() {
      Text('书籍标签:')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#00C5CD')
        .width('100%')
        .padding({ left: 12, bottom: 6 })

      Scroll() {
        Row({ space: 6 }) {
          this.tagItem(-1, '所有')
          ForEach(this.tags, (tag: BookTag) => {
            this.tagItem(tag.id, tag.name)
          })
        }
        .padding({ left: 12, right: 12 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
  }

  @Builder
  tagItem(tagId: number, name: string) {
    Text(name)
      .fontSize(12)
      .height(28)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.currentTag === tagId ? '#00C5CD' : '#F0F0F0')
      .fontColor(this.currentTag === tagId ? '#FFFFFF' : '#333333')
      .borderRadius(4)
      .onClick(() => {
        if (this.currentTag !== tagId && this.onTagChange !== undefined) {
          this.onTagChange(tagId);
        }
      })
  }
}