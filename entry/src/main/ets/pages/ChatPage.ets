import router from '@ohos.router'
import { get, post, put, Api } from './HttpRequest'
import { promptAction } from '@kit.ArkUI'

interface ChatMessage {
  id: number
  type: string
  avatar: string
  nickname: string
  qqId?: string
  isAdmin: boolean
  content: string
  timestamp: number
  displayTime: string
  showTimeLabel: boolean
  linkTitle?: string
  linkUrl?: string
  cardTitle?: string
  cardCover?: string
  cardAuthor?: string
  voiceDuration?: number
  fileName?: string
  fileSize?: string
  isRead?: boolean
  isPinned?: boolean
  isForwarded?: boolean
  isSelf: boolean
}

interface ContextMenuItem {
  icon: string
  label: string
}

interface ImageItem {
  icon: string
  selected: boolean
}

interface EmojiItem {
  icon: string
}

interface StickerItem {
  icon: string
  name: string
}

interface MoreItem {
  icon: string
  name: string
}

interface MessageApiData {
  id: number
  senderId: number
  senderAvatar: string
  senderNickname: string
  msgType: string
  content: string
  createTime: string
  fileName: string
  fileSize: number
  isSelf: boolean
  isRecalled: number
  isForwarded: number
  isRead: number
}

interface MessagePageResult {
  total: number
  pageNum: number
  pageSize: number
  list: MessageApiData[]
}

interface SendMsgBody {
  receiverId: number
  content: string
  msgType: string
}

interface SendGroupMsgBody {
  groupId: number
  content: string
  msgType: string
}

@Entry
@Component
struct ChatPage {
  @StorageProp('userAvatar') userAvatar: string = '🐶'
  @StorageProp('userNickname') userNickname: string = ''
  @State chatName: string = '聊天'
  @State chatAvatar: string = '👤'
  @State isGroup: boolean = false
  @State targetId: string = ''
  @State conversationId: string = ''
  @State inputText: string = ''
  @State messageList: ChatMessage[] = []
  @State activePanel: string = 'none'
  @State isRecording: boolean = false
  @State recordDuration: number = 0
  @State isCancelled: boolean = false
  @State emojiTabIndex: number = 0
  @State selectedImages: boolean[] = []
  @State showContextMenu: boolean = false
  @State contextMenuMsg: ChatMessage | null = null
  @State pinnedMsg: ChatMessage | null = null
  @State showForwardPanel: boolean = false
  @State forwardMsgContent: string = ''
  @State memberCount: number = 1
  @StorageProp('msgPageRefresh') @Watch('onNewMessage') msgRefreshTrigger: number = 0

  private contextMenuItems: ContextMenuItem[] = [
    { icon: '📋', label: '复制' },
    { icon: '↗️', label: '转发' },
    { icon: '⭐', label: '收藏' },
    { icon: '📌', label: '置顶' },
    { icon: '🗑️', label: '删除' },
    { icon: '↩️', label: '撤回' }
  ]

  private forwardContacts: ChatMessage[] = [
    { id: 901, type: 'text', avatar: '👤', nickname: '谢文杰', isAdmin: false, content: '', timestamp: 0, displayTime: '', showTimeLabel: false, isSelf: false },
    { id: 902, type: 'text', avatar: '👥', nickname: '物联网2202班', isAdmin: false, content: '', timestamp: 0, displayTime: '', showTimeLabel: false, isSelf: false },
    { id: 903, type: 'text', avatar: '👤', nickname: '陈宇航', isAdmin: false, content: '', timestamp: 0, displayTime: '', showTimeLabel: false, isSelf: false }
  ]

  private messageScroller: Scroller = new Scroller()
  private recordTimer: number = -1
  private imageList: ImageItem[] = []
  private pollTimer: number = 0
  private recentEmojiList: EmojiItem[] = [
    { icon: '😀' }, { icon: '😂' }, { icon: '😍' }, { icon: '🥰' },
    { icon: '😎' }, { icon: '🤔' }, { icon: '😭' }, { icon: '😤' },
    { icon: '🤗' }, { icon: '😴' }, { icon: '🤮' }, { icon: '🥶' }
  ]
  private emojiList: EmojiItem[] = [
    { icon: '😀' }, { icon: '😃' }, { icon: '😄' }, { icon: '😁' },
    { icon: '😆' }, { icon: '😅' }, { icon: '🤣' }, { icon: '😂' },
    { icon: '🙂' }, { icon: '🙃' }, { icon: '😉' }, { icon: '😊' },
    { icon: '😇' }, { icon: '🥰' }, { icon: '😍' }, { icon: '🤩' },
    { icon: '😘' }, { icon: '😗' }, { icon: '😚' }, { icon: '😙' },
    { icon: '🥲' }, { icon: '😋' }, { icon: '😛' }, { icon: '😜' },
    { icon: '🤪' }, { icon: '😝' }, { icon: '🤑' }, { icon: '🤗' },
    { icon: '🤭' }, { icon: '🤫' }, { icon: '🤔' }, { icon: '🫡' },
    { icon: '🤐' }, { icon: '🤨' }, { icon: '😐' }, { icon: '😑' },
    { icon: '😶' }, { icon: '🫥' }, { icon: '😏' }, { icon: '😒' },
    { icon: '🙄' }, { icon: '😬' }, { icon: '🤥' }, { icon: '😌' },
    { icon: '😔' }, { icon: '😪' }, { icon: '🤤' }, { icon: '😴' },
    { icon: '😷' }, { icon: '🤒' }, { icon: '🤕' }, { icon: '🤢' },
    { icon: '🤮' }, { icon: '🥵' }, { icon: '🥶' }, { icon: '🥴' },
    { icon: '😵' }, { icon: '🤯' }, { icon: '🤠' }, { icon: '🥳' },
    { icon: '🥸' }, { icon: '😎' }, { icon: '🤓' }, { icon: '🧐' },
    { icon: '😕' }, { icon: '🫤' }, { icon: '😟' }, { icon: '🙁' },
    { icon: '😮' }, { icon: '😯' }, { icon: '😲' }, { icon: '😳' },
    { icon: '🥺' }, { icon: '🥹' }, { icon: '😦' }, { icon: '😧' },
    { icon: '😨' }, { icon: '😰' }, { icon: '😥' }, { icon: '😢' },
    { icon: '😭' }, { icon: '😱' }, { icon: '😖' }, { icon: '😣' },
    { icon: '😞' }, { icon: '😓' }, { icon: '😩' }, { icon: '😫' },
    { icon: '🥱' }, { icon: '😤' }, { icon: '😡' }, { icon: '😠' }
  ]
  private stickerList: StickerItem[] = [
    { icon: '🐶', name: '小狗' }, { icon: '🐱', name: '小猫' },
    { icon: '🐭', name: '老鼠' }, { icon: '🐹', name: '仓鼠' },
    { icon: '🐰', name: '兔子' }, { icon: '🦊', name: '狐狸' },
    { icon: '🐻', name: '小熊' }, { icon: '🐼', name: '熊猫' },
    { icon: '🐨', name: '考拉' }, { icon: '🐯', name: '老虎' },
    { icon: '🦁', name: '狮子' }, { icon: '🐮', name: '牛牛' },
    { icon: '🐷', name: '小猪' }, { icon: '🐸', name: '青蛙' },
    { icon: '🐵', name: '猴子' }, { icon: '🐔', name: '小鸡' }
  ]
  private moreItems: MoreItem[] = [
    { icon: '📁', name: '文件' },
    { icon: '🧧', name: '红包' },
    { icon: '💸', name: '转账' },
    { icon: '📍', name: '位置' },
    { icon: '👤', name: '名片' },
    { icon: '🎵', name: '音乐' },
    { icon: '🗳️', name: '群投票' },
    { icon: '🔗', name: '接龙' },
    { icon: '✅', name: '签到' }
  ]

  private friendQqIds: string[] = [
    '123456789',
    '18384529872',
    '987654321',
    '111222333',
    '555666777',
    '888999000',
    '222333444',
    '666777888'
  ]

  private isFriend(qqId: string): boolean {
    for (let i = 0; i < this.friendQqIds.length; i++) {
      if (this.friendQqIds[i] === qqId) {
        return true
      }
    }
    return false
  }

  private handleAvatarClick(msg: ChatMessage): void {
    if (msg.isSelf) {
      return
    }
    const qqId = msg.qqId || ''
    if (this.isFriend(qqId)) {
      router.pushUrl({
        url: 'pages/ContactDetailPage',
        params: {
          contactName: msg.nickname,
          contactAvatar: msg.avatar,
          isOnline: true,
          isFriend: true
        }
      })
    } else {
      router.pushUrl({
        url: 'pages/AddPage',
        params: {
          searchId: qqId,
          searchName: msg.nickname,
          searchAvatar: msg.avatar
        }
      })
    }
  }

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      if (params['chatName'] !== undefined) {
        this.chatName = params['chatName'] as string
      }
      if (params['chatAvatar'] !== undefined) {
        this.chatAvatar = params['chatAvatar'] as string
      }
      if (params['isGroup'] !== undefined) {
        this.isGroup = params['isGroup'] as boolean
      }
      if (params['targetId'] !== undefined) {
        this.targetId = params['targetId'] as string
      }
      if (params['conversationId'] !== undefined) {
        this.conversationId = params['conversationId'] as string
      }
    }
    this.initImages()
    this.loadMessages()
    this.markAsRead()
    if (this.isGroup && this.targetId.length > 0 && Number(this.targetId) > 0) {
      this.loadMemberCount()
    }
    // this.startPollReadStatus()
  }

  onNewMessage(): void {
    if (this.targetId.length > 0 && Number(this.targetId) > 0) {
      this.loadMessages()
      this.markAsRead()
    }
  }

  // private startPollReadStatus(): void {
  //   if (this.isGroup) return
  //   this.pollTimer = setInterval(() => {
  //     this.pollReadStatus()
  //   }, 8000)
  // }

  // private async pollReadStatus(): Promise<void> {
  //   try {
  //     if (!this.targetId || this.isGroup) return
  //     const url = Api.MSG_HISTORY + '?targetId=' + this.targetId + '&targetType=1&pageNum=1&pageSize=50'
  //     const pageData = await get<MessagePageResult>(url)
  //     if (!pageData || !pageData.list) return
  //     const serverList = pageData.list
  //     let changed = false
  //     const newList: ChatMessage[] = []
  //     for (let i = 0; i < this.messageList.length; i++) {
  //       const local = this.messageList[i]
  //       if (local.isSelf) {
  //         let serverRead = local.isRead
  //         for (let j = 0; j < serverList.length; j++) {
  //           if (serverList[j].id === local.id) {
  //             if (serverList[j].isRead === 1 && !local.isRead) {
  //               serverRead = true
  //               changed = true
  //             }
  //             break
  //           }
  //         }
  //         newList.push({
  //           id: local.id, type: local.type, avatar: local.avatar, nickname: local.nickname,
  //           qqId: local.qqId, isAdmin: local.isAdmin, content: local.content,
  //           timestamp: local.timestamp, displayTime: local.displayTime, showTimeLabel: local.showTimeLabel,
  //           linkTitle: local.linkTitle, linkUrl: local.linkUrl, cardTitle: local.cardTitle,
  //           cardCover: local.cardCover, cardAuthor: local.cardAuthor, voiceDuration: local.voiceDuration,
  //           fileName: local.fileName, fileSize: local.fileSize, isRead: serverRead,
  //           isPinned: local.isPinned, isForwarded: local.isForwarded, isSelf: local.isSelf
  //         })
  //       } else {
  //         newList.push(local)
  //       }
  //     }
  //     if (changed) {
  //       this.messageList = newList
  //     }
  //   } catch (_e) {
  //   }
  // }

  private async markAsRead(): Promise<void> {
    try {
      if (!this.targetId || Number(this.targetId) <= 0) return
      const convId = Number(this.conversationId)
      if (convId > 0) {
        AppStorage.setOrCreate<number>('chatReadConvId', convId)
      }
      const targetType = this.isGroup ? 2 : 1
      await put<void>(Api.MSG_MARK_READ + '?targetId=' + this.targetId + '&targetType=' + targetType)
    } catch (_e) {
    }
  }

  async loadMessages(): Promise<void> {
    try {
      let url = Api.MSG_HISTORY + '?pageSize=50'
      if (this.isGroup) {
        if (!this.targetId || Number(this.targetId) <= 0) return
        url += '&targetId=' + this.targetId + '&targetType=2'
      } else if (this.targetId) {
        url += '&targetId=' + this.targetId + '&targetType=1'
      } else {
        return
      }
      const pageData = await get<MessagePageResult>(url)
      if (pageData && pageData.list && Array.isArray(pageData.list) && pageData.list.length > 0) {
        const data = pageData.list
        const result: ChatMessage[] = []
        for (let i = 0; i < data.length; i++) {
          const m = data[i]
          if (m.isRecalled === 1) continue
          const msgType = m.msgType || 'text'
          let type = 'text'
          if (msgType === '1' || msgType === 'image') type = 'image'
          else if (msgType === '2' || msgType === 'voice') type = 'voice'
          else if (msgType === '3' || msgType === 'file') type = 'file'
          else if (msgType === '4' || msgType === 'video') type = 'video'

          result.push({
            id: m.id || i,
            type: type,
            avatar: m.isSelf ? this.userAvatar : (m.senderAvatar || '👤'),
            nickname: m.isSelf ? (this.userNickname || '我') : (m.senderNickname || ''),
            isAdmin: false,
            content: m.content || '',
            timestamp: new Date(m.createTime || Date.now()).getTime(),
            displayTime: '',
            showTimeLabel: false,
            fileName: m.fileName || undefined,
            fileSize: m.fileSize ? String(m.fileSize) : undefined,
            isSelf: m.isSelf === true,
            isRead: m.isRead === 1
          })
        }
        this.messageList = result
        this.calculateTimeLabels()
        setTimeout(() => {
          this.scrollToBottom()
        }, 100)
      } else {
        this.initMessages()
        this.calculateTimeLabels()
        setTimeout(() => {
          this.scrollToBottom()
        }, 100)
      }
    } catch (_e) {
      this.initMessages()
      this.calculateTimeLabels()
      setTimeout(() => {
        this.scrollToBottom()
      }, 100)
    }
  }

  aboutToDisappear(): void {
    this.stopRecordTimer()
    // if (this.pollTimer > 0) {
    //   clearInterval(this.pollTimer)
    //   this.pollTimer = 0
    // }
  }

  private initImages(): void {
    const icons: string[] = [
      '🌅', '🌄', '🏔️', '🌊', '🌸', '🌺', '🌻', '🌹',
      '🍕', '🍔', '🎂', '🍰', '☕', '🍵', '🥤', '🍺',
      '🚗', '✈️', '🚀', '🏠', '🎭', '🎪', '🎨', '🎬'
    ]
    this.imageList = []
    this.selectedImages = []
    for (let i = 0; i < icons.length; i++) {
      this.imageList.push({ icon: icons[i], selected: false })
      this.selectedImages.push(false)
    }
  }

  private toggleImage(index: number): void {
    const newList: ImageItem[] = []
    for (let i = 0; i < this.imageList.length; i++) {
      const item = this.imageList[i]
      if (i === index) {
        newList.push({ icon: item.icon, selected: !item.selected })
      } else {
        newList.push({ icon: item.icon, selected: item.selected })
      }
    }
    this.imageList = newList
    const newSelected: boolean[] = []
    for (let i = 0; i < this.selectedImages.length; i++) {
      if (i === index) {
        newSelected.push(!this.selectedImages[i])
      } else {
        newSelected.push(this.selectedImages[i])
      }
    }
    this.selectedImages = newSelected
  }

  private getSelectedImageCount(): number {
    let count = 0
    for (let i = 0; i < this.selectedImages.length; i++) {
      if (this.selectedImages[i]) {
        count++
      }
    }
    return count
  }

  private switchPanel(panel: string): void {
    if (this.activePanel === panel) {
      this.activePanel = 'none'
    } else {
      this.activePanel = panel
    }
  }

  private startRecord(): void {
    this.isRecording = true
    this.isCancelled = false
    this.recordDuration = 0
    this.recordTimer = setInterval(() => {
      this.recordDuration++
      if (this.recordDuration >= 60) {
        this.finishRecord()
      }
    }, 1000) as number
  }

  private finishRecord(): void {
    this.stopRecordTimer()
    if (this.isCancelled) {
      this.isRecording = false
      this.isCancelled = false
      return
    }
    if (this.recordDuration > 0) {
      const newMsg: ChatMessage = {
        id: this.messageList.length + 1,
        type: 'voice',
        avatar: this.userAvatar,
        nickname: this.userNickname || '我',
        isAdmin: false,
        content: '',
        timestamp: Date.now(),
        displayTime: '',
        showTimeLabel: false,
        voiceDuration: this.recordDuration,
        isSelf: true
      }
      this.messageList = [...this.messageList, newMsg]
      this.calculateTimeLabels()
      this.scrollToBottom()
    }
    this.isRecording = false
    this.recordDuration = 0
  }

  private cancelRecord(): void {
    this.isCancelled = true
    this.stopRecordTimer()
    this.isRecording = false
    this.recordDuration = 0
  }

  private stopRecordTimer(): void {
    if (this.recordTimer !== -1) {
      clearInterval(this.recordTimer)
      this.recordTimer = -1
    }
  }

  private sendSelectedImages(): void {
    let sent = false
    for (let i = 0; i < this.imageList.length; i++) {
      if (this.selectedImages[i]) {
        const newMsg: ChatMessage = {
          id: this.messageList.length + 1,
          type: 'image',
          avatar: this.userAvatar,
          nickname: this.userNickname || '我',
          isAdmin: false,
          content: this.imageList[i].icon,
          timestamp: Date.now(),
          displayTime: '',
          showTimeLabel: false,
          isSelf: true
        }
        this.messageList = [...this.messageList, newMsg]
        sent = true
      }
    }
    if (sent) {
      this.calculateTimeLabels()
      this.scrollToBottom()
      this.initImages()
      this.activePanel = 'none'
    }
  }

  private sendEmoji(icon: string): void {
    const newMsg: ChatMessage = {
      id: this.messageList.length + 1,
      type: 'text',
      avatar: this.userAvatar,
      nickname: this.userNickname || '我',
      isAdmin: false,
      content: icon,
      timestamp: Date.now(),
      displayTime: '',
      showTimeLabel: false,
      isSelf: true
    }
    this.messageList = [...this.messageList, newMsg]
    this.calculateTimeLabels()
    this.scrollToBottom()
  }

  private sendSticker(icon: string): void {
    const newMsg: ChatMessage = {
      id: this.messageList.length + 1,
      type: 'sticker',
      avatar: this.userAvatar,
      nickname: this.userNickname || '我',
      isAdmin: false,
      content: icon,
      timestamp: Date.now(),
      displayTime: '',
      showTimeLabel: false,
      isSelf: true
    }
    this.messageList = [...this.messageList, newMsg]
    this.calculateTimeLabels()
    this.scrollToBottom()
  }

  private handleMoreItem(name: string): void {
    let content = ''
    if (name === '文件') {
      content = '[文件] 文档.pdf'
    } else if (name === '红包') {
      content = '[红包] 恭喜发财'
    } else if (name === '转账') {
      content = '[转账] ¥88.88'
    } else if (name === '位置') {
      content = '[位置] 电子科技大学成都学院'
    } else if (name === '名片') {
      content = '[名片] 谢文杰的名片'
    } else if (name === '音乐') {
      content = '[音乐] 晴天 - 周杰伦'
    } else if (name === '群投票') {
      content = '[群投票] 今晚吃什么？'
    } else if (name === '接龙') {
      content = '[接龙] 周末聚餐报名'
    } else if (name === '签到') {
      content = '签到成功 ✅'
    }
    if (content.length > 0) {
      const newMsg: ChatMessage = {
        id: this.messageList.length + 1,
        type: 'text',
        avatar: this.userAvatar,
        nickname: this.userNickname || '我',
        isAdmin: false,
        content: content,
        timestamp: Date.now(),
        displayTime: '',
        showTimeLabel: false,
        isSelf: true
      }
      this.messageList = [...this.messageList, newMsg]
      this.calculateTimeLabels()
      this.scrollToBottom()
      this.activePanel = 'none'
    }
  }

  private initMessages(): void {
    const baseTime = Date.now()
    const minute = 60 * 1000
    const hour = 60 * minute
    const day = 24 * hour

      this.messageList = []
    }

    private calculateTimeLabels(): void {
      if (this.messageList.length === 0) {
      return
    }
    const todayStart = new Date()
    todayStart.setHours(0, 0, 0, 0)
    const todayTimestamp = todayStart.getTime()
    const yesterdayTimestamp = todayTimestamp - 24 * 60 * 60 * 1000
    const fiveMinutes = 5 * 60 * 1000

    const newList: ChatMessage[] = []
    for (let i = 0; i < this.messageList.length; i++) {
      const msg = this.messageList[i]
      const ts = msg.timestamp
      const date = new Date(ts)
      const hours = date.getHours()
      const minutes = date.getMinutes()
      const hStr = hours < 10 ? '0' + String(hours) : String(hours)
      const mStr = minutes < 10 ? '0' + String(minutes) : String(minutes)
      const timeStr = hStr + ':' + mStr

      let displayTime = ''
      if (ts >= todayTimestamp) {
        displayTime = timeStr
      } else if (ts >= yesterdayTimestamp) {
        displayTime = '昨天 ' + timeStr
      } else {
        const month = date.getMonth() + 1
        const day = date.getDate()
        displayTime = String(month) + '月' + String(day) + '日 ' + timeStr
      }

      let showTimeLabel = false
      if (i === 0) {
        showTimeLabel = true
      } else {
        const prevMsg = this.messageList[i - 1]
        const timeDiff = msg.timestamp - prevMsg.timestamp
        const prevDate = new Date(prevMsg.timestamp)
        const currDate = new Date(msg.timestamp)
        const isSameDay = prevDate.getFullYear() === currDate.getFullYear() &&
          prevDate.getMonth() === currDate.getMonth() &&
          prevDate.getDate() === currDate.getDate()

        if (!isSameDay) {
          showTimeLabel = true
        } else if (timeDiff >= fiveMinutes) {
          showTimeLabel = true
        } else {
          showTimeLabel = false
        }
      }

      newList.push({
        id: msg.id, type: msg.type, avatar: msg.avatar, nickname: msg.nickname,
        qqId: msg.qqId, isAdmin: msg.isAdmin, content: msg.content,
        timestamp: msg.timestamp, displayTime: displayTime, showTimeLabel: showTimeLabel,
        linkTitle: msg.linkTitle, linkUrl: msg.linkUrl, cardTitle: msg.cardTitle,
        cardCover: msg.cardCover, cardAuthor: msg.cardAuthor, voiceDuration: msg.voiceDuration,
        fileName: msg.fileName, fileSize: msg.fileSize, isRead: msg.isRead,
        isPinned: msg.isPinned, isForwarded: msg.isForwarded, isSelf: msg.isSelf
      })
    }
    this.messageList = newList
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('‹')
            .fontSize(32)
            .fontColor('#333333')
            .onClick(() => {
              router.back()
            })

          Column() {
            Text(this.chatName)
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            if (this.isGroup) {
              Text(`(${this.getMemberCount()}人)`)
                .fontSize(12)
                .fontColor('#999999')
            }
          }
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)

          Text('⋯')
            .fontSize(28)
            .fontColor('#333333')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/ChatInfoPage',
                params: {
                  chatName: this.chatName,
                  chatAvatar: this.chatAvatar,
                  isGroup: this.isGroup,
                  targetId: this.targetId
                }
              })
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 12, right: 16 })
        .backgroundColor('#FFFFFF')

        if (this.pinnedMsg !== null) {
          Row() {
            Text('📌')
              .fontSize(14)
              .margin({ right: 6 })
            Text(this.pinnedMsg!.content)
              .fontSize(13)
              .fontColor('#333333')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
            Text('✕')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ left: 8 })
              .onClick(() => {
                this.pinnedMsg = null
              })
          }
          .width('100%')
          .height(36)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFF8E1')
        }

        List({ space: 4, scroller: this.messageScroller }) {
          ForEach(this.messageList, (msg: ChatMessage) => {
            if (msg.showTimeLabel) {
              ListItem() {
                Row() {
                  Text(msg.displayTime)
                    .fontSize(12)
                    .fontColor('#999999')
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .backgroundColor('#E0E0E0')
                    .borderRadius(10)
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .padding({ top: 12, bottom: 4 })
              }
            }

            ListItem() {
              Row() {
                if (msg.isSelf) {
                  Blank()
                    .width(48)

                  Column() {
                    if (this.isGroup) {
                      Row() {
                        Blank()
                        Text(msg.nickname)
                          .fontSize(13)
                          .fontColor('#999999')
                      }
                      .width('100%')
                    }

                    Row() {
                      Blank()
                      this.MessageBubble(msg)
                    }
                    .width('100%')
                  }
                  .alignItems(HorizontalAlign.End)
                  .layoutWeight(1)

                  Text(msg.avatar)
                    .fontSize(40)
                    .margin({ left: 8 })
                } else {
                  Text(msg.avatar)
                    .fontSize(40)
                    .margin({ right: 8 })
                    .onClick(() => {
                      if (this.isGroup) {
                        this.handleAvatarClick(msg)
                      }
                    })

                  Column() {
                    if (this.isGroup) {
                      Row() {
                        Text(msg.nickname)
                          .fontSize(13)
                          .fontColor('#333333')
                        if (msg.isAdmin) {
                          Text('管理员')
                            .fontSize(10)
                            .fontColor('#FFFFFF')
                            .backgroundColor('#4CD964')
                            .borderRadius(4)
                            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                            .margin({ left: 6 })
                        }
                      }
                      .margin({ bottom: 4 })
                    }
                    this.MessageBubble(msg)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Blank()
                    .width(48)
                }
              }
              .width('100%')
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .alignItems(VerticalAlign.Top)
              .gesture(
                LongPressGesture()
                  .onAction(() => {
                    this.contextMenuMsg = msg
                    this.showContextMenu = true
                  })
              )
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
        .scrollBar(BarState.Off)

        Divider()
          .color('#E5E5E5')
          .height(0.5)

        Column() {
          Row() {
            Text('发送')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor(this.inputText.length > 0 ? '#12B7F5' : '#CCCCCC')
              .borderRadius(16)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .margin({ left: 12 })
              .onClick(() => {
                this.sendMessage()
              })

            TextInput({ placeholder: '输入消息...', text: this.inputText })
              .layoutWeight(1)
              .height(36)
              .borderRadius(18)
              .margin({ left: 10, right: 12 })
              .onChange((value: string) => {
                this.inputText = value
              })
          }
          .width('100%')
          .height(50)
          .alignItems(VerticalAlign.Center)

          Row() {
            Column() {
              Text('🎤')
                .fontSize(24)
              Text('语音')
                .fontSize(10)
                .fontColor('#999999')
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              this.switchPanel('voice')
            })

            Column() {
              Text('🖼️')
                .fontSize(24)
              Text('图片')
                .fontSize(10)
                .fontColor('#999999')
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              this.switchPanel('image')
            })

            Column() {
              Text('📷')
                .fontSize(24)
              Text('摄像')
                .fontSize(10)
                .fontColor('#999999')
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              this.switchPanel('camera')
            })

            Column() {
              Text('😊')
                .fontSize(24)
              Text('表情')
                .fontSize(10)
                .fontColor('#999999')
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              this.switchPanel('emoji')
            })

            Column() {
              Text('➕')
                .fontSize(24)
              Text('更多')
                .fontSize(10)
                .fontColor('#999999')
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              this.switchPanel('more')
            })
          }
          .width('100%')
          .height(56)
          .backgroundColor('#F8F8F8')
        }
        .width('100%')
        .backgroundColor('#FFFFFF')

        if (this.activePanel === 'emoji') {
          this.EmojiPanel()
        } else if (this.activePanel === 'image') {
          this.ImagePanel()
        } else if (this.activePanel === 'camera') {
          this.CameraPanel()
        } else if (this.activePanel === 'more') {
          this.MorePanel()
        } else if (this.activePanel === 'voice') {
          this.VoicePanel()
        }
      }
      .width('100%')
      .height('100%')

      if (this.isRecording) {
        this.RecordingOverlay()
      }

      if (this.showContextMenu) {
        this.ContextMenuOverlay()
      }

      if (this.showForwardPanel) {
        this.ForwardPanelOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  VoicePanel() {
    Column() {
      Column() {
        Text('按住 说话')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 16 })

        Row() {
          Text('取消')
            .fontSize(14)
            .fontColor('#999999')

          Column() {
            Text('🎤')
              .fontSize(40)
          }
          .width(80)
          .height(80)
          .justifyContent(FlexAlign.Center)
          .borderRadius(40)
          .backgroundColor('#F0F0F0')
          .border({ width: 2, color: '#12B7F5' })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.startRecord()
            } else if (event.type === TouchType.Up) {
              this.finishRecord()
            } else if (event.type === TouchType.Move) {
            }
          })

          Text('转文字')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(180)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F8F8F8')
    }
    .width('100%')
    .height(180)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#E5E5E5' })
  }

  @Builder
  RecordingOverlay() {
    Column() {
      Column() {
        Text(this.isCancelled ? '松开手指，取消发送' : '手指上滑，取消发送')
          .fontSize(14)
          .fontColor(this.isCancelled ? '#FA5151' : '#999999')
          .margin({ bottom: 16 })

        Column() {
          Row() {
            Text('🔊')
              .fontSize(28)
              .opacity(0.3)
              .margin({ right: 4 })
            Text('🔊')
              .fontSize(28)
              .opacity(0.5)
              .margin({ right: 4 })
            Text('🔊')
              .fontSize(28)
              .opacity(0.7)
              .margin({ right: 4 })
            Text('🔊')
              .fontSize(28)
              .opacity(0.9)
              .margin({ right: 4 })
            Text('🔊')
              .fontSize(28)
              .opacity(1)
          }
          .margin({ bottom: 8 })

          Text(this.recordDuration.toString())
            .fontSize(48)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)

          Text('秒')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width(200)
      .height(200)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius(20)
      .backgroundColor('#000000CC')

      Text('松开 发送')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('rgba(0,0,0,0.4)')
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Up) {
        this.finishRecord()
      }
    })
  }

  @Builder
  ImagePanel() {
    Column() {
      Row() {
        Text('最近图片')
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('📷 拍照')
          .fontSize(14)
          .fontColor('#12B7F5')
          .onClick(() => {
            this.activePanel = 'camera'
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Scroll() {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.imageList, (item: ImageItem, index: number) => {
            Column() {
              Text(item.icon)
                .fontSize(36)
                .width(72)
                .height(72)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F0F0F0')
                .borderRadius(8)

              if (this.selectedImages[index]) {
                Row() {
                  Text('✓')
                    .fontSize(14)
                    .fontColor('#FFFFFF')
                }
                .width(22)
                .height(22)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#12B7F5')
                .borderRadius(11)
                .position({ x: 54, y: -4 })
              }
            }
            .width(80)
            .height(80)
            .margin({ left: 4, right: 4, bottom: 8 })
            .onClick(() => {
              this.toggleImage(index)
            })
          })
        }
        .width('100%')
        .padding({ left: 8, right: 8 })
      }
      .layoutWeight(1)

      if (this.getSelectedImageCount() > 0) {
        Row() {
          Text(`已选择 ${this.getSelectedImageCount()} 张图片`)
            .fontSize(14)
            .fontColor('#666666')
          Blank()
          Text('发送')
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#12B7F5')
            .borderRadius(18)
            .padding({ left: 20, right: 20, top: 8, bottom: 8 })
            .onClick(() => {
              this.sendSelectedImages()
            })
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .border({ width: { top: 0.5 }, color: '#E5E5E5' })
      }
    }
    .width('100%')
    .height(280)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#E5E5E5' })
  }

  @Builder
  CameraPanel() {
    Column() {
      Stack() {
        Column() {
          Text('📷')
            .fontSize(80)
            .opacity(0.3)
          Text('取景框')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#1A1A1A')

        Row() {
          Text('✕')
            .fontSize(20)
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.activePanel = 'none'
            })
          Blank()
          Text('闪光灯')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .onClick(() => {})
          Blank()
          Text('翻转')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .onClick(() => {})
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .position({ x: 0, y: 16 })

        Row() {
          Text('视频')
            .fontSize(14)
            .fontColor('#FFFFFF')
          Text('拍照')
            .fontSize(14)
            .fontColor('#FFD700')
            .margin({ left: 40 })
        }
        .position({ x: 0, y: 80 })
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Row() {
          Column() {
            Text('🖼️')
              .fontSize(28)
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .borderRadius(22)
          .border({ width: 2, color: '#FFFFFF' })

          Blank()

          Column() {
            Row() {
              Text('')
            }
            .width(64)
            .height(64)
            .justifyContent(FlexAlign.Center)
            .borderRadius(32)
            .backgroundColor('#FFFFFF')
            .border({ width: 4, color: '#CCCCCC' })
            .onClick(() => {
              const newMsg: ChatMessage = {
                id: this.messageList.length + 1,
                type: 'image',
                avatar: '🐶',
                nickname: 'water',
                isAdmin: false,
                content: '📸',
                timestamp: Date.now(),
                displayTime: '',
                showTimeLabel: false,
                isSelf: true
              }
              this.messageList = [...this.messageList, newMsg]
              this.calculateTimeLabels()
              this.scrollToBottom()
              this.activePanel = 'none'
            })
          }

          Blank()

          Text('完成')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.activePanel = 'none'
            })
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
        .position({ x: 0, y: 140 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(200)
    }
    .width('100%')
    .height(200)
    .backgroundColor('#1A1A1A')
  }

  @Builder
  EmojiPanel() {
    Column() {
      Row() {
        Text('😊 表情')
          .fontSize(14)
          .fontColor(this.emojiTabIndex === 0 ? '#12B7F5' : '#999999')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .onClick(() => {
            this.emojiTabIndex = 0
          })
        Text('🎭 表情包')
          .fontSize(14)
          .fontColor(this.emojiTabIndex === 1 ? '#12B7F5' : '#999999')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .onClick(() => {
            this.emojiTabIndex = 1
          })
        Text('⭐ 收藏')
          .fontSize(14)
          .fontColor(this.emojiTabIndex === 2 ? '#12B7F5' : '#999999')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .onClick(() => {
            this.emojiTabIndex = 2
          })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')

      Divider()
        .color('#E5E5E5')
        .height(0.5)

      if (this.emojiTabIndex === 0) {
        Scroll() {
          Column() {
            Text('最近使用')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ left: 16, top: 8, bottom: 8 })
              .width('100%')

            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
              ForEach(this.recentEmojiList, (item: EmojiItem) => {
                Text(item.icon)
                  .fontSize(32)
                  .width(40)
                  .height(40)
                  .textAlign(TextAlign.Center)
                  .onClick(() => {
                    this.sendEmoji(item.icon)
                  })
              })
            }
            .width('100%')
            .padding({ left: 8, right: 8 })

            Text('全部表情')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ left: 16, top: 12, bottom: 8 })
              .width('100%')

            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
              ForEach(this.emojiList, (item: EmojiItem) => {
                Text(item.icon)
                  .fontSize(32)
                  .width(40)
                  .height(40)
                  .textAlign(TextAlign.Center)
                  .onClick(() => {
                    this.sendEmoji(item.icon)
                  })
              })
            }
            .width('100%')
            .padding({ left: 8, right: 8 })
          }
          .width('100%')
        }
        .layoutWeight(1)
      } else if (this.emojiTabIndex === 1) {
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
            ForEach(this.stickerList, (item: StickerItem) => {
              Column() {
                Text(item.icon)
                  .fontSize(48)
                  .width(64)
                  .height(64)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(12)
                Text(item.name)
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
              .width(80)
              .padding({ top: 8, bottom: 8 })
              .onClick(() => {
                this.sendSticker(item.icon)
              })
            })
          }
          .width('100%')
          .padding(12)
        }
        .layoutWeight(1)
      } else if (this.emojiTabIndex === 2) {
        Column() {
          Text('⭐')
            .fontSize(48)
            .margin({ top: 40 })
          Text('暂无收藏的表情')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 })
          Text('长按表情可添加到收藏')
            .fontSize(13)
            .fontColor('#CCCCCC')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height(300)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#E5E5E5' })
  }

  @Builder
  MorePanel() {
    Column() {
      Row() {
        Text('更多功能')
          .fontSize(14)
          .fontColor('#999999')
        Blank()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      Swiper() {
        ForEach(this.getMorePages(), (pageItems: MoreItem[]) => {
          Column() {
            ForEach([0, 1], (rowIndex: number) => {
              Row() {
                ForEach(this.getPageRowItems(pageItems, rowIndex), (item: MoreItem) => {
                  Column() {
                    Text(item.icon)
                      .fontSize(32)
                      .width(52)
                      .height(52)
                      .textAlign(TextAlign.Center)
                      .backgroundColor('#F5F5F5')
                      .borderRadius(12)
                    Text(item.name)
                      .fontSize(12)
                      .fontColor('#333333')
                      .margin({ top: 6 })
                  }
                  .width('25%')
                  .padding({ top: 10, bottom: 10 })
                  .alignItems(HorizontalAlign.Center)
                  .onClick(() => {
                    this.handleMoreItem(item.name)
                  })
                })
              }
              .width('100%')
            })
          }
          .width('100%')
          .height('100%')
        })
      }
      .width('100%')
      .layoutWeight(1)
      .indicator(true)
      .loop(false)
    }
    .width('100%')
    .height(260)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 0.5 }, color: '#E5E5E5' })
  }

  private getMorePages(): MoreItem[][] {
    const pages: MoreItem[][] = []
    const pageSize = 8
    for (let i = 0; i < this.moreItems.length; i += pageSize) {
      const page: MoreItem[] = []
      for (let j = i; j < i + pageSize && j < this.moreItems.length; j++) {
        page.push(this.moreItems[j])
      }
      pages.push(page)
    }
    return pages
  }

  private getPageRowItems(pageItems: MoreItem[], rowIndex: number): MoreItem[] {
    const perRow = 4
    const start = rowIndex * perRow
    const result: MoreItem[] = []
    for (let i = start; i < start + perRow && i < pageItems.length; i++) {
      result.push(pageItems[i])
    }
    return result
  }

  @Builder
  MessageBubble(msg: ChatMessage) {
    Column() {
      if (msg.isForwarded) {
        Text('[转发消息]')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ bottom: 4 })
      }

      if (msg.type === 'text') {
        Text(msg.content)
          .fontSize(15)
          .fontColor('#333333')
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .backgroundColor(msg.isSelf ? '#95EC69' : '#FFFFFF')
          .borderRadius(12)
          .constraintSize({ maxWidth: '75%' })
      } else if (msg.type === 'voice') {
        Row() {
          if (msg.isSelf) {
            Text(`${msg.voiceDuration || 0}"`)
              .fontSize(14)
              .fontColor('#333333')
              .margin({ right: 8 })
            Text('🔊')
              .fontSize(18)
          } else {
            Text('🔊')
              .fontSize(18)
              .margin({ right: 8 })
            Text(`${msg.voiceDuration || 0}"`)
              .fontSize(14)
              .fontColor('#333333')
          }
        }
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .backgroundColor(msg.isSelf ? '#95EC69' : '#FFFFFF')
        .borderRadius(12)
      } else if (msg.type === 'image') {
        Text(msg.content)
          .fontSize(64)
          .width(120)
          .height(120)
          .textAlign(TextAlign.Center)
          .backgroundColor('#F0F0F0')
          .borderRadius(8)
      } else if (msg.type === 'sticker') {
        Text(msg.content)
          .fontSize(64)
      } else if (msg.type === 'file') {
        Row() {
          Column() {
            Text('📄')
              .fontSize(32)
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F0F0F0')
          .borderRadius(8)

          Column() {
            Text(msg.fileName || '未知文件')
              .fontSize(14)
              .fontColor('#333333')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(msg.fileSize || '0B')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 10 })
        }
        .width(220)
        .padding(12)
        .backgroundColor(msg.isSelf ? '#95EC69' : '#FFFFFF')
        .borderRadius(12)
      } else if (msg.type === 'link') {
        Column() {
          Text(msg.content)
            .fontSize(15)
            .fontColor('#333333')
            .padding({ left: 12, right: 12, top: 10, bottom: 0 })

          Row() {
            Text('🔗')
              .fontSize(16)
            Column() {
              Text(msg.linkTitle || '')
                .fontSize(14)
                .fontColor('#12B7F5')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(msg.linkUrl || '')
                .fontSize(12)
                .fontColor('#999999')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 8 })
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 8, bottom: 10 })
        }
        .backgroundColor(msg.isSelf ? '#95EC69' : '#FFFFFF')
        .borderRadius(12)
        .constraintSize({ maxWidth: '75%' })
      } else if (msg.type === 'card') {
        Column() {
          Row() {
            Text(msg.cardCover || '')
              .fontSize(40)
              .width(56)
              .height(56)
              .textAlign(TextAlign.Center)
              .backgroundColor('#F0F0F0')
              .borderRadius(8)

            Column() {
              Text(msg.cardTitle || '')
                .fontSize(14)
                .fontColor('#333333')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .lineHeight(20)

              Text(msg.cardAuthor || '')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 10 })
          }
          .width('100%')
          .padding(10)
        }
        .width(240)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .border({ width: 0.5, color: '#E5E5E5' })
      }

      if (msg.isSelf) {
        Row() {
          Text(msg.isRead ? '✓✓' : '✓')
            .fontSize(11)
            .fontColor(msg.isRead ? '#12B7F5' : '#999999')
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ top: 2 })
      }
    }
  }

  private async loadMemberCount(): Promise<void> {
    try {
      interface MemberBrief { userId: number }
      const members = await get<MemberBrief[]>(Api.groupMembers(Number(this.targetId)))
      if (members && Array.isArray(members)) {
        this.memberCount = members.length
      }
    } catch (_e) {}
  }

  private getMemberCount(): string {
    return String(this.memberCount)
  }

  private async sendMessage(): Promise<void> {
    if (this.inputText.length === 0) {
      return
    }
    if (!this.targetId || Number(this.targetId) <= 0) {
      promptAction.showToast({ message: '发送失败：无效的会话' })
      return
    }
    const content = this.inputText
    this.inputText = ''

    const newMsg: ChatMessage = {
      id: this.messageList.length + 1,
      type: 'text',
      avatar: this.userAvatar,
      nickname: this.userNickname || '我',
      isAdmin: false,
      content: content,
      timestamp: Date.now(),
      displayTime: '',
      showTimeLabel: false,
      isSelf: true,
      isRead: false
    }
    this.messageList = [...this.messageList, newMsg]
    this.calculateTimeLabels()
    this.scrollToBottom()

    try {
      if (this.isGroup) {
        const groupMsgBody: SendGroupMsgBody = {
          groupId: Number(this.targetId),
          content: content,
          msgType: 'text'
        }
        await post<void>(Api.MSG_SEND_GROUP, groupMsgBody)
      } else {
        const msgBody: SendMsgBody = {
          receiverId: Number(this.targetId),
          content: content,
          msgType: 'text'
        }
        await post<void>(Api.MSG_SEND, msgBody)
      }
      AppStorage.setOrCreate<number>('msgPageRefresh', Date.now())
    } catch (_e) {
      promptAction.showToast({ message: '发送失败' })
    }
  }

  private scrollToBottom(): void {
    this.messageScroller.scrollEdge(Edge.Bottom)
  }

  private handleContextAction(label: string): void {
    if (this.contextMenuMsg === null) {
      return
    }
    const msg = this.contextMenuMsg
    if (label === '复制') {
      this.inputText = msg.content
    } else if (label === '转发') {
      this.forwardMsgContent = msg.content
      this.showForwardPanel = true
    } else if (label === '收藏') {
      // 收藏到本地
    } else if (label === '置顶') {
      this.pinnedMsg = msg
    } else if (label === '删除') {
      this.messageList = this.messageList.filter((m: ChatMessage) => m.id !== msg.id)
    } else if (label === '撤回') {
      if (msg.isSelf) {
        this.messageList = this.messageList.filter((m: ChatMessage) => m.id !== msg.id)
      }
    }
    this.showContextMenu = false
    this.contextMenuMsg = null
  }

  private handleForward(contactName: string): void {
    const newMsg: ChatMessage = {
      id: this.messageList.length + 1,
      type: 'text',
      avatar: '🐶',
      nickname: 'water',
      isAdmin: false,
      content: `[转发] ${this.forwardMsgContent}`,
      timestamp: Date.now(),
      displayTime: '',
      showTimeLabel: false,
      isSelf: true,
      isForwarded: true,
      isRead: true
    }
    this.messageList = [...this.messageList, newMsg]
    this.showForwardPanel = false
    this.forwardMsgContent = ''
    this.calculateTimeLabels()
    this.scrollToBottom()
  }

  @Builder
  ContextMenuOverlay() {
    Column() {
      Column() {
        ForEach(this.contextMenuItems, (item: ContextMenuItem) => {
          Row() {
            Text(item.icon)
              .fontSize(20)
              .width(32)
            Text(item.label)
              .fontSize(15)
              .fontColor('#333333')
          }
          .width(120)
          .height(44)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.handleContextAction(item.label)
          })
        })
      }
      .backgroundColor('#4C4C4C')
      .borderRadius(12)
      .padding({ top: 4, bottom: 4 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.4)')
    .onClick(() => {
      this.showContextMenu = false
      this.contextMenuMsg = null
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ForwardPanelOverlay() {
    Column() {
      Column() {
        Row() {
          Text('转发给')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          Blank()
          Text('✕')
            .fontSize(22)
            .fontColor('#999999')
            .onClick(() => {
              this.showForwardPanel = false
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 12 })

        Divider()
          .color('#F0F0F0')

        List({ space: 0 }) {
          ForEach(this.forwardContacts, (contact: ChatMessage) => {
            ListItem() {
              Row() {
                Text(contact.avatar)
                  .fontSize(28)
                  .width(40)
                  .height(40)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#E8E8E8')
                  .borderRadius(20)
                Text(contact.nickname)
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ left: 12 })
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                this.handleForward(contact.nickname)
              })
            }
          })
        }
        .width('100%')
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.4)')
    .justifyContent(FlexAlign.End)
    .onClick(() => {
      this.showForwardPanel = false
    })
  }
}
