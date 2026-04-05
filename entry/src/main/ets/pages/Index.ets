@Entry
@Component
struct Index {
  @State message: string = 'Reader';

  build() {
    Column() {
      Text(this.message)
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100 })

      Text('电子书阅读器')
        .fontSize(20)
        .margin({ top: 20 })

      Blank()

      Text('框架已就绪')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 100 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}