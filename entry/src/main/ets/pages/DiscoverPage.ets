@Component
export struct DiscoverPage {
  build() {
    Column() {
      Text('发现')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, left: 20 })

      Text('探索好书')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 100 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}