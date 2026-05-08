import router from '@ohos.router'

interface DynamicItem {
  icon: string
  title: string
  subtitle?: string
  hasDot?: boolean
  hasHot?: boolean
}

@Component
export struct DynamicPage {
  private dynamicItems: DynamicItem[] = [
    { icon: '⭐', title: '空间动态', subtitle: '好友最新动态' },
    { icon: '💡', title: '脑洞秀', subtitle: '创意无限' },
    { icon: '🎮', title: '游戏中心', subtitle: '热门游戏推荐', hasHot: true },
    { icon: '🕹️', title: '小游戏', subtitle: '休闲娱乐', hasHot: true },
    { icon: '🌾', title: 'QQ经典农场', subtitle: '种菜偷菜' },
    { icon: '📚', title: '小说与动漫', subtitle: '海量内容', hasDot: true }
  ]

  build() {
    Column() {
      Row() {
        Text('🐶')
          .fontSize(32)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .backgroundColor('#E8E8E8')
          .borderRadius(20)
          .onClick(() => {
            router.pushUrl({ url: 'pages/SidebarPage' })
          })
        Text('动态')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 12 })
        Blank()
        Text('🐱')
          .fontSize(22)
          .margin({ right: 16 })
        Text('🔲')
          .fontSize(22)
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      Row() {
        Text('🔍')
          .fontSize(18)
          .margin({ left: 12 })
        Text('搜索')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ left: 8 })
      }
      .width('92%')
      .height(44)
      .backgroundColor('#F5F5F5')
      .borderRadius(22)
      .margin({ top: 8 })

      List({ space: 0 }) {
        ForEach(this.dynamicItems, (item: DynamicItem) => {
          ListItem() {
            Row() {
              Text(item.icon)
                .fontSize(24)
                .width(36)
                .height(36)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F0F0F0')
                .borderRadius(8)

              Column() {
                Row() {
                  Text(item.title)
                    .fontSize(16)
                    .fontColor('#333333')
                  if (item.hasHot) {
                    Text('热')
                      .fontSize(10)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#FF9500')
                      .borderRadius(6)
                      .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                      .margin({ left: 6 })
                  }
                }

                if (item.subtitle) {
                  Text(item.subtitle!)
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 2 })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
              .layoutWeight(1)

              if (item.hasDot) {
                Circle()
                  .width(8)
                  .height(8)
                  .fill('#FA5151')
                  .margin({ right: 8 })
              }

              Text('›')
                .fontSize(16)
                .fontColor('#CCCCCC')
            }
            .width('100%')
            .height(64)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/DynamicSubPage',
                params: {
                  title: item.title,
                  icon: item.icon
                }
              })
            })
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
      .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 64 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
