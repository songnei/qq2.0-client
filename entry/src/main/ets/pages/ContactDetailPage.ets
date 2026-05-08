import router from '@ohos.router'
import { get, post, put, del, Api } from './HttpRequest'
import { promptAction } from '@kit.ArkUI'

interface ProfileItem {
  label: string
  value: string
}

interface FriendTag {
  id: number
  name: string
  isSelected: boolean
}

interface CommonGroup {
  avatar: string
  name: string
  memberCount: number
}

@Entry
@Component
struct ContactDetailPage {
  @State contactName: string = '联系人'
  @State contactAvatar: string = '👤'
  @State isOnline: boolean = false
  @State isFriend: boolean = true
  @State friendId: string = ''
  @State qqNumber: string = ''
  @State remark: string = ''
  @State isEditingRemark: boolean = false
  @State remarkInput: string = ''
  @State isSpecialCare: boolean = false
  @State isBlocked: boolean = false
  @State isHidden: boolean = false
  @State showTagPicker: boolean = false
  @State showCommonGroups: boolean = false
  @State showMoreActions: boolean = false
  @State showDialog: boolean = false
  @State dialogTitle: string = ''
  @State dialogContent: string = ''

  private profileItems: ProfileItem[] = [
    { label: 'QQ号', value: '123456789' },
    { label: '性别', value: '男' },
    { label: '年龄', value: '20岁' },
    { label: '生日', value: '1月1日' },
    { label: '所在地', value: '四川 成都' },
    { label: '学校', value: '电子科技大学成都学院' }
  ]

  @State tagList: FriendTag[] = [
    { id: 1, name: '同学', isSelected: true },
    { id: 2, name: '好友', isSelected: false },
    { id: 3, name: '家人', isSelected: false },
    { id: 4, name: '同事', isSelected: false },
    { id: 5, name: '老师', isSelected: false }
  ]

  private commonGroups: CommonGroup[] = [
    { avatar: '👥', name: '物联网2班', memberCount: 28 },
    { avatar: '👥', name: '学习交流群', memberCount: 15 },
    { avatar: '👥', name: '篮球爱好者', memberCount: 20 }
  ]

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      if (params['contactName'] !== undefined) {
        this.contactName = params['contactName'] as string
      }
      if (params['contactAvatar'] !== undefined) {
        this.contactAvatar = params['contactAvatar'] as string
      }
      if (params['isOnline'] !== undefined) {
        this.isOnline = params['isOnline'] as boolean
      }
      if (params['isFriend'] !== undefined) {
        this.isFriend = params['isFriend'] as boolean
      }
      if (params['friendId'] !== undefined) {
        this.friendId = params['friendId'] as string
      }
      if (params['qqNumber'] !== undefined) {
        this.qqNumber = params['qqNumber'] as string
        this.profileItems = [
          { label: 'QQ号', value: this.qqNumber },
          { label: '性别', value: '未知' },
          { label: '年龄', value: '' },
          { label: '生日', value: '' },
          { label: '所在地', value: '' },
          { label: '学校', value: '' }
        ]
      }
      if (params['remark'] !== undefined) {
        this.remark = params['remark'] as string
      }
    }
  }

  toggleTag(tagId: number): void {
    const newList: FriendTag[] = []
    for (let i = 0; i < this.tagList.length; i++) {
      const tag = this.tagList[i]
      if (tag.id === tagId) {
        newList.push({ id: tag.id, name: tag.name, isSelected: !tag.isSelected })
      } else {
        newList.push(tag)
      }
    }
    this.tagList = newList
  }

  @Builder
  RemarkSection() {
    Column() {
      Row() {
        Text('备注名')
          .fontSize(14)
          .fontColor('#999999')
          .width(72)

        if (this.isEditingRemark) {
          TextInput({ placeholder: '设置备注名', text: this.remarkInput })
            .layoutWeight(1)
            .height(36)
            .fontSize(14)
            .backgroundColor('#F5F5F5')
            .borderRadius(6)
            .onChange((value: string) => {
              this.remarkInput = value
            })
          Text('保存')
            .fontSize(14)
            .fontColor('#12B7F5')
            .margin({ left: 12 })
            .onClick(async () => {
              this.remark = this.remarkInput
              this.isEditingRemark = false
              if (this.friendId) {
                try {
                  await put<void>(Api.friendRemark(Number(this.friendId)) + '?remark=' + encodeURIComponent(this.remark))
                } catch (_e) {
                  // ignore
                }
              }
            })
          Text('取消')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ left: 12 })
            .onClick(() => {
              this.isEditingRemark = false
            })
        } else {
          Text(this.remark.length > 0 ? this.remark : '点击设置备注')
            .fontSize(14)
            .fontColor(this.remark.length > 0 ? '#333333' : '#CCCCCC')
            .layoutWeight(1)
          Text('✏️')
            .fontSize(16)
            .onClick(() => {
              this.remarkInput = this.remark
              this.isEditingRemark = true
            })
        }
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  TagSection() {
    Column() {
      Row() {
        Text('分组标签')
          .fontSize(14)
          .fontColor('#999999')
          .width(72)
        Row() {
          ForEach(this.tagList, (tag: FriendTag) => {
            if (tag.isSelected) {
              Text(tag.name)
                .fontSize(12)
                .fontColor('#12B7F5')
                .backgroundColor('#E8F7FE')
                .borderRadius(4)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .margin({ right: 6 })
            }
          })
        }
        .layoutWeight(1)

        Text('›')
          .fontSize(16)
          .fontColor('#CCCCCC')
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.showTagPicker = !this.showTagPicker
      })

      if (this.showTagPicker) {
        List() {
          ForEach(this.tagList, (tag: FriendTag) => {
            ListItem() {
              Row() {
                Text(tag.name)
                  .fontSize(14)
                  .fontColor('#333333')
                  .layoutWeight(1)
                if (tag.isSelected) {
                  Text('✓')
                    .fontSize(16)
                    .fontColor('#12B7F5')
                }
              }
              .width('100%')
              .height(44)
              .padding({ left: 88, right: 16 })
              .onClick(() => {
                this.toggleTag(tag.id)
              })
            }
          })
        }
        .width('100%')
        .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 88 })
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  RelationSection() {
    Column() {
      Row() {
        Text('特别关心')
          .fontSize(15)
          .fontColor('#333333')
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.isSpecialCare })
          .onChange((isOn: boolean) => {
            this.isSpecialCare = isOn
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
        Text('屏蔽此人')
          .fontSize(15)
          .fontColor(this.isBlocked ? '#FA5151' : '#333333')
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.isBlocked })
          .onChange((isOn: boolean) => {
            this.isBlocked = isOn
            if (isOn) {
              this.dialogTitle = '屏蔽确认'
              this.dialogContent = `确定要屏蔽 ${this.contactName} 吗？屏蔽后将不再收到对方的消息。`
              this.showDialog = true
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
        Text('隐藏会话')
          .fontSize(15)
          .fontColor('#333333')
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.isHidden })
          .onChange((isOn: boolean) => {
            this.isHidden = isOn
          })
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  CommonGroupSection() {
    Column() {
      Row() {
        Text('共同群聊')
          .fontSize(14)
          .fontColor('#999999')
          .layoutWeight(1)
        Text(`${this.commonGroups.length}个`)
          .fontSize(13)
          .fontColor('#CCCCCC')
        Text('›')
          .fontSize(16)
          .fontColor('#CCCCCC')
          .margin({ left: 4 })
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.showCommonGroups = !this.showCommonGroups
      })

      if (this.showCommonGroups) {
        List() {
          ForEach(this.commonGroups, (group: CommonGroup) => {
            ListItem() {
              Row() {
                Text(group.avatar)
                  .fontSize(22)
                  .width(36)
                  .height(36)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#F0F0F0')
                  .borderRadius(18)
                Column() {
                  Text(group.name)
                    .fontSize(14)
                    .fontColor('#333333')
                  Text(`${group.memberCount}人`)
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
                .layoutWeight(1)
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
    .backgroundColor('#FFFFFF')
  }

  @Builder
  ActionButtonSection() {
    Column() {
      if (this.isFriend) {
        Row() {
          Row() {
            Text('💬')
              .fontSize(22)
            Text('发消息')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .margin({ left: 6 })
          }
          .padding({ left: 24, right: 24, top: 12, bottom: 12 })
          .backgroundColor('#12B7F5')
          .borderRadius(22)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ChatPage',
              params: {
                chatName: this.contactName,
                chatAvatar: this.contactAvatar,
                isGroup: false,
                targetId: this.friendId
              }
            })
          })

          Row() {
            Text('📞')
              .fontSize(22)
            Text('语音通话')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ left: 6 })
          }
          .padding({ left: 24, right: 24, top: 12, bottom: 12 })
          .backgroundColor('#F5F5F5')
          .borderRadius(22)
          .margin({ left: 16 })
        }
        .width('100%')
        .padding({ top: 16, bottom: 12 })
        .justifyContent(FlexAlign.Center)

        Text('删除好友')
          .fontSize(15)
          .fontColor('#FA5151')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ bottom: 24, top: 8 })
          .onClick(() => {
            this.dialogTitle = '删除好友'
            this.dialogContent = `确定要删除好友 ${this.contactName} 吗？删除后将清空聊天记录。`
            this.showDialog = true
          })
      } else {
        Row() {
          Text('加为好友')
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#12B7F5')
            .borderRadius(22)
            .padding({ left: 32, right: 32, top: 12, bottom: 12 })
        }
        .width('100%')
        .padding({ top: 16, bottom: 24 })
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Row() {
          Text('‹')
            .fontSize(28)
            .fontColor('#FFFFFF')
            .onClick(() => {
              router.back()
            })
          Blank()
          Text('⋯')
            .fontSize(28)
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.showMoreActions = !this.showMoreActions
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 12, right: 16 })

        Column() {
          Text(this.contactAvatar)
            .fontSize(72)
            .width(88)
            .height(88)
            .textAlign(TextAlign.Center)
            .backgroundColor('rgba(255,255,255,0.3)')
            .borderRadius(44)

          Text(this.remark.length > 0 ? this.remark : this.contactName)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ top: 12 })

          if (this.remark.length > 0) {
            Text(`(${this.contactName})`)
              .fontSize(13)
              .fontColor('#999999')
              .margin({ top: 4 })
          }

          Row() {
            Circle()
              .width(8)
              .height(8)
              .fill(this.isOnline ? '#4CD964' : '#CCCCCC')
            Text(this.isOnline ? '在线' : '离线')
              .fontSize(13)
              .fontColor(this.isOnline ? '#4CD964' : '#999999')
              .margin({ left: 4 })
          }
          .margin({ top: 6 })

          Text('编辑个签，展示我的独特态度。')
            .fontSize(13)
            .fontColor('#999999')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ top: 20, bottom: 20 })
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#FFFFFF')

        Divider()
          .color('#F0F0F0')
          .height(8)

        Scroll() {
          Column() {
            this.RemarkSection()

            Divider()
              .color('#F0F0F0')
              .height(8)

            this.TagSection()

            Divider()
              .color('#F0F0F0')
              .height(8)

            List({ space: 0 }) {
              ForEach(this.profileItems, (item: ProfileItem) => {
                ListItem() {
                  Row() {
                    Text(item.label)
                      .fontSize(14)
                      .fontColor('#999999')
                      .width(64)

                    Text(item.value)
                      .fontSize(14)
                      .fontColor('#333333')
                      .layoutWeight(1)
                  }
                  .width('100%')
                  .height(48)
                  .padding({ left: 16, right: 16 })
                }
              })
            }
            .width('100%')
            .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 16, endMargin: 16 })

            Divider()
              .color('#F0F0F0')
              .height(8)

            this.RelationSection()

            Divider()
              .color('#F0F0F0')
              .height(8)

            this.CommonGroupSection()

            Divider()
              .color('#F0F0F0')
              .height(8)

            this.ActionButtonSection()
          }
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F0F0F0')

      if (this.showDialog) {
        Column() {
          Column() {
            Text(this.dialogTitle)
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
            Text(this.dialogContent)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12 })
              .textAlign(TextAlign.Center)
            Row() {
              Text('取消')
                .fontSize(16)
                .fontColor('#999999')
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding({ top: 14, bottom: 14 })
                .onClick(() => {
                  this.showDialog = false
                  this.isBlocked = false
                })
              Divider()
                .vertical(true)
                .height(44)
                .color('#F0F0F0')
              Text('确定')
                .fontSize(16)
                .fontColor('#12B7F5')
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding({ top: 14, bottom: 14 })
                .onClick(async () => {
                  this.showDialog = false
                  if (this.dialogTitle === '删除好友') {
                    if (this.friendId) {
                      try {
                        await del<void>(Api.friendDelete(Number(this.friendId)))
                        promptAction.showToast({ message: '已删除好友' })
                      } catch (_e) {
                        promptAction.showToast({ message: '删除失败' })
                      }
                    }
                    AppStorage.SetOrCreate('deletedFriendName', this.contactName)
                    router.back()
                  }
                })
            }
            .width('100%')
            .margin({ top: 20 })
            .borderWidth({ top: 0.5 })
            .borderColor({ top: '#F0F0F0' })
          }
          .width(280)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding({ top: 24, left: 24, right: 24, bottom: 0 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showDialog = false
        })
      }

      if (this.showMoreActions) {
        Column() {
          Column() {
            Row() {
              Text('设置备注')
                .fontSize(15)
                .fontColor('#333333')
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding({ top: 14, bottom: 14 })
                .onClick(() => {
                  this.showMoreActions = false
                  this.remarkInput = this.remark
                  this.isEditingRemark = true
                })
            }
            .width('100%')
            .borderWidth({ bottom: 0.5 })
            .borderColor({ bottom: '#F0F0F0' })

            Row() {
              Text('分享名片')
                .fontSize(15)
                .fontColor('#333333')
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding({ top: 14, bottom: 14 })
                .onClick(() => {
                  this.showMoreActions = false
                })
            }
            .width('100%')
            .borderWidth({ bottom: 0.5 })
            .borderColor({ bottom: '#F0F0F0' })

            Row() {
              Text('举报')
                .fontSize(15)
                .fontColor('#FA5151')
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding({ top: 14, bottom: 14 })
                .onClick(() => {
                  this.showMoreActions = false
                })
            }
            .width('100%')
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 16, right: 16, bottom: 8 })

          Row() {
            Text('取消')
              .fontSize(16)
              .fontColor('#333333')
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .padding({ top: 14, bottom: 14 })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 16, right: 16, bottom: 16 })
          .onClick(() => {
            this.showMoreActions = false
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          this.showMoreActions = false
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
