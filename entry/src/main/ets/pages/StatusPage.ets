import router from '@ohos.router'
import { UserStatusInfo, getStatusIcon, updateStatusToServer } from './GlobalState'

interface StatusItem {
  icon: string
  name: string
  isSelected: boolean
}

@Entry
@Component
struct StatusPage {
  @StorageProp('userStatusName') currentStatusName: string = '在线'
  @StorageProp('userNickname') userNickname: string = 'QQ用户'
  @State statusList: StatusItem[] = [
    { icon: '+', name: '自定义', isSelected: false },
    { icon: '🟢', name: '在线', isSelected: true },
    { icon: '🕐', name: '离开', isSelected: false },
    { icon: '⛔', name: '忙碌', isSelected: false },
    { icon: '🚫', name: '请勿打扰', isSelected: false },
    { icon: '⚪', name: '隐身', isSelected: false },
    { icon: '😊', name: 'Q我吧', isSelected: false },
    { icon: '🔋', name: '我的电量', isSelected: false },
    { icon: '🎧', name: '听歌中', isSelected: false },
    { icon: '🐧', name: '出去浪', isSelected: false },
    { icon: '🧳', name: '去旅行', isSelected: false },
    { icon: '😵', name: '被掏空', isSelected: false },
    { icon: '🏃', name: '运动中', isSelected: false },
    { icon: '☁️', name: '今日天气', isSelected: false },
    { icon: '💗', name: '我crush了', isSelected: false },
    { icon: '🥰', name: '爱你', isSelected: false }
  ]

  aboutToAppear(): void {
    this.statusList.forEach((s) => {
      s.isSelected = s.name === this.currentStatusName
    })
  }

  build() {
    Column() {
      Stack() {
        Column() {
          Text('👧')
            .fontSize(280)
          
          Text('✏️')
            .fontSize(32)
            .margin({ top: 24 })
        }
        
        Row() {
          Text('✕')
            .fontSize(32)
            .fontColor('#FFFFFF')
            .onClick(() => {
              router.back()
            })
          
          Blank()
          
          Column() {
            Text(`${this.userNickname}正在"${this.currentStatusName}"`)
              .fontSize(14)
              .fontColor('#FFFFFF')
          }
          .padding({ left: 24, right: 24, top: 12, bottom: 12 })
          .backgroundColor('rgba(0,0,0,0.5)')
          .borderRadius(24)
          
          Blank()
          
          Text('⋯')
            .fontSize(32)
            .fontColor('#FFFFFF')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 48 })
      }
      .width('100%')
      .height(400)
      .backgroundColor('#87CEEB')

      Scroll() {
        Column() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
            ForEach(this.statusList, (item: StatusItem, index: number) => {
              Column() {
                Text(item.icon)
                  .fontSize(index === 0 ? 32 : 40)
                Text(item.name)
                  .fontSize(14)
                  .fontColor(item.isSelected ? '#FFFFFF' : '#333333')
                  .margin({ top: 8 })
              }
              .width('22%')
              .padding({ top: 20, bottom: 20 })
              .borderRadius(12)
              .backgroundColor(item.isSelected ? '#12B7F5' : '#FFFFFF')
              .margin({ left: 4, right: 4, top: 6, bottom: 6 })
              .onClick(() => {
                if (item.name === '自定义') {
                  return
                }
                this.statusList.forEach((s, i) => {
                  s.isSelected = i === index
                })
                const selectedName = item.name
                const selectedIcon = item.icon
                AppStorage.setOrCreate<string>('userStatusName', selectedName)
                AppStorage.setOrCreate<string>('userStatusIcon', selectedIcon)
                updateStatusToServer(selectedIcon, selectedName).then((success: boolean) => {
                  setTimeout(() => {
                    router.back()
                  }, 300)
                })
              })
            })
          }
          .width('100%')
          .padding(12)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}
