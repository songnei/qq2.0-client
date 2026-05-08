import router from '@ohos.router'
import { get, post, Api } from './HttpRequest'
import { promptAction } from '@kit.ArkUI'

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

interface SelectableFriend {
  friendId: number
  avatar: string
  name: string
  selected: boolean
  isMember: boolean
}

@Entry
@Component
struct InviteFriendsPage {
  @State groupId: number = 0
  @State groupName: string = ''
  @State friendList: SelectableFriend[] = []
  @State isLoading: boolean = false
  @State isInviting: boolean = false
  @State searchText: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      if (params['groupId'] !== undefined) {
        this.groupId = Number(params['groupId'])
      }
      if (params['groupName'] !== undefined) {
        this.groupName = params['groupName'] as string
      }
    }
    this.loadData()
  }

  private isValidAvatar(val: string): boolean {
    if (!val || val.length === 0) return false
    if (val.length > 10) return true
    const lower = val.toLowerCase()
    if (lower === 'avatar' || lower === 'null' || lower === 'undefined' || lower === 'none') return false
    return true
  }

  async loadData(): Promise<void> {
    this.isLoading = true
    try {
      const memberIds: number[] = []
      if (this.groupId > 0) {
        interface MemberBrief { userId: number }
        const members = await get<MemberBrief[]>(Api.groupMembers(this.groupId))
        if (members && Array.isArray(members)) {
          for (let i = 0; i < members.length; i++) {
            memberIds.push(members[i].userId || 0)
          }
        }
      }

      const data = await get<FriendApiData[]>(Api.FRIEND_LIST)
      if (data && Array.isArray(data)) {
        const result: SelectableFriend[] = []
        for (let i = 0; i < data.length; i++) {
          const f = data[i]
          const fid = f.friendId || f.id || 0
          const already = memberIds.indexOf(fid) >= 0
          const name = f.remark || f.nickname || f.friendNickname || ''
          const avatarVal = this.isValidAvatar(f.friendAvatar) ? f.friendAvatar : '👤'
          result.push({
            friendId: fid,
            avatar: avatarVal,
            name: name,
            selected: false,
            isMember: already
          })
        }
        this.friendList = result
      }
    } catch (_e) {
      promptAction.showToast({ message: '加载好友列表失败' })
    } finally {
      this.isLoading = false
    }
  }

  getFilteredFriends(): SelectableFriend[] {
    if (this.searchText.trim().length === 0) {
      return this.friendList
    }
    const keyword = this.searchText.trim()
    const result: SelectableFriend[] = []
    for (let i = 0; i < this.friendList.length; i++) {
      if (this.friendList[i].name.indexOf(keyword) >= 0) {
        result.push(this.friendList[i])
      }
    }
    return result
  }

  getSelectedCount(): number {
    let count = 0
    for (let i = 0; i < this.friendList.length; i++) {
      if (this.friendList[i].selected && !this.friendList[i].isMember) {
        count++
      }
    }
    return count
  }

  toggleSelect(index: number): void {
    const filtered = this.getFilteredFriends()
    if (index < 0 || index >= filtered.length) return
    const target = filtered[index]
    if (target.isMember) return
    const newList: SelectableFriend[] = []
    for (let i = 0; i < this.friendList.length; i++) {
      const item = this.friendList[i]
      if (item.friendId === target.friendId) {
        newList.push({
          friendId: item.friendId,
          avatar: item.avatar,
          name: item.name,
          selected: !item.selected,
          isMember: item.isMember
        })
      } else {
        newList.push(item)
      }
    }
    this.friendList = newList
  }

  async doInvite(): Promise<void> {
    if (this.getSelectedCount() === 0) {
      promptAction.showToast({ message: '请至少选择一位好友' })
      return
    }
    this.isInviting = true
    try {
      const inviteIds: number[] = []
      for (let i = 0; i < this.friendList.length; i++) {
        if (this.friendList[i].selected && !this.friendList[i].isMember) {
          inviteIds.push(this.friendList[i].friendId)
        }
      }
      await post<void>(Api.groupInvite(this.groupId), inviteIds)
      promptAction.showToast({ message: '邀请已发送' })
      AppStorage.setOrCreate<number>('msgPageRefresh', Date.now())
      router.back()
    } catch (_e) {
      promptAction.showToast({ message: '邀请发送失败' })
    } finally {
      this.isInviting = false
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
        Text('邀请好友')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 12 })
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 16 })

      Divider().color('#F0F0F0')

      Row() {
        Text('群聊：')
          .fontSize(14)
          .fontColor('#999999')
        Text(this.groupName)
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
        Blank()
        Text(this.getSelectedCount() + '人已选')
          .fontSize(13)
          .fontColor('#12B7F5')
      }
      .width('100%')
      .height(44)
      .padding({ left: 16, right: 16 })

      Row() {
        Text('🔍')
          .fontSize(16)
          .margin({ left: 12 })
        TextInput({ placeholder: '搜索好友', text: this.searchText })
          .layoutWeight(1)
          .height(36)
          .fontSize(14)
          .backgroundColor('transparent')
          .margin({ left: 6 })
          .onChange((value: string) => {
            this.searchText = value
          })
      }
      .width('92%')
      .height(40)
      .backgroundColor('#F5F5F5')
      .borderRadius(20)
      .margin({ top: 8, left: 16, right: 16 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#12B7F5')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.getFilteredFriends(), (item: SelectableFriend, index: number) => {
            ListItem() {
              Row() {
                Text(item.avatar)
                  .fontSize(28)
                  .width(40)
                  .height(40)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#E8E8E8')
                  .borderRadius(20)

                Column() {
                  Text(item.name)
                    .fontSize(15)
                    .fontColor('#333333')
                  if (item.isMember) {
                    Text('已在群中')
                      .fontSize(11)
                      .fontColor('#4CD964')
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({ left: 12 })

                if (item.isMember) {
                  Text('已加入')
                    .fontSize(12)
                    .fontColor('#CCCCCC')
                } else if (item.selected) {
                  Text('✓')
                    .fontSize(18)
                    .fontColor('#FFFFFF')
                    .width(24)
                    .height(24)
                    .textAlign(TextAlign.Center)
                    .backgroundColor('#12B7F5')
                    .borderRadius(12)
                } else {
                  Text('')
                    .width(24)
                    .height(24)
                    .borderRadius(12)
                    .borderWidth(1.5)
                    .borderColor('#DDDDDD')
                }
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                this.toggleSelect(index)
              })
            }
          })
        }
        .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 68 })
        .width('100%')
        .layoutWeight(1)
        .margin({ top: 8 })
      }

      Button(this.isInviting ? '发送中...' : '发送邀请')
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor(this.isInviting ? '#99D6F0' : '#12B7F5')
        .borderRadius(24)
        .height(44)
        .width('80%')
        .margin({ top: 8, bottom: 24 })
        .onClick(() => {
          if (!this.isInviting) {
            this.doInvite()
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
