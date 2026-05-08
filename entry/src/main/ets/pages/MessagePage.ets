import router from '@ohos.router'
import { get, post, put, del, Api } from './HttpRequest'

interface ConversationVO {
  id: number
  targetId: number
  targetType: number
  avatar: string
  name: string
  lastMsgContent: string
  lastMsgType: string
  lastMsgTime: string
  unreadCount: number
  isGroup: boolean
  isPinned: number
  isMuted: number
  isRead: number
}

interface MessageItem {
  conversationId: number
  targetId: number
  avatar: string
  name: string
  message: string
  time: string
  unread: number
  isMuted: boolean
  isGroup: boolean
  isPinned: boolean
  isRead: boolean
}

@Component
export struct MessagePage {
  @StorageProp('userStatusName') currentStatusName: string = '在线'
  @StorageProp('userNickname') userNickname: string = 'QQ用户'
  @StorageProp('userAvatar') userAvatar: string = '🐶'
  @StorageLink('chatReadConvId') @Watch('onChatRead') chatReadConvId: number = 0
  @StorageProp('msgPageRefresh') @Watch('onPageVisible') msgRefreshTrigger: number = 0

  // 关键：强制刷新标记
  @State listRefreshKey: number = 0
  @State messageList: MessageItem[] = []
  @State showMenu: boolean = false
  @State isLoading: boolean = false
  cnt: number = 0

  aboutToAppear(): void {
    this.loadConversations()
  }

  async onPageVisible(): Promise<void> {
    await this.loadConversations()
    this.onChatRead()
  }

  // 强制刷新列表UI
  private forceRefreshUI() {
    this.listRefreshKey = this.listRefreshKey + 1
  }

  private onChatRead(): void {
    const convId = this.chatReadConvId
    if (convId <= 0) return
    for (let i = 0; i < this.messageList.length; i++) {
      const m = this.messageList[i]
      if (m.conversationId === convId) {
        const copy: MessageItem = {
          conversationId: m.conversationId,
          targetId: m.targetId,
          avatar: m.avatar,
          name: m.name,
          message: m.message,
          time: m.time,
          unread: 0,
          isMuted: m.isMuted,
          isGroup: m.isGroup,
          isPinned: m.isPinned,
          isRead: true
        }
        this.messageList[i] = copy
        break
      }
    }
    let totalUnread = 0
    for (let i = 0; i < this.messageList.length; i++) {
      if (!this.messageList[i].isMuted) {
        totalUnread += this.messageList[i].unread
      }
    }
    AppStorage.setOrCreate<string>('messageBadge', totalUnread > 0 ? String(totalUnread) : '')
    AppStorage.setOrCreate<number>('chatReadConvId', 0)
    // 强制刷新UI
    this.forceRefreshUI()
  }

  async loadConversations(): Promise<void> {
    this.isLoading = true
    try {
      const list = await get<ConversationVO[]>(Api.conversationList)
      const result: MessageItem[] = []
      if (list && Array.isArray(list)) {
        for (let i = 0; i < list.length; i++) {
          const c = list[i]
          if (!c.targetId || c.targetId <= 0) continue
          const displayMsg = this.formatLastMsg(c.lastMsgContent, c.lastMsgType)
          result.push({
            conversationId: c.id,
            targetId: c.targetId,
            avatar: c.avatar || '👤',
            name: c.name || '',
            message: displayMsg,
            time: this.formatTime(c.lastMsgTime),
            unread: c.unreadCount || 0,
            isMuted: c.isMuted === 1,
            isGroup: c.isGroup === true,
            isPinned: c.isPinned === 1,
            isRead: c.isRead === 1
          })
        }
      }
      const pinned: MessageItem[] = []
      const unpinned: MessageItem[] = []
      for (let i = 0; i < result.length; i++) {
        if (result[i].isPinned) {
          pinned.push(result[i])
        } else {
          unpinned.push(result[i])
        }
      }
      this.messageList = pinned.concat(unpinned.reverse())
      let totalUnread = 0
      for (let i = 0; i < this.messageList.length; i++) {
        if (!this.messageList[i].isMuted) {
          totalUnread += this.messageList[i].unread
        }
      }
      AppStorage.setOrCreate<string>('messageBadge', totalUnread > 0 ? String(totalUnread) : '')
    } catch (_e) {
      this.messageList = []
      AppStorage.setOrCreate<string>('messageBadge', '')
    } finally {
      this.isLoading = false
    }
  }

  private refreshSortList() {
    const pinned: MessageItem[] = []
    const unpinned: MessageItem[] = []
    for (let i = 0; i < this.messageList.length; i++) {
      const item = this.messageList[i]
      if (item.isPinned) {
        pinned.push(item)
      } else {
        unpinned.push(item)
      }
    }
    this.messageList = pinned.concat(unpinned.reverse())
    // 重排后强制刷新
    this.forceRefreshUI()
  }

  private formatTime(timeStr: string): string {
    if (!timeStr) return ''
    try {
      const now = new Date()
      const date = new Date(timeStr)
      const diffMs = now.getTime() - date.getTime()
      const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))

      const hours = date.getHours().toString().padStart(2, '0')
      const minutes = date.getMinutes().toString().padStart(2, '0')

      if (diffDays === 0) {
        return hours + ':' + minutes
      } else if (diffDays === 1) {
        return '昨天 ' + hours + ':' + minutes
      } else if (diffDays < 365) {
        return (date.getMonth() + 1) + '/' + date.getDate()
      } else {
        return date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate()
      }
    } catch (_e) {
      return timeStr
    }
  }

  private formatLastMsg(content: string, msgType: string): string {
    if (!content && !msgType) return ''
    const type = msgType || 'text'
    if (type === 'text') {
      return content || ''
    } else if (type === 'image') {
      return '[图片]'
    } else if (type === 'voice') {
      return '[语音]'
    } else if (type === 'file') {
      if (content && content.length > 0) {
        return '[文件] ' + content
      }
      return '[文件]'
    } else if (type === 'video') {
      return '[视频]'
    } else if (type === 'system') {
      return content || '[系统消息]'
    }
    return content || ''
  }

  private getStatusColor(statusName: string): ResourceColor {
    if (statusName === '在线') {
      return '#4CD964'
    } else if (statusName === '离开' || statusName === '忙碌') {
      return '#FFA500'
    } else if (statusName === '请勿打扰') {
      return '#FA5151'
    } else if (statusName === '隐身') {
      return '#999999'
    }
    return '#4CD964'
  }

  async togglePin(index: number): Promise<void> {
    const item = this.messageList[index]
    try {
      await put<void>(Api.conversationPin(item.conversationId))
      // 手动新建对象赋值
      const newItem: MessageItem = {
        conversationId: item.conversationId,
        targetId: item.targetId,
        avatar: item.avatar,
        name: item.name,
        message: item.message,
        time: item.time,
        unread: item.unread,
        isMuted: item.isMuted,
        isGroup: item.isGroup,
        isPinned: !item.isPinned,
        isRead: item.isRead
      }
      this.messageList[index] = newItem
      // 重新排序
      this.refreshSortList()
    } catch (_e) {}
  }

  async toggleRead(index: number): Promise<void> {
    const item = this.messageList[index]
    try {
      await put<void>(Api.conversationRead(item.conversationId))
      const wasRead = item.isRead
      const newItem: MessageItem = {
        conversationId: item.conversationId,
        targetId: item.targetId,
        avatar: item.avatar,
        name: item.name,
        message: item.message,
        time: item.time,
        unread: wasRead ? 1 : 0,
        isMuted: item.isMuted,
        isGroup: item.isGroup,
        isPinned: item.isPinned,
        isRead: !wasRead
      }
      this.messageList[index] = newItem
      this.updateBadge(this.messageList)
      // 强制刷新UI
      this.forceRefreshUI()
    } catch (_e) {}
  }

  async deleteMessage(index: number): Promise<void> {
    try {
      const item = this.messageList[index]
      await del<void>(Api.conversationDelete(item.conversationId))
      // 直接删除原数组元素
      this.messageList.splice(index, 1)
      this.updateBadge(this.messageList)
      // 强制刷新UI
      this.forceRefreshUI()
    } catch (_e) {}
  }

  private updateBadge(list: MessageItem[]): void {
    let totalUnread = 0
    for (let i = 0; i < list.length; i++) {
      if (!list[i].isMuted) {
        totalUnread += list[i].unread
      }
    }
    AppStorage.setOrCreate<string>('messageBadge', totalUnread > 0 ? String(totalUnread) : '')
  }

  @Builder
  SwipeActions(index: number, isPinned: boolean, isRead: boolean) {
    Row() {
      Column() {
        Text(isPinned ? '取消置顶' : '置顶')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
      }
      .width(72)
      .height('100%')
      .backgroundColor('#12B7F5')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.togglePin(index)
      })

      Column() {
        Text('删除')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
      }
      .width(72)
      .height('100%')
      .backgroundColor('#FA5151')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.deleteMessage(index)
      })

      Column() {
        Text(isRead ? '标为未读' : '标为已读')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
      }
      .width(72)
      .height('100%')
      .backgroundColor('#FFA500')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.toggleRead(index)
      })
    }
    .height('100%')
  }

  build() {
    Column() {
      Row() {
        Text(this.userAvatar)
          .fontSize(40)
          .onClick(() => {
            router.pushUrl({ url: 'pages/SidebarPage' })
          })

        Column() {
          Text(this.userNickname)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .onClick(() => {
              router.pushUrl({ url: 'pages/SidebarPage' })
            })

          Row() {
            Circle()
              .width(8)
              .height(8)
              .fill(this.getStatusColor(this.currentStatusName))
            Text(this.currentStatusName)
              .fontSize(12)
              .fontColor('#999999')
              .onClick(() => {
                router.pushUrl({ url: 'pages/StatusPage' })
              })
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })

        Blank()

        Text('+')
          .fontSize(28)
          .fontColor('#333333')
          .margin({ right: 16 })
          .onClick(() => {
            this.showMenu = !this.showMenu
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 16, bottom: 12 })

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
      .onClick(() => {
        router.pushUrl({ url: 'pages/SearchPage' })
      })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#12B7F5')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.messageList.length === 0) {
        Column() {
          Text('💬')
            .fontSize(64)
          Text('暂无消息')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 关键：把刷新key绑到ForEach外层，强制重建
        List({ space: 0 }) {
          ForEach(this.messageList, (item: MessageItem, index: number) => {
            ListItem() {
              Row() {
                if (item.isPinned) {
                  Text('📌')
                    .fontSize(14)
                    .margin({ right: 4 })
                }

                Text(item.avatar)
                  .fontSize(36)
                  .margin({ left: item.isPinned ? 0 : 16 })

                Column() {
                  Row() {
                    Text(item.name)
                      .fontSize(16)
                      .fontColor(item.isRead ? '#333333' : '#000000')
                      .fontWeight(item.isRead ? FontWeight.Normal : FontWeight.Medium)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Blank()
                    Text(item.time)
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .width('100%')

                  Row() {
                    Text(item.message)
                      .fontSize(14)
                      .fontColor(item.isRead ? '#999999' : '#666666')
                      .fontWeight(item.isRead ? FontWeight.Normal : FontWeight.Medium)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .layoutWeight(1)

                    if (item.isMuted) {
                      Text('🔕')
                        .fontSize(16)
                        .margin({ right: 8 })
                    }

                    if (item.unread > 0) {
                      Text(item.unread.toString())
                        .fontSize(12)
                        .fontColor('#FFFFFF')
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .backgroundColor('#FF0000')
                        .borderRadius(10)
                    }
                  }
                  .width('100%')
                  .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 12, right: 16 })
              }
              .width('100%')
              .height(76)
            }
            .width('100%')
            .height(76)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/ChatPage',
                params: {
                  chatName: item.name,
                  chatAvatar: item.avatar,
                  isGroup: item.isGroup,
                  targetId: item.targetId.toString(),
                  conversationId: item.conversationId.toString()
                }
              })
            })
            .swipeAction({ end: this.SwipeActions(index, item.isPinned, item.isRead) })
          }, (item: MessageItem, idx: number) => String(item.conversationId) + '_' + String(this.listRefreshKey))
        }
        .width('100%')
        .layoutWeight(1)
        .margin({ top: 12 })
      }

      if (this.showMenu) {
        this.PlusMenu()
      }

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  PlusMenu() {
    Column({ space: 0 }) {
      Path()
        .width(20)
        .height(10)
        .commands('M 0 10 L 10 0 L 20 10 Z')
        .fill('#FFFFFF')
        .margin({ left: 120 })

      Column({ space: 0 }) {
        Row() {
          Text('➕')
            .fontSize(20)
          Text('创建群聊')
            .fontSize(14)
            .fontColor('#333333')
            .margin({ left: 8 })
          Blank()
          Text('›')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ right: 8 })
        }
        .width(160)
        .height(40)
        .padding({ left: 8 })
        .onClick(() => {
          this.showMenu = false
          router.pushUrl({ url: 'pages/CreateGroupPage' })
        })

        Divider()
          .color('#E5E5E5')
          .margin({ left: 44 })

        Row() {
          Text('🔗')
            .fontSize(20)
          Text('创建频道')
            .fontSize(14)
            .fontColor('#333333')
            .margin({ left: 8 })
          Blank()
          Text('›')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ right: 8 })
        }
        .width(160)
        .height(40)
        .padding({ left: 8 })

        Divider()
          .color('#E5E5E5')
          .margin({ left: 44 })

        Row() {
          Text('👥')
            .fontSize(20)
          Text('加好友/群')
            .fontSize(14)
            .fontColor('#333333')
            .margin({ left: 8 })
          Blank()
          Text('›')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ right: 8 })
        }
        .width(160)
        .height(40)
        .padding({ left: 8 })
        .onClick(() => {
          this.showMenu = false
          router.pushUrl({ url: 'pages/AddPage' })
        })

        Divider()
          .color('#E5E5E5')
          .margin({ left: 44 })

        Row() {
          Text('📷')
            .fontSize(20)
          Text('扫一扫')
            .fontSize(14)
            .fontColor('#333333')
            .margin({ left: 8 })
          Blank()
          Text('›')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ right: 8 })
        }
        .width(160)
        .height(40)
        .padding({ left: 8 })

        Divider()
          .color('#E5E5E5')
          .margin({ left: 44 })

        Row() {
          Text('📁')
            .fontSize(20)
          Text('传文件')
            .fontSize(14)
            .fontColor('#333333')
            .margin({ left: 8 })
          Blank()
          Text('›')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ right: 8 })
        }
        .width(160)
        .height(40)
        .padding({ left: 8 })

        Divider()
          .color('#E5E5E5')
          .margin({ left: 44 })

        Row() {
          Text('💰')
            .fontSize(20)
          Text('收付款')
            .fontSize(14)
            .fontColor('#333333')
            .margin({ left: 8 })
          Blank()
          Text('›')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ right: 8 })
        }
        .width(160)
        .height(40)
        .padding({ left: 8 })
      }
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 10 })
    }
    .width(160)
    .position({ x: '45%', y: 80 })
    .zIndex(100)
    .onClick(() => {
      this.showMenu = false
    })
  }
}