import router from '@ohos.router'
import { logout } from './HttpRequest'
import { promptAction } from '@kit.ArkUI'
import { disconnect as disconnectWs } from './WsManager'

interface SettingsItem {
  icon: string
  title: string
  desc?: string
  avatar?: string
}

@Entry
@Component
export struct SettingsPage {
  private functionList: SettingsItem[] = [
    {
      icon: '🔔',
      title: '消息通知'
    },
    {
      icon: '🔲',
      title: '模式选择',
      desc: '普通模式'
    },
    {
      icon: '👕',
      title: '个性装扮与特权外显'
    },
    {
      icon: '🔧',
      title: '通用'
    }
  ]

  private privacyList: SettingsItem[] = [
    {
      icon: '🛡️',
      title: '隐私设置'
    },
    {
      icon: '📝',
      title: '个人信息收集清单'
    },
    {
      icon: '📱',
      title: '第三方个人信息共享清单'
    },
    {
      icon: '✅',
      title: '个人信息保护设置'
    }
  ]

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(24)
          .onClick(() => {
            router.back()
          })

        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 12 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16, top: 8 })

      Scroll() {
        Column() {
          Row() {
            Text('👤')
              .fontSize(24)
              .margin({ left: 16 })

            Text('账号与安全')
              .fontSize(16)
              .fontColor('#333333')
              .margin({ left: 12 })

            Blank()

            Text('🐶')
              .fontSize(28)

            Text('›')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ left: 8, right: 16 })
          }
          .width('100%')
          .height(72)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 12, right: 12, top: 12 })

          Column() {
            Text('功能')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .padding({ left: 16, top: 12, bottom: 8 })

            List({ space: 0 }) {
              ForEach(this.functionList, (item: SettingsItem, index: number) => {
                ListItem() {
                  Row() {
                    Text(item.icon)
                      .fontSize(24)
                      .margin({ left: 16 })

                    Text(item.title)
                      .fontSize(16)
                      .fontColor('#333333')
                      .margin({ left: 12 })

                    Blank()

                    if (item.desc) {
                      Text(item.desc)
                        .fontSize(14)
                        .fontColor('#999999')
                    }

                    Text('›')
                      .fontSize(16)
                      .fontColor('#999999')
                      .margin({ left: 8, right: 16 })
                  }
                  .width('100%')
                  .height(56)
                }

                if (index < this.functionList.length - 1) {
                  ListItem() {
                    Divider()
                      .color('#E5E5E5')
                      .margin({ left: 56 })
                  }
                }
              })
            }
            .width('100%')
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 12, right: 12, top: 12 })

          Column() {
            Text('隐私')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .padding({ left: 16, top: 12, bottom: 8 })

            List({ space: 0 }) {
              ForEach(this.privacyList, (item: SettingsItem, index: number) => {
                ListItem() {
                  Row() {
                    Text(item.icon)
                      .fontSize(24)
                      .margin({ left: 16 })

                    Text(item.title)
                      .fontSize(16)
                      .fontColor('#333333')
                      .margin({ left: 12 })

                    Blank()

                    Text('›')
                      .fontSize(16)
                      .fontColor('#999999')
                      .margin({ left: 8, right: 16 })
                  }
                  .width('100%')
                  .height(56)
                }

                if (index < this.privacyList.length - 1) {
                  ListItem() {
                    Divider()
                      .color('#E5E5E5')
                      .margin({ left: 56 })
                  }
                }
              })
            }
            .width('100%')
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 12, right: 12, top: 12 })

          Row() {
            Text('ℹ️')
              .fontSize(24)
              .margin({ left: 16 })

            Text('关于QQ与帮助')
              .fontSize(16)
              .fontColor('#333333')
              .margin({ left: 12 })

            Blank()

            Text('›')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ left: 8, right: 16 })
          }
          .width('100%')
          .height(56)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 12, right: 12, top: 12 })

          Row() {
            Text('🚪')
              .fontSize(24)
              .margin({ left: 16 })

            Text('退出当前账号')
              .fontSize(16)
              .fontColor('#333333')
              .margin({ left: 12 })

            Blank()

            Text('›')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ left: 8, right: 16 })
          }
          .width('100%')
          .height(56)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 12, right: 12, top: 12, bottom: 24 })
          .onClick(async () => {
            disconnectWs()
            await logout()
            AppStorage.setOrCreate<string>('userStatusName', '在线')
            AppStorage.setOrCreate<string>('userStatusIcon', '🟢')
            promptAction.showToast({ message: '已退出登录' })
            router.replaceUrl({ url: 'pages/LoginPage' })
          })
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
