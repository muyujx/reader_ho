import { BookTag } from '../model/BookModel';

@Component
export struct TagSelector {
  @Prop tags: BookTag[] = [];
  @Prop currentTag: number = -1;
  onTagChange?: (tagId: number) => void;

  build() {
    Column() {
      Text('修改标签')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .padding({ bottom: 8 })

      Blank()

      Row({ space: 8 }) {
        ForEach(this.tags, (tag: BookTag) => {
          Text(tag.name)
            .fontSize(12)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(this.currentTag === tag.id ? '#00C5CD' : '#E0E0E0')
            .fontColor(this.currentTag === tag.id ? '#FFFFFF' : '#333333')
            .borderRadius(4)
            .onClick(() => {
              if (this.onTagChange !== undefined) {
                this.onTagChange(tag.id);
              }
            })
        })
      }
    }
    .width(120)
    .padding(10)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({
      radius: 10,
      color: '#40000000',
      offsetX: 2,
      offsetY: 2
    })
  }
}