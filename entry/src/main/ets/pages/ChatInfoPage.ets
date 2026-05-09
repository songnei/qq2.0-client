import router from '@ohos.router'
import { get, post, put, del, Api } from './HttpRequest'
import promptAction from '@ohos.promptAction'

interface GroupMember {
  userId: number
  avatar: string
  name: string
  isAdmin: boolean
  isMuted: boolean
}

interface InfoMenuItem {
  icon: string
  title: string
  desc?: string
}

interface GroupAnnouncement {
  id: number
  title: string
  content: string
  publisher: string
  time: string
  isTop: boolean
}

interface GroupFile {
  id: number
  icon: string
  name: string
  size: string
  uploader: string
  time: string
}

interface GroupPoll {
  id: number
  question: string
  options: string[]
  votes: number[]
  totalVotes: number
  endTime: string
  isVoted: boolean
}

interface GroupDetailApiData {
  groupNumber: string
  description: string
  isMutedAll: number
  allowTempChat: number
}

interface MemberApiData {
  userId: number
  avatar: string
  nickname: string
  remark: string
  role: number
  isMuted: number
}

interface AnnouncementApiData {
  id: number
  title: string
  content: string
  publisherNickname: string
  publisherId: number
  createTime: string
  isTop: number
}

interface FileApiData {
  id: number
  fileType: string
  fileName: string
  fileSize: number
  uploaderNickname: string
  uploaderId: number
  createTime: string
}

interface PollApiData {
  id: number
  question: string
  options: string
  totalVotes: number
  endTime: string
}

@Entry
@Component
struct ChatInfoPage {
  @State chatName: string = '群聊信息'
  @State chatAvatar: string = '👥'
  @State isGroup: boolean = true
  @State groupId: number = 0
  @State isMuted: boolean = false
  @State isPinned: boolean = false
  @State showAnnouncements: boolean = false
  @State showFiles: boolean = false
  @State showPolls: boolean = false
  @State showManagement: boolean = false
  @State showMemberManage: boolean = false
  @State groupNotice: string = ''
  @State isGroupMuted: boolean = false
  @State allowTempChat: boolean = true
  @State isLoading: boolean = true
  @State groupNumber: string = ''

  @StorageProp('userId') currentUserId: string = ''
  @StorageProp('userNickname') currentNickname: string = ''

  @State memberList: GroupMember[] = []
  @State announcementList: GroupAnnouncement[] = []
  @State fileList: GroupFile[] = []
  @State pollList: GroupPoll[] = []
  @State myRole: number = 0

  private menuList: InfoMenuItem[] = [
    { icon: '🔍', title: '查找聊天记录' },
    { icon: '🖼️', title: '聊天背景' },
    { icon: '📌', title: '置顶聊天', desc: '' },
    { icon: '🔔', title: '消息免打扰', desc: '' },
    { icon: '👥', title: '群管理' },
    { icon: '🚫', title: '屏蔽此人' }
  ]

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
        this.groupId = Number(params['targetId'])
      }
    }
    if (this.isGroup && this.groupId > 0) {
      this.loadGroupInfo()
      this.loadMembers()
      this.loadAnnouncements()
      this.loadFiles()
      this.loadPolls()
    }
  }

  private async loadGroupInfo(): Promise<void> {
    try {
      const data = await get<GroupDetailApiData>(Api.groupDetail(this.groupId))
      this.groupNumber = data.groupNumber || ''
      this.groupNotice = data.description || ''
      this.isGroupMuted = (data.isMutedAll || 0) === 1
      this.allowTempChat = (data.allowTempChat || 1) === 1
    } catch (_e) {}
  }

  private async loadMembers(): Promise<void> {
    try {
      const data = await get<MemberApiData[]>(Api.groupMembers(this.groupId))
      const result: GroupMember[] = []
      let myRoleFound = 0
      const uid = Number(this.currentUserId) || 0
      for (let i = 0; i < data.length; i++) {
        const m = data[i]
        const userId = m.userId || 0
        if (uid > 0 && userId === uid) {
          myRoleFound = m.role || 0
        }
        result.push({
          userId: userId,
          avatar: m.avatar || '👤',
          name: m.nickname || m.remark || '成员',
          isAdmin: (m.role || 0) >= 1,
          isMuted: (m.isMuted || 0) === 1
        })
      }
      this.memberList = result
      this.myRole = myRoleFound
    } catch (_e) {}
  }

  private async loadAnnouncements(): Promise<void> {
    try {
      const data = await get<AnnouncementApiData[]>(Api.groupAnnouncements(this.groupId))
      const result: GroupAnnouncement[] = []
      for (let i = 0; i < data.length; i++) {
        const a = data[i]
        result.push({
          id: a.id || 0,
          title: a.title || '',
          content: a.content || '',
          publisher: a.publisherNickname || '',
          time: this.formatTime(a.createTime || ''),
          isTop: (a.isTop || 0) === 1
        })
      }
      this.announcementList = result
    } catch (_e) {}
  }

  private async loadFiles(): Promise<void> {
    try {
      const data = await get<FileApiData[]>(Api.groupFiles(this.groupId))
      const result: GroupFile[] = []
      for (let i = 0; i < data.length; i++) {
        const f = data[i]
        result.push({
          id: f.id || 0,
          icon: this.getFileIcon(f.fileType || ''),
          name: f.fileName || '',
          size: this.formatFileSize(f.fileSize || 0),
          uploader: f.uploaderNickname || '',
          time: this.formatTime(f.createTime || '').split(' ')[0]
        })
      }
      this.fileList = result
    } catch (_e) {}
  }

  private async loadPolls(): Promise<void> {
    try {
      const data = await get<PollApiData[]>(Api.groupPolls(this.groupId))
      const result: GroupPoll[] = []
      for (let i = 0; i < data.length; i++) {
        const p = data[i]
        let options: string[] = []
        try {
          options = JSON.parse(p.options || '[]')
        } catch (_e2) {
          options = []
        }
        result.push({
          id: p.id || 0,
          question: p.question || '',
          options: options,
          votes: options.map(() => 0),
          totalVotes: p.totalVotes || 0,
          endTime: p.endTime || '',
          isVoted: false
        })
      }
      this.pollList = result
    } catch (_e) {}
  }

  private getFileIcon(fileType: string): string {
    if (fileType.includes('image')) return '🖼️'
    if (fileType.includes('pdf')) return '📄'
    if (fileType.includes('word') || fileType.includes('document')) return '📊'
    if (fileType.includes('sheet') || fileType.includes('excel')) return '📝'
    if (fileType.includes('zip') || fileType.includes('rar')) return '📦'
    return '📁'
  }

  private formatFileSize(bytes: number): string {
    if (bytes < 1024) return bytes + 'B'
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + 'KB'
    if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + 'MB'
    return (bytes / (1024 * 1024 * 1024)).toFixed(1) + 'GB'
  }

  private formatTime(dateStr: string): string {
    if (!dateStr) return ''
    const d = new Date(dateStr)
    if (isNaN(d.getTime())) return dateStr
    const now = new Date()
    const pad = (n: number) => n.toString().padStart(2, '0')
    if (d.toDateString() === now.toDateString()) {
      return `${pad(d.getHours())}:${pad(d.getMinutes())}`
    }
    const yesterday = new Date(now)
    yesterday.setDate(yesterday.getDate() - 1)
    if (d.toDateString() === yesterday.toDateString()) {
      return `昨天 ${pad(d.getHours())}:${pad(d.getMinutes())}`
    }
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
  }

  @Builder
  AnnouncementSection() {
    Column() {
      Row() {
        Text('📢')
          .fontSize(20)
          .width(32)
        Text('群公告')
          .fontSize(15)
          .fontColor('#333333')
          .layoutWeight(1)
        Text(`${this.announcementList.length}条`)
          .fontSize(13)
          .fontColor('#999999')
        Text('›')
          .fontSize(16)
          .fontColor('#CCCCCC')
          .margin({ left: 4 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.showAnnouncements = !this.showAnnouncements
      })

      if (this.showAnnouncements) {
        Column() {
          ForEach(this.announcementList, (item: GroupAnnouncement) => {
            Column() {
              Row() {
                if (item.isTop) {
                  Text('置顶')
                    .fontSize(11)
                    .fontColor('#12B7F5')
                    .backgroundColor('#E8F7FE')
                    .borderRadius(4)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .margin({ right: 8 })
                }
                Text(item.title)
                  .fontSize(14)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')

              Text(item.content)
                .fontSize(13)
                .fontColor('#666666')
                .width('100%')
                .margin({ top: 8 })
                .maxLines(3)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Row() {
                Text(`${item.publisher} 发布`)
                  .fontSize(12)
                  .fontColor('#999999')
                Blank()
                Text(item.time)
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .width('100%')
              .margin({ top: 8 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor('#FFFFFF')
            .margin({ bottom: 1 })
          })
        }
        .width('100%')
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  FileSection() {
    Column() {
      Row() {
        Text('📁')
          .fontSize(20)
          .width(32)
        Text('群文件')
          .fontSize(15)
          .fontColor('#333333')
          .layoutWeight(1)
        Text(`${this.fileList.length}个`)
          .fontSize(13)
          .fontColor('#999999')
        Text('›')
          .fontSize(16)
          .fontColor('#CCCCCC')
          .margin({ left: 4 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.showFiles = !this.showFiles
      })

      if (this.showFiles) {
        List() {
          ForEach(this.fileList, (item: GroupFile) => {
            ListItem() {
              Row() {
                Text(item.icon)
                  .fontSize(24)
                  .width(40)
                  .height(40)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)

                Column() {
                  Text(item.name)
                    .fontSize(14)
                    .fontColor('#333333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                  Row() {
                    Text(item.size)
                      .fontSize(12)
                      .fontColor('#999999')
                    Text(` · ${item.uploader}`)
                      .fontSize(12)
                      .fontColor('#999999')
                    Text(` · ${item.time}`)
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .margin({ top: 4 })
                }
                .layoutWeight(1)
                .margin({ left: 12 })
              }
              .width('100%')
              .height(64)
              .padding({ left: 16, right: 16 })
            }
          })
        }
        .width('100%')
        .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 72 })
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  PollSection() {
    Column() {
      Row() {
        Text('📊')
          .fontSize(20)
          .width(32)
        Text('群投票')
          .fontSize(15)
          .fontColor('#333333')
          .layoutWeight(1)
        Text(`${this.pollList.length}个`)
          .fontSize(13)
          .fontColor('#999999')
        Text('›')
          .fontSize(16)
          .fontColor('#CCCCCC')
          .margin({ left: 4 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.showPolls = !this.showPolls
      })

      if (this.showPolls) {
        Column() {
          ForEach(this.pollList, (item: GroupPoll, pollIndex: number) => {
            Column() {
              Row() {
                Text(item.question)
                  .fontSize(15)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium)
                  .layoutWeight(1)
                if (item.isVoted) {
                  Text('已投票')
                    .fontSize(11)
                    .fontColor('#4CD964')
                    .backgroundColor('#E8F8E9')
                    .borderRadius(4)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                }
              }
              .width('100%')

              Column() {
                ForEach(item.options, (option: string, optIndex: number) => {
                  Column() {
                    Row() {
                      Text(option)
                        .fontSize(13)
                        .fontColor('#333333')
                        .layoutWeight(1)
                      Text(`${item.votes[optIndex]}票`)
                        .fontSize(12)
                        .fontColor('#999999')
                      Text(` ${Math.round(item.votes[optIndex] / item.totalVotes * 100)}%`)
                        .fontSize(12)
                        .fontColor('#12B7F5')
                    }
                    .width('100%')

                    Stack({ alignContent: Alignment.Start }) {
                      Row()
                        .width('100%')
                        .height(8)
                        .backgroundColor('#F0F0F0')
                        .borderRadius(4)
                      Row()
                        .width(`${Math.round(item.votes[optIndex] / item.totalVotes * 100)}%`)
                        .height(8)
                        .backgroundColor(item.isVoted ? '#12B7F5' : '#E0E0E0')
                        .borderRadius(4)
                    }
                    .width('100%')
                    .height(8)
                    .margin({ top: 6 })
                  }
                  .width('100%')
                  .margin({ top: 12 })
                })
              }
              .width('100%')
              .margin({ top: 12 })

              Row() {
                Text(`共${item.totalVotes}人参与`)
                  .fontSize(12)
                  .fontColor('#999999')
                Blank()
                Text(`截止: ${item.endTime}`)
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .width('100%')
              .margin({ top: 12 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            .backgroundColor('#FFFFFF')
            .margin({ bottom: 8 })
          })
        }
        .width('100%')
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  ManagementSection() {
    Column() {
      Row() {
        Text('⚙️')
          .fontSize(20)
          .width(32)
        Text('群管理')
          .fontSize(15)
          .fontColor('#333333')
          .layoutWeight(1)
        Text('›')
          .fontSize(16)
          .fontColor('#CCCCCC')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.showManagement = !this.showManagement
      })

      if (this.showManagement) {
        Column() {
          Row() {
            Text('群公告内容')
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
            Text('编辑')
              .fontSize(13)
              .fontColor('#12B7F5')
              .onClick(() => {})
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12 })

          Text(this.groupNotice)
            .fontSize(13)
            .fontColor('#666666')
            .width('100%')
            .padding({ left: 16, right: 16, top: 8, bottom: 12 })

          Divider()
            .color('#F0F0F0')
            .height(0.5)
            .margin({ left: 16, right: 16 })

          Row() {
            Text('全员禁言')
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.isGroupMuted })
              .onChange(async (isOn: boolean) => {
                this.isGroupMuted = isOn
                try {
                  await put<void>(Api.groupMuteAll(this.groupId) + '?muted=' + (isOn ? 'true' : 'false'))
                  promptAction.showToast({ message: isOn ? '已开启全员禁言' : '已关闭全员禁言' })
                } catch (_e) {
                  this.isGroupMuted = !isOn
                  promptAction.showToast({ message: '操作失败' })
                }
              })
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })

          Divider()
            .color('#F0F0F0')
            .height(0.5)
            .margin({ left: 16, right: 16 })

          Row() {
            Text('允许临时会话')
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.allowTempChat })
              .onChange((isOn: boolean) => {
                this.allowTempChat = isOn
              })
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })

          Divider()
            .color('#F0F0F0')
            .height(0.5)
            .margin({ left: 16, right: 16 })

          Row() {
            Text('成员管理')
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
            Text(`${this.memberList.length}人`)
              .fontSize(13)
              .fontColor('#999999')
            Text('›')
              .fontSize(16)
              .fontColor('#CCCCCC')
              .margin({ left: 4 })
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.showMemberManage = !this.showMemberManage
          })

          if (this.showMemberManage) {
            List() {
              ForEach(this.memberList, (member: GroupMember, index: number) => {
                ListItem() {
                  Row() {
                    Text(member.avatar)
                      .fontSize(24)
                      .width(36)
                      .height(36)
                      .textAlign(TextAlign.Center)
                      .backgroundColor('#F0F0F0')
                      .borderRadius(18)
                    Column() {
                      Text(member.name)
                        .fontSize(14)
                        .fontColor('#333333')
                      if (member.isAdmin) {
                        Text('管理员')
                          .fontSize(11)
                          .fontColor('#4CD964')
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: 12 })
                    .layoutWeight(1)

                    if (!member.isAdmin) {
                      Text('设为管理员')
                        .fontSize(12)
                        .fontColor('#12B7F5')
                        .onClick(async () => {
                          try {
                            await put<void>(Api.groupMemberRole(this.groupId, member.userId) + '?role=1')
                            member.isAdmin = true
                            promptAction.showToast({ message: '已设为管理员' })
                          } catch (_e) {
                            promptAction.showToast({ message: '操作失败' })
                          }
                        })
                    } else {
                      Text('取消管理员')
                        .fontSize(12)
                        .fontColor('#FF6B6B')
                        .onClick(async () => {
                          try {
                              await put<void>(Api.groupMemberRole(this.groupId, member.userId) + '?role=0')
                              member.isAdmin = false
                            promptAction.showToast({ message: '已取消管理员' })
                          } catch (_e) {
                            promptAction.showToast({ message: '操作失败' })
                          }
                        })
                    }
                  }
                  .width('100%')
                  .height(56)
                  .padding({ left: 16, right: 16 })
                }
              })
            }
            .width('100%')
            .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 68 })
          }
        }
        .width('100%')
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
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

        Text(this.isGroup ? '群聊信息' : '好友信息')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 12 })

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 16 })

      Scroll() {
        Column() {
          Column() {
            Text(this.chatAvatar)
              .fontSize(64)

            Text(this.chatName)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ top: 12 })

            Text(this.isGroup ? (this.groupNumber ? `群号: ${this.groupNumber}` : '') : 'QQ号: 123456789')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ top: 6 })
          }
          .width('100%')
          .padding({ top: 20, bottom: 20 })
          .alignItems(HorizontalAlign.Center)

          Divider()
            .color('#F0F0F0')
            .height(8)

          if (this.isGroup) {
            Column() {
              Row() {
                Text(`群成员 (${this.memberList.length})`)
                  .fontSize(15)
                  .fontColor('#333333')
                Blank()
                Text('邀请好友')
                  .fontSize(13)
                  .fontColor('#12B7F5')
                  .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                  .border({ width: 1, color: '#12B7F5', radius: 12 })
                  .margin({ right: 8 })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/InviteFriendsPage',
                      params: {
                        groupId: this.groupId,
                        groupName: this.chatName
                      }
                    })
                  })
                Text('管理群成员 ›')
                  .fontSize(13)
                  .fontColor('#999999')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.memberList, (member: GroupMember) => {
                  Column() {
                    Text(member.avatar)
                      .fontSize(32)
                      .width(44)
                      .height(44)
                      .textAlign(TextAlign.Center)
                      .backgroundColor('#F0F0F0')
                      .borderRadius(22)
                    Text(member.name)
                      .fontSize(12)
                      .fontColor('#333333')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .margin({ top: 4 })
                    if (member.isAdmin) {
                      Text('管理员')
                        .fontSize(10)
                        .fontColor('#FFFFFF')
                        .backgroundColor('#4CD964')
                        .borderRadius(4)
                        .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                        .margin({ top: 2 })
                    }
                  }
                  .width('16%')
                  .margin({ bottom: 12 })
                  .alignItems(HorizontalAlign.Center)
                })
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
          }

          Divider()
            .color('#F0F0F0')
            .height(8)

          if (this.isGroup) {
            this.AnnouncementSection()

            Divider()
              .color('#F0F0F0')
              .height(8)

            this.FileSection()

            Divider()
              .color('#F0F0F0')
              .height(8)

            this.PollSection()

            Divider()
              .color('#F0F0F0')
              .height(8)

            this.ManagementSection()

            Divider()
              .color('#F0F0F0')
              .height(8)
          }

          List({ space: 0 }) {
            ForEach(this.menuList, (item: InfoMenuItem, index: number) => {
              ListItem() {
                Row() {
                  Text(item.icon)
                    .fontSize(20)
                    .width(32)

                  Text(item.title)
                    .fontSize(15)
                    .fontColor('#333333')
                    .layoutWeight(1)

                  if (item.title === '消息免打扰' || item.title === '置顶聊天') {
                    Toggle({ type: ToggleType.Switch, isOn: item.title === '消息免打扰' ? this.isMuted : this.isPinned })
                      .onChange((isOn: boolean) => {
                        if (item.title === '消息免打扰') {
                          this.isMuted = isOn
                        } else {
                          this.isPinned = isOn
                        }
                      })
                  } else {
                    Text('›')
                      .fontSize(16)
                      .fontColor('#CCCCCC')
                  }
                }
                .width('100%')
                .height(56)
                .padding({ left: 16, right: 16 })
              }
            })
          }
          .width('100%')
          .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 56 })

          Divider()
            .color('#F0F0F0')
            .height(8)

          Row() {
            Text('🚫')
              .fontSize(20)
              .width(32)
            Text('举报')
              .fontSize(15)
              .fontColor('#FA5151')
              .layoutWeight(1)
            Text('›')
              .fontSize(16)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })

          if (this.isGroup) {
            Divider()
              .color('#F0F0F0')
              .height(8)

            if (this.myRole === 2) {
              Row() {
                Text('解散该群')
                  .fontSize(15)
                  .fontColor('#FA5151')
              }
              .width('100%')
              .height(56)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                AlertDialog.show({
                  title: '解散群聊',
                  message: `确定要解散"${this.chatName}"吗？此操作不可撤销。`,
                  primaryButton: {
                    value: '取消',
                    action: () => {}
                  },
                  secondaryButton: {
                    value: '解散',
                    fontColor: '#FA5151',
                    action: async () => {
                      try {
                        await del<void>(Api.groupDelete(this.groupId))
                        promptAction.showToast({ message: '群聊已解散' })
                        AppStorage.setOrCreate<number>('msgPageRefresh', Date.now())
                        router.clear()
                        router.pushUrl({ url: 'pages/MainPage' })
                      } catch (_e) {
                        promptAction.showToast({ message: '解散失败' })
                      }
                    }
                  }
                })
              })
            } else {
              Row() {
                Text('退出该群')
                  .fontSize(15)
                  .fontColor('#FA5151')
              }
              .width('100%')
              .height(56)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                AlertDialog.show({
                  title: '退出群聊',
                  message: `确定要退出"${this.chatName}"吗？`,
                  primaryButton: {
                    value: '取消',
                    action: () => {}
                  },
                  secondaryButton: {
                    value: '退出',
                    fontColor: '#FA5151',
                    action: async () => {
                      try {
                        await post<void>(Api.groupExit(this.groupId))
                        promptAction.showToast({ message: '已退出群聊' })
                        AppStorage.setOrCreate<number>('msgPageRefresh', Date.now())
                        router.clear()
                        router.pushUrl({ url: 'pages/MainPage' })
                      } catch (_e) {
                        promptAction.showToast({ message: '退出失败' })
                      }
                    }
                  }
                })
              })
            }
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
  }
}
