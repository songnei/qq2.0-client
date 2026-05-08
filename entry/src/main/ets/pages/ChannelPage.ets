import router from '@ohos.router'

@Component
export struct ChannelPage {
  @State isReady: boolean = false
  @State rotateAngle: number = 0
  @State scaleValue: number = 0.3
  @State opacityValue: number = 0
  @State bounceOffset: number = 50
  @State slideX: number = -300
  @State pulseScale: number = 1
  @State waveOffset: number = 0

  aboutToAppear(): void {
    setTimeout(() => {
      this.isReady = true
      animateTo({ duration: 800, curve: Curve.EaseOut }, () => {
        this.scaleValue = 1
        this.opacityValue = 1
        this.bounceOffset = 0
      })
      setTimeout(() => {
        animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
          this.slideX = 0
        })
      }, 300)
    }, 100)
  }

  startPulse(): void {
    animateTo({ duration: 1000, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate }, () => {
      this.pulseScale = 1.15
    })
  }

  startRotate(): void {
    animateTo({ duration: 3000, curve: Curve.Linear, iterations: -1 }, () => {
      this.rotateAngle = 360
    })
  }

  build() {
    Column() {
      Row() {
        Text('🐶')
          .fontSize(28)
          .margin({ left: 12 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/SidebarPage' })
          })
        Text('频道')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ top: 8 })

      Scroll() {
        Column() {
          Column() {
            Text('🎮')
              .fontSize(48)
              .width(80)
              .height(80)
              .textAlign(TextAlign.Center)
              .backgroundColor('#E8F7FE')
              .borderRadius(20)
              .rotate({ angle: this.rotateAngle })
              .onAppear(() => {
                this.startRotate()
              })
            Text('游戏中心')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ top: 12 })
            Text('发现好玩的游戏世界')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ top: 4 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 30, bottom: 30 })
          .scale({ x: this.scaleValue, y: this.scaleValue })
          .opacity(this.opacityValue)

          Row() {
            Column() {
              Text('🎵')
                .fontSize(36)
                .width(56)
                .height(56)
                .textAlign(TextAlign.Center)
                .backgroundColor('#FFF0F0')
                .borderRadius(16)
              Text('音乐')
                .fontSize(14)
                .fontColor('#333333')
                .margin({ top: 8 })
            }
            .width('25%')
            .alignItems(HorizontalAlign.Center)
            .translate({ y: this.bounceOffset })
            .opacity(this.opacityValue)

            Column() {
              Text('📺')
                .fontSize(36)
                .width(56)
                .height(56)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F0FFF0')
                .borderRadius(16)
              Text('视频')
                .fontSize(14)
                .fontColor('#333333')
                .margin({ top: 8 })
            }
            .width('25%')
            .alignItems(HorizontalAlign.Center)
            .translate({ y: this.bounceOffset })
            .opacity(this.opacityValue)

            Column() {
              Text('📰')
                .fontSize(36)
                .width(56)
                .height(56)
                .textAlign(TextAlign.Center)
                .backgroundColor('#FFF8E1')
                .borderRadius(16)
              Text('看点')
                .fontSize(14)
                .fontColor('#333333')
                .margin({ top: 8 })
            }
            .width('25%')
            .alignItems(HorizontalAlign.Center)
            .translate({ y: this.bounceOffset })
            .opacity(this.opacityValue)

            Column() {
              Text('🎙️')
                .fontSize(36)
                .width(56)
                .height(56)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F0F0FF')
                .borderRadius(16)
              Text('直播')
                .fontSize(14)
                .fontColor('#333333')
                .margin({ top: 8 })
            }
            .width('25%')
            .alignItems(HorizontalAlign.Center)
            .translate({ y: this.bounceOffset })
            .opacity(this.opacityValue)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 24 })

          Column() {
            Row() {
              Text('热门频道')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Blank()
              Text('更多 ›')
                .fontSize(13)
                .fontColor('#12B7F5')
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 12 })

            Column() {
              Row() {
                Text('🏟️')
                  .fontSize(40)
                  .width(56)
                  .height(56)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#E8F7FE')
                  .borderRadius(12)
                  .scale({ x: this.pulseScale, y: this.pulseScale })
                  .onAppear(() => {
                    this.startPulse()
                  })
                Column() {
                  Text('王者荣耀官方频道')
                    .fontSize(15)
                    .fontColor('#333333')
                  Text('12.5万人关注')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
                .layoutWeight(1)
              }
              .width('100%')
              .height(72)
              .padding({ left: 16, right: 16 })
              .translate({ x: this.slideX })
              .opacity(this.opacityValue)

              Divider().color('#F0F0F0').margin({ left: 84 })

              Row() {
                Text('🎬')
                  .fontSize(40)
                  .width(56)
                  .height(56)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#FFF0F0')
                  .borderRadius(12)
                Column() {
                  Text('B站番剧更新')
                    .fontSize(15)
                    .fontColor('#333333')
                  Text('8.3万人关注')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
                .layoutWeight(1)
              }
              .width('100%')
              .height(72)
              .padding({ left: 16, right: 16 })
              .translate({ x: this.slideX })
              .opacity(this.opacityValue)

              Divider().color('#F0F0F0').margin({ left: 84 })

              Row() {
                Text('🏀')
                  .fontSize(40)
                  .width(56)
                  .height(56)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#FFF8E1')
                  .borderRadius(12)
                Column() {
                  Text('NBA赛事频道')
                    .fontSize(15)
                    .fontColor('#333333')
                  Text('6.7万人关注')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
                .layoutWeight(1)
              }
              .width('100%')
              .height(72)
              .padding({ left: 16, right: 16 })
              .translate({ x: this.slideX })
              .opacity(this.opacityValue)
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ left: 16, right: 16 })
          }
          .width('100%')

          Column() {
            Row() {
              Text('推荐兴趣')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Blank()
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 24, bottom: 12 })

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(['编程学习', '二次元', '摄影', '追星', '运动健身', '美食分享', '旅行打卡', '读书会'], (tag: string, idx: number) => {
                Text(tag)
                  .fontSize(14)
                  .fontColor('#12B7F5')
                  .backgroundColor('#E8F7FE')
                  .borderRadius(16)
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .scale({ x: this.scaleValue, y: this.scaleValue })
                  .opacity(this.opacityValue)
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
}
