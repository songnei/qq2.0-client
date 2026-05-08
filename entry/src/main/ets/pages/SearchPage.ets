import router from '@ohos.router'
import { get, Api } from './HttpRequest'

interface SearchResult {
  avatar: string
  name: string
  matchedText: string
  time: string
  isGroup: boolean
}

interface MessageSearchItem {
  avatar: string
  name: string
  message: string
  time: string
  isGroup: boolean
}

interface UserSearchData {
  id: number
  avatar: string
  nickname: string
  qqNumber: string
}

@Entry
@Component
struct SearchPage {
  @State searchKeyword: string = ''
  @State searchResults: SearchResult[] = []
  @State isSearching: boolean = false

  private messageData: MessageSearchItem[] = [
    {
      avatar: '👤',
      name: '寝',
      message: '谢文杰 物联网工程: [图片]',
      time: '03/29',
      isGroup: true
    },
    {
      avatar: '👥',
      name: '2023下半年45期入党入党积极分子',
      message: '信息工程学院党总支干事余泰安: [文件]信工入...',
      time: '2025/06/26',
      isGroup: true
    },
    {
      avatar: '📢',
      name: '公众号',
      message: '生活精选: 和平精英7周年！来这100%有礼！',
      time: '08:31',
      isGroup: false
    },
    {
      avatar: '👥',
      name: '视神明为救赎、後知後覺、华华、...',
      message: '後知後覺: [QQ小程序]揭秘Opus模型如何指挥...',
      time: '08:06',
      isGroup: true
    },
    {
      avatar: '👥',
      name: '电子2025专升本官方大群',
      message: '江卓洧18782063880/17396209872: @所有人',
      time: '昨天 22:40',
      isGroup: true
    }
  ]

  private hotSearchList: string[] = [
    'DeepSeek',
    '王者荣耀s41赛季',
    'Creme见义勇为',
    '幽灵娘',
    '开心超人',
    '浙江高速上外卖员被甩出'
  ]

  private doSearch(keyword: string): void {
    if (keyword.length === 0) {
      this.searchResults = []
      this.isSearching = false
      return
    }
    this.isSearching = true
    const results: SearchResult[] = []
    this.messageData.forEach((item: MessageSearchItem) => {
      const nameMatch = item.name.includes(keyword)
      const msgMatch = item.message.includes(keyword)
      if (nameMatch || msgMatch) {
        results.push({
          avatar: item.avatar,
          name: item.name,
          matchedText: msgMatch ? this.highlightMatch(item.message, keyword) : item.message,
          time: item.time,
          isGroup: item.isGroup
        })
      }
    })
    this.searchResults = results
    this.searchOnlineUsers(keyword)
  }

  private async searchOnlineUsers(keyword: string): Promise<void> {
    try {
      const data = await get<UserSearchData[]>(Api.USER_SEARCH + '?keyword=' + encodeURIComponent(keyword))
      const existingNames = new Set(this.searchResults.map((r: SearchResult) => r.name))
      for (let i = 0; i < data.length; i++) {
        const u = data[i]
        if (!existingNames.has(u.nickname || '')) {
          const item: SearchResult = {
            avatar: u.avatar || '👤',
            name: u.nickname || '',
            matchedText: 'QQ号: ' + (u.qqNumber || ''),
            time: '',
            isGroup: false
          }
          this.searchResults = [...this.searchResults, item]
        }
      }
    } catch (_e) {}
  }

  private highlightMatch(text: string, keyword: string): string {
    return text
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text('🔍')
            .fontSize(18)
            .margin({ left: 12 })
          TextInput({ placeholder: '搜索', text: this.searchKeyword })
            .layoutWeight(1)
            .height(36)
            .backgroundColor('transparent')
            .fontSize(16)
            .onChange((value: string) => {
              this.searchKeyword = value
              this.doSearch(value)
            })
        }
        .width('80%')
        .height(44)
        .backgroundColor('#F5F5F5')
        .borderRadius(22)

        Text('取消')
          .fontSize(16)
          .fontColor('#12B7F5')
          .margin({ left: 12 })
          .onClick(() => {
            router.back()
          })
      }
      .width('100%')
      .padding({ left: 12, right: 16, top: 16, bottom: 12 })

      if (!this.isSearching) {
        Scroll() {
          Column() {
            Text('搜索指定内容')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ left: 16, top: 16, bottom: 12 })

            Row() {
              Text('群聊')
                .fontSize(15)
                .fontColor('#333333')
              Text('聊天记录')
                .fontSize(15)
                .fontColor('#333333')
              Text('文件')
                .fontSize(15)
                .fontColor('#333333')
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
            .padding({ left: 16, right: 16, bottom: 20 })

            Divider()
              .color('#E5E5E5')

            Text('热搜')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ left: 16, top: 16, bottom: 8 })

            ForEach(this.hotSearchList, (item: string, index: number) => {
              Row() {
                Text((index + 1).toString())
                  .fontSize(14)
                  .fontColor(index < 3 ? '#FA5151' : '#999999')
                  .fontWeight(index < 3 ? FontWeight.Bold : FontWeight.Normal)
                  .width(24)
                  .textAlign(TextAlign.Center)
                Text(item)
                  .fontSize(15)
                  .fontColor('#333333')
                  .margin({ left: 12 })
                if (index === 0) {
                  Text('热')
                    .fontSize(10)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#FA5151')
                    .borderRadius(4)
                    .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                    .margin({ left: 6 })
                }
                if (index === 2) {
                  Text('新')
                    .fontSize(10)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#FFA500')
                    .borderRadius(4)
                    .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                    .margin({ left: 6 })
                }
              }
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })
            })
          }
          .width('100%')
        }
        .layoutWeight(1)
      } else {
        if (this.searchResults.length === 0) {
          Column() {
            Text('🔍')
              .fontSize(64)
              .margin({ bottom: 16 })
            Text(`未找到与"${this.searchKeyword}"相关的结果`)
              .fontSize(16)
              .fontColor('#999999')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Column() {
            Row() {
              Text(`找到 ${this.searchResults.length} 条相关结果`)
                .fontSize(13)
                .fontColor('#999999')
            }
            .width('100%')
            .padding({ left: 16, top: 12, bottom: 8 })

            List({ space: 0 }) {
              ForEach(this.searchResults, (item: SearchResult) => {
                ListItem() {
                  Row() {
                    Text(item.avatar)
                      .fontSize(32)
                      .width(44)
                      .height(44)
                      .textAlign(TextAlign.Center)
                      .backgroundColor('#F0F0F0')
                      .borderRadius(22)

                    Column() {
                      Row() {
                        Text(item.name)
                          .fontSize(16)
                          .fontColor('#333333')
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .layoutWeight(1)
                        if (item.isGroup) {
                          Text('群聊')
                            .fontSize(11)
                            .fontColor('#999999')
                            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                            .backgroundColor('#F0F0F0')
                            .borderRadius(4)
                        }
                        Text(item.time)
                          .fontSize(12)
                          .fontColor('#999999')
                          .margin({ left: 8 })
                      }
                      .width('100%')

                      Text(item.matchedText)
                        .fontSize(14)
                        .fontColor('#999999')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                    .margin({ left: 12 })
                  }
                  .width('100%')
                  .height(68)
                  .padding({ left: 16, right: 16 })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/ChatPage',
                      params: {
                        chatName: item.name,
                        chatAvatar: item.avatar,
                        isGroup: item.isGroup
                      }
                    })
                  })
                }
              })
            }
            .width('100%')
            .layoutWeight(1)
            .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 72 })
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#FFFFFF')
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
}
