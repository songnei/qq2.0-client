import router from '@ohos.router'
import { get, post, put, del, Api } from './HttpRequest'
import { promptAction } from '@kit.ArkUI'

interface ContactItem {
  avatar: string
  name: string
  desc?: string
  isOnline?: boolean
  age?: number
  location?: string
  pinyin: string
  group: string
  friendId?: number
  qqNumber?: string
}

interface GroupItem {
  avatar: string
  name: string
  memberCount: string
  lastMsg?: string
  groupId?: number
}

interface FriendGroup {
  id: number
  name: string
  members: ContactItem[]
  isExpanded: boolean
}

interface FriendRequest {
  id: number
  avatar: string
  name: string
  message: string
  time: string
  status: string
  requestId?: number
}

interface FriendApiData {
  id: number
  friendId: number
  nickname: string
  friendNickname: string
  remark: string
  friendAvatar: string
  signature: string
  online: boolean
  groupName: string
  friendQqNumber: string
  qqNumber: string
}

interface GroupApiData {
  id: number
  groupId: number
  avatar: string
  name: string
  memberCount: number
  lastMessage: string
}

interface FriendRequestApiData {
  id: number
  avatar: string
  nickname: string
  qqNumber: string
  message: string
  createTime: string
  status: number
}

interface GroupInviteApiData {
  id: number
  groupId: number
  groupName: string
  groupAvatar: string
  inviterId: number
  inviterNickname: string
  inviterAvatar: string
  status: number
  createTime: string
}

interface GroupInviteItem {
  inviteId: number
  groupId: number
  groupName: string
  groupAvatar: string
  inviterName: string
  inviterAvatar: string
  time: string
}

@Component
export struct ContactPage {
  @StorageProp('userAvatar') userAvatar: string = '🐶'
  @StorageProp('msgPageRefresh') @Watch('onMsgRefresh') msgRefreshTrigger: number = 0
  @State groupRefreshKey: number = 0
  @State currentTab: number = 0
  @State expandedGroups: Record<number, boolean> = { 1: true }
  @State showMoveDialog: boolean = false
  @State moveTarget: number = -1
  @State moveFriendIndex: number = -1
  @State moveFromGroup: number = -1
  @State showSearchResult: boolean = false
  @State searchKeyword: string = ''
  @State searchResults: ContactItem[] = []
  @StorageLink('deletedFriendName') @Watch('onFriendDeleted') deletedFriendName: string = ''
  @State showFriendRequests: boolean = false
  @State friendRequests: FriendRequest[] = []
  @State groupInvites: GroupInviteItem[] = []
  @State showGroupInvites: boolean = false
  private tabs: string[] = ['分组', '好友', '群聊', '频道', '机器人', '设备']

  private recommendList: ContactItem[] = [
    {
      avatar: '👤',
      name: '川蔡依林的狗',
      age: 23,
      desc: '你的群友陈宇航(18384529872)',
      pinyin: 'c',
      group: '推荐'
    },
    {
      avatar: '👤',
      name: '小麦_AI',
      age: 19,
      location: '在北京',
      desc: '摩羯座',
      pinyin: 'x',
      group: '推荐'
    }
  ]

  @State friendList: ContactItem[] = []

  @State friendGroups: FriendGroup[] = [
    { id: 0, name: '特别关心', members: [], isExpanded: false },
    { id: 1, name: '我的好友', members: [], isExpanded: true },
    { id: 2, name: '朋友', members: [], isExpanded: false },
    { id: 3, name: '家人', members: [], isExpanded: false },
    { id: 4, name: '同学', members: [], isExpanded: false }
  ]

  private groupList: GroupItem[] = [
  ]

  private channelList: ContactItem[] = [
    { avatar: '🎮', name: '王者荣耀开黑', pinyin: 'w', group: '' },
    { avatar: '🎵', name: '音乐分享', pinyin: 'y', group: '' },
    { avatar: '📸', name: '摄影爱好者', pinyin: 's', group: '' }
  ]

  private botList: ContactItem[] = [
    { avatar: '🤖', name: 'QQ小冰', desc: '智能聊天机器人', pinyin: 'q', group: '' },
    { avatar: '🤖', name: '日程助手', desc: '管理你的日程', pinyin: 'r', group: '' },
    { avatar: '🤖', name: '文件传输助手', desc: '跨设备传输文件', pinyin: 'w', group: '' }
  ]

  private deviceList: ContactItem[] = [
    { avatar: '💻', name: '我的电脑', desc: '已离线', pinyin: 'w', group: '' },
    { avatar: '📱', name: '我的手机', desc: '在线', pinyin: 'w', group: '' }
  ]

  aboutToAppear(): void {
    this.loadFriends()
    this.loadGroups()
    this.loadFriendRequests()
    this.loadGroupInvites()
  }

  onMsgRefresh(): void {
    this.loadGroups()
    this.loadGroupInvites()
  }

  private forceRefreshGroups(): void {
    this.groupRefreshKey = this.groupRefreshKey + 1
  }

  async loadFriends(): Promise<void> {
    try {
      const data = await get<FriendApiData[]>(Api.FRIEND_LIST)
      if (data && Array.isArray(data)) {
        const result: ContactItem[] = []
        for (let i = 0; i < data.length; i++) {
          const f = data[i]
          const name = f.remark || f.nickname || f.friendNickname || ''
          const avatarVal = this.isValidAvatar(f.friendAvatar) ? f.friendAvatar : '👤'
          result.push({
            avatar: avatarVal,
            name: name,
            desc: f.signature || '',
            isOnline: f.online,
            pinyin: name.charAt(0).toLowerCase(),
            group: f.groupName || '我的好友',
            friendId: f.friendId || f.id || 0,
            qqNumber: f.friendQqNumber || f.qqNumber || ''
          })
        }
        this.friendList = result
        this.rebuildGroups()
      }
    } catch (_e) {
      this.rebuildGroups()
    }
  }

  async loadGroups(): Promise<void> {
    try {
      const data = await get<GroupApiData[]>(Api.GROUP_LIST)
      if (data && Array.isArray(data)) {
        const result: GroupItem[] = []
        for (let i = 0; i < data.length; i++) {
          const g = data[i]
          result.push({
            avatar: g.avatar || '👥',
            name: g.name || '',
            memberCount: (g.memberCount || 0) + '人',
            lastMsg: g.lastMessage || '',
            groupId: g.id || g.groupId || 0
          })
        }
        this.groupList = result
        this.forceRefreshGroups()
      }
    } catch (_e) {
    }
  }

  private isValidAvatar(val: string): boolean {
    if (!val || val.length === 0) return false
    if (val.length > 10) return true
    const lower = val.toLowerCase()
    if (lower === 'avatar' || lower === 'null' || lower === 'undefined' || lower === 'none') return false
    return true
  }

  async loadFriendRequests(): Promise<void> {
    try {
      const data = await get<FriendRequestApiData[]>(Api.FRIEND_REQUESTS)
      if (data && Array.isArray(data)) {
        const result: FriendRequest[] = []
        for (let i = 0; i < data.length; i++) {
          const r = data[i]
          let statusStr: string = 'pending'
          if (r.status === 1) {
            statusStr = 'accepted'
          } else if (r.status === 2) {
            statusStr = 'refused'
          }
          const avatarVal = this.isValidAvatar(r.avatar) ? r.avatar : '👤'
          result.push({
            id: r.id || 0,
            avatar: avatarVal,
            name: r.nickname || '',
            message: r.message || '',
            time: this.formatRequestTime(r.createTime || ''),
            status: statusStr,
            requestId: r.id || 0
          })
        }
        this.friendRequests = result
      }
    } catch (_e) {
    }
  }

  private formatRequestTime(timeStr: string): string {
    if (!timeStr) return ''
    try {
      const now = new Date()
      const date = new Date(timeStr)
      const diffMs = now.getTime() - date.getTime()
      const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
      if (diffHours < 1) return '刚刚'
      if (diffHours < 24) return diffHours + '小时前'
      const diffDays = Math.floor(diffHours / 24)
      if (diffDays < 7) return diffDays + '天前'
      return (date.getMonth() + 1) + '/' + date.getDate()
    } catch (_e) {
      return timeStr
    }
  }

  async loadGroupInvites(): Promise<void> {
    try {
      const data = await get<GroupInviteApiData[]>(Api.GROUP_INVITE_LIST)
      if (data && Array.isArray(data)) {
        const result: GroupInviteItem[] = []
        for (let i = 0; i < data.length; i++) {
          const item = data[i]
          result.push({
            inviteId: item.id || 0,
            groupId: item.groupId || 0,
            groupName: item.groupName || '',
            groupAvatar: item.groupAvatar || '👥',
            inviterName: item.inviterNickname || '',
            inviterAvatar: item.inviterAvatar || '👤',
            time: this.formatRequestTime(item.createTime || '')
          })
        }
        this.groupInvites = result
      }
    } catch (_e) {
    }
  }

  async acceptGroupInvite(inviteId: number): Promise<void> {
    try {
      await post<void>(Api.GROUP_INVITE_ACCEPT + inviteId + '/accept')
      promptAction.showToast({ message: '已加入群聊' })
      const newList: GroupInviteItem[] = []
      for (let i = 0; i < this.groupInvites.length; i++) {
        if (this.groupInvites[i].inviteId !== inviteId) {
          newList.push(this.groupInvites[i])
        }
      }
      this.groupInvites = newList
      this.loadGroups()
      AppStorage.setOrCreate<number>('msgPageRefresh', Date.now())
    } catch (_e) {
      promptAction.showToast({ message: '操作失败' })
    }
  }

  async rejectGroupInvite(inviteId: number): Promise<void> {
    try {
      await post<void>(Api.GROUP_INVITE_REJECT + inviteId + '/reject')
      const newList: GroupInviteItem[] = []
      for (let i = 0; i < this.groupInvites.length; i++) {
        if (this.groupInvites[i].inviteId !== inviteId) {
          newList.push(this.groupInvites[i])
        }
      }
      this.groupInvites = newList
    } catch (_e) {
      promptAction.showToast({ message: '操作失败' })
    }
  }

  onFriendDeleted(): void {
    if (this.deletedFriendName.length === 0) {
      return
    }
    const targetName = this.deletedFriendName
    const newList: ContactItem[] = []
    for (let i = 0; i < this.friendList.length; i++) {
      if (this.friendList[i].name !== targetName) {
        newList.push(this.friendList[i])
      }
    }
    this.friendList = newList
    this.rebuildGroups()
    this.deletedFriendName = ''
  }

  rebuildGroups(): void {
    const newGroups: FriendGroup[] = []
    for (let g = 0; g < this.friendGroups.length; g++) {
      const group = this.friendGroups[g]
      const members: ContactItem[] = []
      for (let i = 0; i < this.friendList.length; i++) {
        if (this.friendList[i].group === group.name) {
          members.push(this.friendList[i])
        }
      }
      newGroups.push({
        id: group.id,
        name: group.name,
        members: members,
        isExpanded: group.isExpanded
      })
    }
    this.friendGroups = newGroups
  }

  getSortedFriends(): ContactItem[] {
    const sorted: ContactItem[] = []
    for (let i = 0; i < this.friendList.length; i++) {
      sorted.push(this.friendList[i])
    }
    for (let i = 0; i < sorted.length; i++) {
      for (let j = i + 1; j < sorted.length; j++) {
        if (sorted[i].pinyin > sorted[j].pinyin) {
          const temp = sorted[i]
          sorted[i] = sorted[j]
          sorted[j] = temp
        }
      }
    }
    return sorted
  }

  toggleGroupExpand(groupId: number): void {
    const newGroups: FriendGroup[] = []
    for (let i = 0; i < this.friendGroups.length; i++) {
      const group = this.friendGroups[i]
      if (group.id === groupId) {
        newGroups.push({
          id: group.id,
          name: group.name,
          members: group.members,
          isExpanded: !group.isExpanded
        })
      } else {
        newGroups.push(group)
      }
    }
    this.friendGroups = newGroups
  }

  moveFriend(newGroupName: string): void {
    if (this.moveFriendIndex < 0 || this.moveFriendIndex >= this.friendList.length) {
      return
    }
    const newList: ContactItem[] = []
    for (let i = 0; i < this.friendList.length; i++) {
      const item = this.friendList[i]
      if (i === this.moveFriendIndex) {
        newList.push({
          avatar: item.avatar,
          name: item.name,
          desc: item.desc,
          isOnline: item.isOnline,
          age: item.age,
          location: item.location,
          pinyin: item.pinyin,
          group: newGroupName
        })
      } else {
        newList.push(item)
      }
    }
    this.friendList = newList
    this.rebuildGroups()
    this.showMoveDialog = false
    this.moveFriendIndex = -1
  }

  async acceptRequest(reqId: number): Promise<void> {
    try {
      const requestId = this.getRequestId(reqId)
      await put<void>(Api.friendAccept(requestId))
      this.updateRequestStatus(reqId, 'accepted')
      promptAction.showToast({ message: '已同意' })
      this.loadFriends()
    } catch (_e) {
      promptAction.showToast({ message: '操作失败' })
    }
  }

  async refuseRequest(reqId: number): Promise<void> {
    try {
      const requestId = this.getRequestId(reqId)
      await put<void>(Api.friendReject(requestId))
      this.updateRequestStatus(reqId, 'refused')
      promptAction.showToast({ message: '已拒绝' })
    } catch (_e) {
      promptAction.showToast({ message: '操作失败' })
    }
  }

  private getRequestId(reqId: number): number {
    for (let i = 0; i < this.friendRequests.length; i++) {
      if (this.friendRequests[i].id === reqId) {
        return this.friendRequests[i].requestId || reqId
      }
    }
    return reqId
  }

  private updateRequestStatus(reqId: number, status: string): void {
    const newList: FriendRequest[] = []
    for (let i = 0; i < this.friendRequests.length; i++) {
      const req = this.friendRequests[i]
      if (req.id === reqId) {
        newList.push({
          id: req.id,
          avatar: req.avatar,
          name: req.name,
          message: req.message,
          time: req.time,
          status: status,
          requestId: req.requestId
        })
      } else {
        newList.push(req)
      }
    }
    this.friendRequests = newList
  }

  getPendingCount(): number {
    let count = 0
    for (let i = 0; i < this.friendRequests.length; i++) {
      if (this.friendRequests[i].status === 'pending') {
        count++
      }
    }
    return count
  }

  doSearch(keyword: string): void {
    this.searchKeyword = keyword
    if (keyword.trim().length === 0) {
      this.showSearchResult = false
      this.searchResults = []
      return
    }
    const results: ContactItem[] = []
    for (let i = 0; i < this.friendList.length; i++) {
      const item = this.friendList[i]
      if (item.name.indexOf(keyword) >= 0) {
        results.push(item)
      }
    }
    for (let i = 0; i < this.groupList.length; i++) {
      const item = this.groupList[i]
      if (item.name.indexOf(keyword) >= 0) {
        results.push({
          avatar: item.avatar,
          name: item.name,
          desc: item.memberCount,
          pinyin: '',
          group: '群聊'
        })
      }
    }
    this.searchResults = results
    this.showSearchResult = true
  }

  @Builder
  SearchBar() {
    Row() {
      Text('🔍')
        .fontSize(18)
        .margin({ left: 12 })
      TextInput({ placeholder: '搜索联系人/群聊', text: this.searchKeyword })
        .layoutWeight(1)
        .height(44)
        .fontSize(16)
        .backgroundColor('transparent')
        .margin({ left: 8 })
        .onChange((value: string) => {
          this.searchKeyword = value
        })
        .onSubmit(() => {
          this.doSearch(this.searchKeyword)
        })
    }
    .width('92%')
    .height(44)
    .backgroundColor('#F5F5F5')
    .borderRadius(22)
    .margin({ top: 8 })
  }

  @Builder
  GroupSectionItem(groupName: string, count: string, groupId: number) {
    Column() {
      Row() {
        Text(this.friendGroups[groupId] && this.friendGroups[groupId].isExpanded ? '▾' : '›')
          .fontSize(16)
          .fontColor('#999999')
          .width(20)
        Text(groupName)
          .fontSize(15)
          .fontColor('#333333')
          .margin({ left: 8 })
          .layoutWeight(1)
        Text(count)
          .fontSize(13)
          .fontColor('#999999')
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.toggleGroupExpand(groupId)
      })

      if (this.friendGroups[groupId] && this.friendGroups[groupId].isExpanded) {
        ForEach(this.friendGroups[groupId].members, (item: ContactItem, mIdx: number) => {
          Row() {
            Text(item.avatar)
              .fontSize(24)
              .width(36)
              .height(36)
              .textAlign(TextAlign.Center)
              .backgroundColor('#F0F0F0')
              .borderRadius(18)
            Column() {
              Text(item.name)
                .fontSize(14)
                .fontColor('#333333')
              if (item.desc) {
                Text(item.desc!)
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 2 })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
            .layoutWeight(1)
          }
          .width('100%')
          .height(56)
          .padding({ left: 36, right: 16 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ContactDetailPage',
              params: {
                contactName: item.name,
                contactAvatar: item.avatar,
                isOnline: item.isOnline || false,
                isFriend: true,
                friendId: item.friendId ? String(item.friendId) : '',
                qqNumber: item.qqNumber || '',
                remark: item.desc || ''
              }
            })
          })
          .gesture(
            LongPressGesture()
              .onAction(() => {
                let realIdx = -1
                for (let fi = 0; fi < this.friendList.length; fi++) {
                  if (this.friendList[fi].name === item.name && this.friendList[fi].group === groupName) {
                    realIdx = fi
                    break
                  }
                }
                if (realIdx >= 0) {
                  this.moveFriendIndex = realIdx
                  this.moveFromGroup = groupId
                  this.showMoveDialog = true
                }
              })
          )
          Divider().color('#F0F0F0').margin({ left: 52 })
        })
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Row() {
          Text(this.userAvatar)
            .fontSize(28)
            .margin({ left: 12 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/SidebarPage' })
            })
          Text('联系人')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ left: 12 })
          Blank()
          Text('➕')
            .fontSize(24)
            .margin({ right: 16 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddPage' })
            })
        }
        .width('100%')
        .height(56)
        .padding({ top: 8 })

        this.SearchBar()

        Scroll() {
          Column() {
            if (this.showSearchResult) {
              Column() {
                if (this.searchResults.length > 0) {
                  ForEach(this.searchResults, (item: ContactItem) => {
                    Row() {
                      Text(item.avatar)
                        .fontSize(28)
                        .width(44)
                        .height(44)
                        .textAlign(TextAlign.Center)
                        .backgroundColor('#E8E8E8')
                        .borderRadius(22)
                      Column() {
                        Text(item.name)
                          .fontSize(16)
                          .fontColor('#333333')
                        if (item.desc) {
                          Text(item.desc!)
                            .fontSize(12)
                            .fontColor('#999999')
                            .margin({ top: 2 })
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                      .margin({ left: 12 })
                      .layoutWeight(1)
                      if (item.group) {
                        Text(item.group)
                          .fontSize(12)
                          .fontColor('#999999')
                      }
                    }
                    .width('100%')
                    .height(64)
                    .padding({ left: 16, right: 16 })
                    .onClick(() => {
                      if (item.group === '群聊') {
                        router.pushUrl({
                          url: 'pages/ChatPage',
                          params: { chatName: item.name, chatAvatar: item.avatar, isGroup: true, targetId: item.friendId ? String(item.friendId) : '' }
                        })
                      } else {
                        router.pushUrl({
                          url: 'pages/ContactDetailPage',
                          params: {
                            contactName: item.name,
                            contactAvatar: item.avatar,
                            isOnline: item.isOnline || false,
                            isFriend: true,
                            friendId: item.friendId ? String(item.friendId) : '',
                            qqNumber: item.qqNumber || '',
                            remark: item.desc || ''
                          }
                        })
                      }
                    })
                    Divider().color('#F0F0F0').margin({ left: 72 })
                  })
                } else {
                  Column() {
                    Text('🔍')
                      .fontSize(40)
                      .margin({ top: 30 })
                    Text('未找到相关联系人')
                      .fontSize(14)
                      .fontColor('#999999')
                      .margin({ top: 8 })
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Center)
                  .padding({ bottom: 20 })
                }
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
            } else {
              Column() {
                Column() {
                  Row() {
                    Text('可能认识的人')
                      .fontSize(14)
                      .fontColor('#999999')
                    Blank()
                    Text('›')
                      .fontSize(16)
                      .fontColor('#999999')
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })

                  ForEach(this.recommendList, (item: ContactItem) => {
                    Row() {
                      Text(item.avatar)
                        .fontSize(32)
                      Column() {
                        Text(item.name)
                          .fontSize(15)
                          .fontColor('#333333')
                        Row() {
                          if (item.age) {
                            Text(`${item.age}岁`)
                              .fontSize(12)
                              .fontColor('#999999')
                              .margin({ right: 4 })
                          }
                          if (item.location) {
                            Text(item.location)
                              .fontSize(12)
                              .fontColor('#999999')
                              .margin({ right: 4 })
                          }
                          if (item.desc) {
                            Text(item.desc)
                              .fontSize(12)
                              .fontColor('#999999')
                              .maxLines(1)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                          }
                        }
                        .margin({ top: 4 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                      .margin({ left: 12 })

                      Button('添加')
                        .fontSize(14)
                        .fontColor('#12B7F5')
                        .backgroundColor('#FFFFFF')
                        .border({ width: 1, color: '#12B7F5' })
                        .borderRadius(16)
                        .height(32)
                        .padding({ left: 16, right: 16 })

                      Text('✕')
                        .fontSize(20)
                        .fontColor('#999999')
                        .margin({ left: 12 })
                    }
                    .width('100%')
                    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                  })
                }
                .width('100%')
                .backgroundColor('#FFFFFF')

                Divider()
                  .color('#F0F0F0')
                  .height(8)

                Row() {
                  Text('新朋友')
                    .fontSize(16)
                    .fontColor('#333333')
                  if (this.getPendingCount() > 0) {
                    Text(`${this.getPendingCount()}条新申请`)
                      .fontSize(12)
                      .fontColor('#FA5151')
                      .backgroundColor('#FFF0F0')
                      .borderRadius(8)
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .margin({ left: 8 })
                  }
                  Blank()
                  Text(this.showFriendRequests ? '▾' : '›')
                    .fontSize(16)
                    .fontColor('#999999')
                }
                .width('100%')
                .height(56)
                .padding({ left: 16, right: 16 })
                .backgroundColor('#FFFFFF')
                .onClick(() => {
                  this.showFriendRequests = !this.showFriendRequests
                })

                if (this.showFriendRequests) {
                  Column() {
                    if (this.friendRequests.length > 0) {
                      ForEach(this.friendRequests, (req: FriendRequest) => {
                        Column() {
                          Row() {
                            Text(req.avatar)
                              .fontSize(32)
                              .width(48)
                              .height(48)
                              .textAlign(TextAlign.Center)
                              .backgroundColor('#F0F0F0')
                              .borderRadius(24)
                            Column() {
                              Row() {
                                Text(req.name)
                                  .fontSize(15)
                                  .fontColor('#333333')
                                  .fontWeight(FontWeight.Medium)
                                Blank()
                                Text(req.time)
                                  .fontSize(12)
                                  .fontColor('#CCCCCC')
                              }
                              .width('100%')
                              Text(req.message)
                                .fontSize(13)
                                .fontColor('#999999')
                                .width('100%')
                                .margin({ top: 4 })
                                .maxLines(1)
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                            }
                            .alignItems(HorizontalAlign.Start)
                            .layoutWeight(1)
                            .margin({ left: 12 })
                          }
                          .width('100%')

                          if (req.status === 'pending') {
                            Row() {
                              Text('拒绝')
                                .fontSize(13)
                                .fontColor('#999999')
                                .backgroundColor('#F5F5F5')
                                .borderRadius(14)
                                .padding({ left: 20, right: 20, top: 6, bottom: 6 })
                                .onClick(() => {
                                  this.refuseRequest(req.id)
                                })
                              Text('同意')
                                .fontSize(13)
                                .fontColor('#FFFFFF')
                                .backgroundColor('#12B7F5')
                                .borderRadius(14)
                                .padding({ left: 20, right: 20, top: 6, bottom: 6 })
                                .margin({ left: 12 })
                                .onClick(() => {
                                  this.acceptRequest(req.id)
                                })
                            }
                            .width('100%')
                            .justifyContent(FlexAlign.End)
                            .margin({ top: 8 })
                          } else if (req.status === 'accepted') {
                            Row() {
                              Text('已同意')
                                .fontSize(13)
                                .fontColor('#4CD964')
                                .backgroundColor('#E8F8E9')
                                .borderRadius(14)
                                .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                            }
                            .width('100%')
                            .justifyContent(FlexAlign.End)
                            .margin({ top: 8 })
                          } else {
                            Row() {
                              Text('已拒绝')
                                .fontSize(13)
                                .fontColor('#999999')
                                .backgroundColor('#F5F5F5')
                                .borderRadius(14)
                                .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                            }
                            .width('100%')
                            .justifyContent(FlexAlign.End)
                            .margin({ top: 8 })
                          }

                          Divider().color('#F0F0F0').margin({ top: 12 })
                        }
                        .width('100%')
                        .padding({ left: 16, right: 16, top: 12 })
                      })
                    } else {
                      Column() {
                        Text('暂无好友申请')
                          .fontSize(14)
                          .fontColor('#CCCCCC')
                          .margin({ top: 16, bottom: 16 })
                      }
                      .width('100%')
                      .alignItems(HorizontalAlign.Center)
                    }
                  }
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                }

                Divider()
                  .color('#E5E5E5')
                  .margin({ left: 16 })

                Row() {
                  Text('群通知')
                    .fontSize(16)
                    .fontColor('#333333')
                  if (this.groupInvites.length > 0) {
                    Text(String(this.groupInvites.length))
                      .fontSize(11)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#FA5151')
                      .borderRadius(8)
                      .textAlign(TextAlign.Center)
                      .width(16)
                      .height(16)
                      .margin({ left: 6 })
                  }
                  Blank()
                  Text('›')
                    .fontSize(16)
                    .fontColor('#999999')
                }
                .width('100%')
                .height(56)
                .padding({ left: 16, right: 16 })
                .backgroundColor('#FFFFFF')
                .onClick(() => {
                  this.showGroupInvites = !this.showGroupInvites
                  if (this.showGroupInvites) {
                    this.loadGroupInvites()
                  }
                })

                if (this.showGroupInvites) {
                  Column() {
                    if (this.groupInvites.length > 0) {
                      ForEach(this.groupInvites, (invite: GroupInviteItem) => {
                        Column() {
                          Row() {
                            Text(invite.groupAvatar)
                              .fontSize(28)
                              .width(40)
                              .height(40)
                              .textAlign(TextAlign.Center)
                              .backgroundColor('#E8E8E8')
                              .borderRadius(20)

                            Column() {
                              Row() {
                                Text(invite.inviterName)
                                  .fontSize(14)
                                  .fontColor('#333333')
                                  .fontWeight(FontWeight.Medium)
                                Text(' 邀请你加入 ')
                                  .fontSize(14)
                                  .fontColor('#666666')
                                Text(invite.groupName)
                                  .fontSize(14)
                                  .fontColor('#12B7F5')
                                  .fontWeight(FontWeight.Medium)
                              }

                              Text(invite.time)
                                .fontSize(12)
                                .fontColor('#999999')
                                .margin({ top: 4 })
                            }
                            .alignItems(HorizontalAlign.Start)
                            .layoutWeight(1)
                            .margin({ left: 12 })
                          }
                          .width('100%')

                          Row() {
                            Text('拒绝')
                              .fontSize(13)
                              .fontColor('#999999')
                              .backgroundColor('#F5F5F5')
                              .borderRadius(14)
                              .padding({ left: 20, right: 20, top: 6, bottom: 6 })
                              .onClick(() => {
                                this.rejectGroupInvite(invite.inviteId)
                              })
                            Text('同意')
                              .fontSize(13)
                              .fontColor('#FFFFFF')
                              .backgroundColor('#12B7F5')
                              .borderRadius(14)
                              .padding({ left: 20, right: 20, top: 6, bottom: 6 })
                              .margin({ left: 12 })
                              .onClick(() => {
                                this.acceptGroupInvite(invite.inviteId)
                              })
                          }
                          .width('100%')
                          .justifyContent(FlexAlign.End)
                          .margin({ top: 8 })

                          Divider().color('#F0F0F0').margin({ top: 12 })
                        }
                        .width('100%')
                        .padding({ left: 16, right: 16, top: 12 })
                      })
                    } else {
                      Column() {
                        Text('暂无群邀请')
                          .fontSize(14)
                          .fontColor('#CCCCCC')
                          .margin({ top: 16, bottom: 16 })
                      }
                      .width('100%')
                      .alignItems(HorizontalAlign.Center)
                    }
                  }
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                }

                Divider()
                  .color('#F0F0F0')
                  .height(8)

                Scroll() {
                  Row({ space: 0 }) {
                    ForEach(this.tabs, (tab: string, index: number) => {
                      Text(tab)
                        .fontSize(15)
                        .fontColor(this.currentTab === index ? '#12B7F5' : '#333333')
                        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
                        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                        .onClick(() => {
                          this.currentTab = index
                        })
                    })
                  }
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
                .backgroundColor('#FFFFFF')

                if (this.currentTab === 0) {
                  Column() {
                    ForEach(this.friendGroups, (group: FriendGroup, gIdx: number) => {
                      Column() {
                        this.GroupSectionItem(group.name, `${group.members.length}/0`, gIdx)
                        Divider().color('#E5E5E5').margin({ left: 16 })
                      }
                    })
                  }
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                }

                if (this.currentTab === 1) {
                  Column() {
                    ForEach(this.getSortedFriends(), (item: ContactItem) => {
                      Row() {
                        Stack({ alignContent: Alignment.BottomEnd }) {
                          Text(item.avatar)
                            .fontSize(28)
                            .width(44)
                            .height(44)
                            .textAlign(TextAlign.Center)
                            .backgroundColor('#E8E8E8')
                            .borderRadius(22)
                          Circle()
                            .width(10)
                            .height(10)
                            .fill(item.isOnline ? '#4CD964' : '#CCCCCC')
                            .margin({ right: 2, bottom: 2 })
                        }
                        Column() {
                          Text(item.name)
                            .fontSize(16)
                            .fontColor('#333333')
                          if (item.desc) {
                            Text(item.desc!)
                              .fontSize(12)
                              .fontColor('#999999')
                              .margin({ top: 2 })
                          }
                        }
                        .alignItems(HorizontalAlign.Start)
                        .margin({ left: 12 })
                        .layoutWeight(1)
                      }
                      .width('100%')
                      .height(64)
                      .padding({ left: 16, right: 16 })
                      .onClick(() => {
                        router.pushUrl({
                          url: 'pages/ContactDetailPage',
                          params: {
                            contactName: item.name,
                            contactAvatar: item.avatar,
                            isOnline: item.isOnline || false,
                            isFriend: true,
                            friendId: item.friendId ? String(item.friendId) : '',
                            qqNumber: item.qqNumber || '',
                            remark: item.desc || ''
                          }
                        })
                      })
                      Divider().color('#F0F0F0').margin({ left: 72 })
                    })
                  }
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                }

                if (this.currentTab === 2) {
                  Column() {
                    ForEach(this.groupList, (item: GroupItem) => {
                      Row() {
                        Text(item.avatar)
                          .fontSize(28)
                          .width(44)
                          .height(44)
                          .textAlign(TextAlign.Center)
                          .backgroundColor('#E8E8E8')
                          .borderRadius(10)
                        Column() {
                          Text(item.name)
                            .fontSize(16)
                            .fontColor('#333333')
                          Row() {
                            Text(item.memberCount)
                              .fontSize(12)
                              .fontColor('#999999')
                            if (item.lastMsg) {
                              Text(` · ${item.lastMsg}`)
                                .fontSize(12)
                                .fontColor('#CCCCCC')
                                .maxLines(1)
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                            }
                          }
                          .margin({ top: 2 })
                        }
                        .alignItems(HorizontalAlign.Start)
                        .margin({ left: 12 })
                        .layoutWeight(1)
                      }
                      .width('100%')
                      .height(64)
                      .padding({ left: 16, right: 16 })
                      .onClick(() => {
                        router.pushUrl({
                          url: 'pages/ChatPage',
                          params: {
                            chatName: item.name,
                            chatAvatar: item.avatar,
                            isGroup: true,
                            targetId: item.groupId ? String(item.groupId) : ''
                          }
                        })
                      })
                      Divider().color('#F0F0F0').margin({ left: 72 })
                    }, (item: GroupItem) => String(item.groupId) + '_' + String(this.groupRefreshKey))
                  }
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                }

                if (this.currentTab === 3) {
                  Column() {
                    ForEach(this.channelList, (item: ContactItem) => {
                      Row() {
                        Text(item.avatar)
                          .fontSize(28)
                          .width(44)
                          .height(44)
                          .textAlign(TextAlign.Center)
                          .backgroundColor('#E8E8E8')
                          .borderRadius(10)
                        Text(item.name)
                          .fontSize(16)
                          .fontColor('#333333')
                          .margin({ left: 12 })
                      }
                      .width('100%')
                      .height(64)
                      .padding({ left: 16, right: 16 })
                      Divider().color('#F0F0F0').margin({ left: 72 })
                    })
                  }
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                }

                if (this.currentTab === 4) {
                  Column() {
                    ForEach(this.botList, (item: ContactItem) => {
                      Row() {
                        Text(item.avatar)
                          .fontSize(28)
                          .width(44)
                          .height(44)
                          .textAlign(TextAlign.Center)
                          .backgroundColor('#E8E8E8')
                          .borderRadius(10)
                        Column() {
                          Text(item.name)
                            .fontSize(16)
                            .fontColor('#333333')
                          if (item.desc) {
                            Text(item.desc!)
                              .fontSize(12)
                              .fontColor('#999999')
                              .margin({ top: 2 })
                          }
                        }
                        .alignItems(HorizontalAlign.Start)
                        .margin({ left: 12 })
                      }
                      .width('100%')
                      .height(64)
                      .padding({ left: 16, right: 16 })
                      Divider().color('#F0F0F0').margin({ left: 72 })
                    })
                  }
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                }

                if (this.currentTab === 5) {
                  Column() {
                    ForEach(this.deviceList, (item: ContactItem) => {
                      Row() {
                        Text(item.avatar)
                          .fontSize(28)
                          .width(44)
                          .height(44)
                          .textAlign(TextAlign.Center)
                          .backgroundColor('#E8E8E8')
                          .borderRadius(10)
                        Column() {
                          Text(item.name)
                            .fontSize(16)
                            .fontColor('#333333')
                          if (item.desc) {
                            Text(item.desc!)
                              .fontSize(12)
                              .fontColor(item.desc === '在线' ? '#4CD964' : '#999999')
                              .margin({ top: 2 })
                          }
                        }
                        .alignItems(HorizontalAlign.Start)
                        .margin({ left: 12 })
                      }
                      .width('100%')
                      .height(64)
                      .padding({ left: 16, right: 16 })
                      Divider().color('#F0F0F0').margin({ left: 72 })
                    })
                  }
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                }
              }
              .width('100%')
            }
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F0F0F0')

      if (this.showMoveDialog) {
        Column() {
          Column() {
            Text('移动分组')
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
            Text(`将 ${this.moveFriendIndex >= 0 ? this.friendList[this.moveFriendIndex].name : ''} 移动到：`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12 })

            List() {
              ForEach(this.friendGroups, (group: FriendGroup) => {
                ListItem() {
                  Row() {
                    Text(group.name)
                      .fontSize(15)
                      .fontColor(group.id === this.moveFromGroup ? '#CCCCCC' : '#333333')
                      .layoutWeight(1)
                    if (group.id === this.moveFromGroup) {
                      Text('当前')
                        .fontSize(12)
                        .fontColor('#999999')
                    }
                  }
                  .width('100%')
                  .height(48)
                  .padding({ left: 16, right: 16 })
                  .onClick(() => {
                    if (group.id !== this.moveFromGroup) {
                      this.moveFriend(group.name)
                    }
                  })
                }
              })
            }
            .width('100%')
            .margin({ top: 12 })
            .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 16 })

            Row() {
              Text('取消')
                .fontSize(16)
                .fontColor('#999999')
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding({ top: 14, bottom: 14 })
                .onClick(() => {
                  this.showMoveDialog = false
                })
            }
            .width('100%')
            .margin({ top: 12 })
            .borderWidth({ top: 0.5 })
            .borderColor({ top: '#F0F0F0' })
          }
          .width(280)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding({ top: 24, left: 24, right: 24, bottom: 16 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showMoveDialog = false
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
