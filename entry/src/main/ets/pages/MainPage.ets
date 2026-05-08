import router from '@ohos.router'
import { MessagePage } from './MessagePage'
import { ContactPage } from './ContactPage'
import { DynamicPage } from './DynamicPage'
import { ChannelPage } from './ChannelPage'
import { SidebarPage } from './SidebarPage'
import { loadUserProfile } from './GlobalState'
import { connect as connectWs } from './WsManager'

interface TabBarItem {
  icon: string
  activeIcon: string
  title: string
}

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0
  @State showSidebar: boolean = false
  @State msgTabKey: number = 0
  @StorageProp('messageBadge') messageBadge: string = ''

  aboutToAppear(): void {
    if (!AppStorage.has('userStatusName')) {
      AppStorage.setOrCreate<string>('userStatusName', '在线')
    }
    if (!AppStorage.has('userStatusIcon')) {
      AppStorage.setOrCreate<string>('userStatusIcon', '🟢')
    }
    if (!AppStorage.has('messageBadge')) {
      AppStorage.setOrCreate<string>('messageBadge', '')
    }
    AppStorage.setOrCreate<number>('msgPageRefresh', 0)
    AppStorage.setOrCreate<number>('chatReadConvId', 0)
    loadUserProfile()
    connectWs()
  }

  onPageShow(): void {
    this.msgTabKey++
    AppStorage.setOrCreate<number>('msgPageRefresh', Date.now())
  }

  private tabList: TabBarItem[] = [
    {
      icon: '📨',
      activeIcon: '📨',
      title: '消息'
    },
    {
      icon: '📺',
      activeIcon: '📺',
      title: '频道'
    },
    {
      icon: '👥',
      activeIcon: '👥',
      title: '联系人'
    },
    {
      icon: '🎯',
      activeIcon: '🎯',
      title: '动态'
    }
  ]

  @Builder
  TabBarBuilder() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        MessagePage()
      }
      .tabBar(this.TabItemBuilder(0))

      TabContent() {
        ChannelPage()
      }
      .tabBar(this.TabItemBuilder(1))

      TabContent() {
        ContactPage()
      }
      .tabBar(this.TabItemBuilder(2))

      TabContent() {
        DynamicPage()
      }
      .tabBar(this.TabItemBuilder(3))
    }
    .onChange((index: number) => {
      this.currentIndex = index
    })
    .barHeight(56)
    .barBackgroundColor('#FFFFFF')
  }

  @Builder
  TabItemBuilder(index: number) {
    Column() {
      Stack() {
        Text(this.tabList[index].icon)
          .fontSize(20)

        if (index === 0 && this.messageBadge.length > 0) {
          Text(this.messageBadge)
            .fontSize(10)
            .fontColor('#FFFFFF')
            .padding({ left: 5, right: 5, top: 1, bottom: 1 })
            .backgroundColor('#FA5151')
            .borderRadius(8)
            .position({ x: 12, y: -6 })
        }
      }

      Text(this.tabList[index].title)
        .fontSize(10)
        .fontColor(index === this.currentIndex ? '#12B7F5' : '#8C8C8C')
        .margin({ top: 2 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack() {
      Column() {
        if (this.msgTabKey >= 0) {
          this.TabBarBuilder()
        }
      }
      .width('100%')
      .height('100%')
      .gesture(
        SwipeGesture({ direction: SwipeDirection.Horizontal })
          .onAction(() => {
            this.showSidebar = true
          })
      )

      if (this.showSidebar) {
        Row() {
          SidebarPage()
            .width('85%')
            .layoutWeight(1)

          Column()
            .width('15%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.3)')
            .onClick(() => {
              this.showSidebar = false
            })
        }
        .width('100%')
        .height('100%')
        .transition({ type: TransitionType.Insert, translate: { x: -300 } })
      }
    }
    .width('100%')
    .height('100%')
  }
}
