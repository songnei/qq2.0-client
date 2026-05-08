import router from '@ohos.router'

interface MenuItem {
  icon: string
  title: string
  desc?: string
  hasBadge?: boolean
}

@Entry
@Component
export struct SidebarPage {
  @StorageProp('userNickname') userNickname: string = 'QQ用户'
  @StorageProp('userAvatar') userAvatar: string = '🐶'
  @StorageProp('userQq') userQq: string = ''
  @StorageProp('userStatusIcon') userStatusIcon: string = '🟢'

  private menuList: MenuItem[] = [
    {
      icon: '🖼️',
      title: '相册'
    },
    {
      icon: '⭐',
      title: '收藏'
    },
    {
      icon: '📁',
      title: '文件'
    },
    {
      icon: '💳',
      title: '钱包'
    },
    {
      icon: '🎁',
      title: '会员中心',
      desc: '领2年SVIP',
      hasBadge: true
    },
    {
      icon: '👕',
      title: '个性装扮',
      desc: '1个好友正在使用',
      hasBadge: true
    }
  ]

  build() {
    Column() {
      Stack() {
        Column() {
          Row() {
            Text('今天还没打卡哦')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('rgba(0,0,0,0.3)')
              .borderRadius(14)

            Blank()

            Row({ space: 16 }) {
              Text('😊')
                .fontSize(24)
              Text('⚙️')
                .fontSize(24)
              Text('✕')
                .fontSize(24)
                .onClick(() => {
                  router.back()
                })
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 50 })
        }
        .width('100%')
      }
      .width('100%')
      .height(180)
      .backgroundColor('#12B7F5')

      Column() {
        Row() {
          Text(this.userAvatar)
            .fontSize(56)

          Column() {
            Row() {
              Text(this.userNickname)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text('切换账号')
                .fontSize(12)
                .fontColor('#999999')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor('#F5F5F5')
                .borderRadius(10)
                .margin({ left: 8 })
            }
            .width('100%')

            Row() {
              Text(this.userQq ? ('QQ: ' + this.userQq) : '编辑个签，展示我的独特态度。')
                .fontSize(13)
                .fontColor('#999999')
                .margin({ left: 4 })
            }
            .width('100%')
            .margin({ top: 6 })

            Row({ space: 8 }) {
              Text(this.userStatusIcon)
                .fontSize(16)
              Text('☀')
                .fontSize(16)
              Text('☀')
                .fontSize(16)
              Text('☀')
                .fontSize(16)
              Text('🌙')
                .fontSize(16)
              Text('🌙')
                .fontSize(16)
              Text('⭐')
                .fontSize(16)
            }
            .margin({ top: 8 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 12 })

          Text('🔲')
            .fontSize(24)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16 })

        Row() {
          Row() {
            Text('➕')
              .fontSize(14)
            Text('添加标签')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ left: 4 })
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .border({ width: 1, color: '#E5E5E5' })
          .borderRadius(14)

          Blank()

          Row({ space: 16 }) {
            Row({ space: 4 }) {
              Text('🔔')
                .fontSize(16)
              Text('通知')
                .fontSize(13)
                .fontColor('#999999')
            }

            Row({ space: 4 }) {
              Text('👍')
                .fontSize(16)
              Text('51')
                .fontSize(13)
                .fontColor('#999999')
            }
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 16 })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')

      Divider()
        .color('#F0F0F0')
        .height(8)

      List({ space: 0 }) {
        ForEach(this.menuList, (item: MenuItem, index: number) => {
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
                  .fontSize(13)
                  .fontColor('#999999')
              }

              if (item.hasBadge) {
                Circle()
                  .width(8)
                  .height(8)
                  .fill('#FA5151')
                  .margin({ left: 8 })
              }

              Text('›')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ left: 8, right: 16 })
            }
            .width('100%')
            .height(56)
            .onClick(() => {
              if (item.title === '设置') {
                router.pushUrl({ url: 'pages/SettingsPage' })
              } else if (item.title === '相册') {
                router.pushUrl({ url: 'pages/DynamicSubPage', params: { title: '相册', icon: '🖼️' } })
              } else if (item.title === '收藏') {
                router.pushUrl({ url: 'pages/DynamicSubPage', params: { title: '收藏', icon: '⭐' } })
              } else if (item.title === '文件') {
                router.pushUrl({ url: 'pages/DynamicSubPage', params: { title: '文件', icon: '📁' } })
              } else if (item.title === '钱包') {
                router.pushUrl({ url: 'pages/DynamicSubPage', params: { title: '钱包', icon: '💳' } })
              } else if (item.title === '会员中心') {
                router.pushUrl({ url: 'pages/DynamicSubPage', params: { title: '会员中心', icon: '🎁' } })
              } else if (item.title === '个性装扮') {
                router.pushUrl({ url: 'pages/DynamicSubPage', params: { title: '个性装扮', icon: '👗' } })
              }
            })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')

      Row() {
        Column() {
          Text('⚙️')
            .fontSize(24)
          Text('设置')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => {
          router.pushUrl({ url: 'pages/SettingsPage' })
        })

        Column() {
          Text('🌙')
            .fontSize(24)
          Text('夜间')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)

        Column() {
          Text('14°')
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
          Text('郫都')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .layoutWeight(1)

        Blank()
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 24 })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
}
