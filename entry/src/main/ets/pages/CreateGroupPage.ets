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
}

interface CreateGroupBody {
  name: string
  avatar: string
  description: string
  memberIds: number[]
}

interface GroupVO {
  id: number
  groupNumber: string
  name: string
  avatar: string
  description: string
  ownerId: number
  ownerNickname: string
  memberCount: number
}

@Entry
@Component
struct CreateGroupPage {
  @State groupName: string = ''
  @State groupDesc: string = ''
  @State friendList: SelectableFriend[] = []
  @State isLoading: boolean = false
  @State isCreating: boolean = false
  @State searchText: string = ''

  aboutToAppear(): void {
    this.loadFriends()
  }

  private isValidAvatar(val: string): boolean {
    if (!val || val.length === 0) return false
    if (val.length > 10) return true
    const lower = val.toLowerCase()
    if (lower === 'avatar' || lower === 'null' || lower === 'undefined' || lower === 'none') return false
    return true
  }

  async loadFriends(): Promise<void> {
    this.isLoading = true
    try {
      const data = await get<FriendApiData[]>(Api.FRIEND_LIST)
      if (data && Array.isArray(data)) {
        const result: SelectableFriend[] = []
        for (let i = 0; i < data.length; i++) {
          const f = data[i]
          const name = f.remark || f.nickname || f.friendNickname || ''
          const avatarVal = this.isValidAvatar(f.friendAvatar) ? f.friendAvatar : '👤'
          result.push({
            friendId: f.friendId || f.id || 0,
            avatar: avatarVal,
            name: name,
            selected: false
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
      if (this.friendList[i].selected) {
        count++
      }
    }
    return count
  }

  toggleSelect(index: number): void {
    const filtered = this.getFilteredFriends()
    if (index < 0 || index >= filtered.length) return
    const target = filtered[index]
    const newList: SelectableFriend[] = []
    for (let i = 0; i < this.friendList.length; i++) {
      const item = this.friendList[i]
      if (item.friendId === target.friendId) {
        newList.push({
          friendId: item.friendId,
          avatar: item.avatar,
          name: item.name,
          selected: !item.selected
        })
      } else {
        newList.push(item)
      }
    }
    this.friendList = newList
  }

  async doCreate(): Promise<void> {
    if (this.groupName.trim().length === 0) {
      promptAction.showToast({ message: '请输入群名称' })
      return
    }
    this.isCreating = true
    try {
      const body: CreateGroupBody = {
        name: this.groupName.trim(),
        avatar: '👥',
        description: this.groupDesc.trim(),
        memberIds: []
      }
      const result = await post<GroupVO>(Api.GROUP_CREATE, body)
      if (result && result.id) {
        const inviteIds: number[] = []
        for (let i = 0; i < this.friendList.length; i++) {
          if (this.friendList[i].selected) {
            inviteIds.push(this.friendList[i].friendId)
          }
        }
        if (inviteIds.length > 0) {
          await post<void>(Api.GROUP_INVITE + result.id + '/invite', inviteIds)
          promptAction.showToast({ message: '创建成功，邀请已发送' })
        } else {
          promptAction.showToast({ message: '创建成功' })
        }
        AppStorage.setOrCreate<number>('msgPageRefresh', Date.now())
        router.replaceUrl({
          url: 'pages/ChatPage',
          params: {
            chatName: result.name || this.groupName.trim(),
            chatAvatar: result.avatar || '👥',
            isGroup: true,
            targetId: String(result.id)
          }
        })
      }
    } catch (_e) {
      promptAction.showToast({ message: '创建失败' })
    } finally {
      this.isCreating = false
    }
  }

  @Builder
  SelectedBar() {
    if (this.getSelectedCount() === 0) {
      Row() {
        Text('选择邀请的好友（可选）')
          .fontSize(14)
          .fontColor('#CCCCCC')
      }
      .width('100%')
      .height(64)
      .padding({ left: 16, right: 16 })
    } else {
      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.friendList, (item: SelectableFriend) => {
            if (item.selected) {
              Column() {
                Text(item.avatar)
                  .fontSize(24)
                  .width(40)
                  .height(40)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#E8E8E8')
                  .borderRadius(20)
                Text(item.name)
                  .fontSize(11)
                  .fontColor('#333333')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width(48)
                  .textAlign(TextAlign.Center)
                  .margin({ top: 4 })
              }
              .width(48)
            }
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(72)
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
        Text('创建群聊')
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

      Column() {
        Row() {
          Text('群名称')
            .fontSize(15)
            .fontColor('#333333')
            .width(72)
          TextInput({ placeholder: '请输入群名称', text: this.groupName })
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor('transparent')
            .onChange((value: string) => {
              this.groupName = value
            })
        }
        .width('100%')
        .height(52)
        .padding({ left: 16, right: 16 })

        Divider().color('#F0F0F0').margin({ left: 16 })

        Row() {
          Text('群描述')
            .fontSize(15)
            .fontColor('#333333')
            .width(72)
          TextInput({ placeholder: '请输入群描述（可选）', text: this.groupDesc })
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor('transparent')
            .onChange((value: string) => {
              this.groupDesc = value
            })
        }
        .width('100%')
        .height(52)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')

      Divider().color('#F0F0F0').height(8)

      Row() {
        Text('邀请好友')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        Blank()
        Text(this.getSelectedCount() + '人已选')
          .fontSize(13)
          .fontColor('#12B7F5')
      }
      .width('100%')
      .height(44)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      this.SelectedBar()

      Divider().color('#F0F0F0').margin({ left: 16 })

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

                Text(item.name)
                  .fontSize(15)
                  .fontColor('#333333')
                  .margin({ left: 12 })
                  .layoutWeight(1)

                if (item.selected) {
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

      Button(this.isCreating ? '创建中...' : '创建群聊')
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor(this.isCreating ? '#99D6F0' : '#12B7F5')
        .borderRadius(24)
        .height(44)
        .width('80%')
        .margin({ top: 8, bottom: 24 })
        .onClick(() => {
          if (!this.isCreating) {
            this.doCreate()
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
