import router from '@ohos.router'

@Entry
@Component
struct Index {
  aboutToAppear() {
    setTimeout(() => {
      router.replaceUrl({ url: 'pages/LoginPage' })
    }, 500)
  }

  build() {
    Column() {
      Text('QQ')
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor('#12B7F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
  }
}