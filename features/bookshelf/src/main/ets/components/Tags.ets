import { BookTag } from '../model/BookModel';

@Component
export struct Tags {
  @Prop tags: BookTag[] = [];
  @Prop currentTag: number = -1;
  onTagChange?: (tag: number) => void;

  build() {
    Scroll() {
      Row({ space: 8 }) {
        this.tagChip(-1, '所有')
        ForEach(this.tags, (tag: BookTag) => {
          this.tagChip(tag.id, tag.name)
        })
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(48)
  }

  @Builder
  tagChip(tagId: number, name: string) {
    Text(name)
      .fontSize(13)
      .height(32)
      .padding({ left: 14, right: 14 })
      .fontColor(this.currentTag === tagId ? '#FFFFFF' : '#666666')
      .backgroundColor(this.currentTag === tagId ? '#00C5CD' : '#F5F5F5')
      .borderRadius(16)
      .borderStyle(BorderStyle.Solid)
      .borderWidth(1)
      .borderColor(this.currentTag === tagId ? '#00C5CD' : '#E0E0E0')
      .onClick(() => {
        if (this.currentTag !== tagId && this.onTagChange !== undefined) {
          this.onTagChange(tagId);
        }
      })
  }
}
