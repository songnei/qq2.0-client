import router from '@ohos.router'
import { get, post, Api } from './HttpRequest'
import { promptAction } from '@kit.ArkUI'

interface SearchResult {
  avatar: string
  name: string
  id: string
  userId: number
  desc: string
  type: string
}

interface FriendRequestBody {
  toUserId: number
  message: string
}

interface UserSearchApiData {
  id: number
  avatar: string
  nickname: string
  qqNumber: string
  location: string
}

interface GroupSearchApiData {
  id: number
  avatar: string
  name: string
  memberCount: number
}

@Entry
@Component
struct AddPage {
  @State searchType: number = 0
  @State searchText: string = ''
  @State searchResults: SearchResult[] = []
  @State hasSearched: boolean = false
  @State directResult: SearchResult | null = null

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      const searchId = params['searchId'] as string
      const searchName = params['searchName'] as string
      const searchAvatar = params['searchAvatar'] as string
      if (searchId !== undefined) {
        this.searchText = searchId
        this.searchType = 0
        this.directResult = {
          avatar: searchAvatar || '👤',
          name: searchName || '未知用户',
          id: searchId,
          userId: 0,
          desc: '来自：群聊',
          type: 'person'
        }
        this.hasSearched = true
      }
    }
  }

  private mockPersons: SearchResult[] = [
    { avatar: '👤', name: '张小丽', id: '987654321', userId: 0, desc: '来自：搜索添加', type: 'person' },
    { avatar: '👤', name: '刘伟', id: '555123456', userId: 0, desc: '四川 成都', type: 'person' },
    { avatar: '👤', name: '赵磊', id: '111222333', userId: 0, desc: '电子科技大学', type: 'person' }
  ]

  private mockGroups: SearchResult[] = [
    { avatar: '👥', name: '物联网2202班', id: '10086001', userId: 0, desc: '45人 · 学习交流', type: 'group' },
    { avatar: '👥', name: '计算机协会', id: '10086002', userId: 0, desc: '128人 · 技术讨论', type: 'group' },
    { avatar: '👥', name: '篮球社', id: '10086003', userId: 0, desc: '66人 · 运动健身', type: 'group' }
  ]

  async doSearch(): Promise<void> {
    this.hasSearched = true
    this.directResult = null
    if (this.searchText.trim().length === 0) {
      this.searchResults = []
      return
    }
    const keyword = this.searchText.trim()

    if (this.searchType === 0) {
      try {
        const data = await get<UserSearchApiData>(Api.USER_SEARCH + '?keyword=' + keyword)
        if (data && data.id) {
          this.searchResults = [{
            avatar: data.avatar || '👤',
            name: data.nickname || '',
            id: data.qqNumber || keyword,
            userId: data.id,
            desc: data.location || '',
            type: 'person'
          }]
        } else {
          this.searchResults = []
        }
      } catch (_e) {
        this.searchResults = []
      }
    } else {
      try {
        const data = await get<GroupSearchApiData>(Api.groupDetail(Number(keyword)))
        if (data && data.id) {
          this.searchResults = [{
            avatar: data.avatar || '👥',
            name: data.name || '',
            id: String(data.id || keyword),
            userId: 0,
            desc: (data.memberCount || 0) + '人',
            type: 'group'
          }]
        } else {
          this.searchResults = []
        }
      } catch (_e) {
        this.searchResults = []
      }
    }
  }

  async handleAddFriend(userId: number, qqNumber: string, name: string): Promise<void> {
    try {
      let targetUserId = userId
      if (!targetUserId) {
        targetUserId = await this.getUserIdByQqNumber(qqNumber)
      }
      if (!targetUserId) {
        promptAction.showToast({ message: '未找到该用户' })
        return
      }
      const body: FriendRequestBody = {
        toUserId: targetUserId,
        message: '我是' + (AppStorage.get<string>('userNickname') || '') + '，请求加为好友'
      }
      await post<void>(Api.FRIEND_REQUEST, body)
      promptAction.showToast({ message: '好友请求已发送' })
    } catch (_e) {
      promptAction.showToast({ message: '发送失败' })
    }
  }

  private async getUserIdByQqNumber(qqNumber: string): Promise<number> {
    try {
      const data = await get<UserSearchApiData>(Api.USER_SEARCH + '?keyword=' + qqNumber)
      if (data && data.id) {
        return data.id
      }
    } catch (_e) {}
    return 0
  }

  async handleJoinGroup(groupId: string): Promise<void> {
    try {
      await post<void>(Api.groupJoin(Number(groupId)))
      promptAction.showToast({ message: '已申请加入群聊' })
    } catch (_e) {
      promptAction.showToast({ message: '加入失败' })
    }
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(28)
          .fontColor('#333333')
          .onClick(() => {
            router.back()
          })
        Text('添加好友/群')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 16 })

      Row() {
        Text('查找方式')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 16 })

        Row() {
          Text('找人')
            .fontSize(14)
            .fontColor(this.searchType === 0 ? '#FFFFFF' : '#666666')
            .backgroundColor(this.searchType === 0 ? '#12B7F5' : '#F5F5F5')
            .borderRadius(16)
            .padding({ left: 20, right: 20, top: 8, bottom: 8 })
            .onClick(() => {
              this.searchType = 0
              this.searchResults = []
              this.hasSearched = false
              this.directResult = null
            })

          Text('找群')
            .fontSize(14)
            .fontColor(this.searchType === 1 ? '#FFFFFF' : '#666666')
            .backgroundColor(this.searchType === 1 ? '#12B7F5' : '#F5F5F5')
            .borderRadius(16)
            .padding({ left: 20, right: 20, top: 8, bottom: 8 })
            .margin({ left: 12 })
            .onClick(() => {
              this.searchType = 1
              this.searchResults = []
              this.hasSearched = false
              this.directResult = null
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })

      Row() {
        TextInput({ placeholder: this.searchType === 0 ? '输入QQ号/手机号搜索' : '输入群号搜索', text: this.searchText })
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .backgroundColor('#F5F5F5')
          .borderRadius(22)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.searchText = value
          })
          .onSubmit(() => {
            this.doSearch()
          })

        Text('搜索')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#12B7F5')
          .borderRadius(22)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .margin({ left: 12 })
          .onClick(() => {
            this.doSearch()
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })

      if (this.hasSearched) {
        if (this.directResult !== null) {
          Column() {
            Row() {
              Text(this.directResult!.avatar)
                .fontSize(48)
                .width(72)
                .height(72)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F0F0F0')
                .borderRadius(36)

              Column() {
                Text(this.directResult!.name)
                  .fontSize(18)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium)
                Text(`QQ: ${this.directResult!.id}`)
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 6 })
                Text(this.directResult!.desc)
                  .fontSize(13)
                  .fontColor('#CCCCCC')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 16 })
            }
            .width('100%')
            .padding({ left: 24, right: 24, top: 40 })

            Button('加好友')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#12B7F5')
              .borderRadius(24)
              .height(44)
              .width('80%')
              .margin({ top: 32 })
              .onClick(() => {
                this.handleAddFriend(this.directResult!.userId, this.directResult!.id, this.directResult!.name)
              })

            Text('发送好友申请后，等待对方通过')
              .fontSize(13)
              .fontColor('#CCCCCC')
              .margin({ top: 12 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        } else if (this.searchResults.length > 0) {
          List() {
            ForEach(this.searchResults, (item: SearchResult) => {
              ListItem() {
                Row() {
                  Text(item.avatar)
                    .fontSize(32)
                    .width(48)
                    .height(48)
                    .textAlign(TextAlign.Center)
                    .backgroundColor('#F0F0F0')
                    .borderRadius(24)

                  Column() {
                    Text(item.name)
                      .fontSize(16)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium)
                    Text(`${this.searchType === 0 ? 'QQ' : '群号'}: ${item.id}`)
                      .fontSize(13)
                      .fontColor('#999999')
                      .margin({ top: 4 })
                    Text(item.desc)
                      .fontSize(12)
                      .fontColor('#CCCCCC')
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 12 })
                  .layoutWeight(1)

                  Button(this.searchType === 0 ? '加好友' : '加群')
                    .fontSize(14)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#12B7F5')
                    .borderRadius(16)
                    .height(32)
                    .padding({ left: 16, right: 16 })
                    .onClick(() => {
                      if (this.searchType === 0) {
                        this.handleAddFriend(item.userId, item.id, item.name)
                      } else {
                        this.handleJoinGroup(item.id)
                      }
                    })
                }
                .width('100%')
                .height(80)
                .padding({ left: 16, right: 16 })
              }
            })
          }
          .width('100%')
          .margin({ top: 16 })
          .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 80 })
        } else {
          Column() {
            Text('🔍')
              .fontSize(48)
              .margin({ top: 60 })
            Text('未找到相关结果')
              .fontSize(15)
              .fontColor('#999999')
              .margin({ top: 12 })
            Text('请检查号码是否正确')
              .fontSize(13)
              .fontColor('#CCCCCC')
              .margin({ top: 6 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
      } else {
        Column() {
          Text('💡')
            .fontSize(48)
            .margin({ top: 60 })
          Text(this.searchType === 0 ? '输入QQ号或手机号查找好友' : '输入群号查找群聊')
            .fontSize(15)
            .fontColor('#999999')
            .margin({ top: 12 })
          Text('也可以通过扫描二维码添加')
            .fontSize(13)
            .fontColor('#CCCCCC')
            .margin({ top: 6 })

          Row() {
            Column() {
              Text('📷')
                .fontSize(32)
              Text('扫一扫')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 6 })
            }
            .width('25%')
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {})

            Column() {
              Text('📱')
                .fontSize(32)
              Text('手机号')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 6 })
            }
            .width('25%')
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {})

            Column() {
              Text('📋')
                .fontSize(32)
              Text('通讯录')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 6 })
            }
            .width('25%')
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {})

            Column() {
              Text('🔗')
                .fontSize(32)
              Text('链接')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 6 })
            }
            .width('25%')
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {})
          }
          .width('100%')
          .margin({ top: 32 })
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
