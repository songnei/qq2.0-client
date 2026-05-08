import router from '@ohos.router'
import { get, post, Api } from './HttpRequest'
import { promptAction } from '@kit.ArkUI'

interface CommentItem {
  id: number
  avatar: string
  name: string
  content: string
  time: string
}

interface SpacePost {
  id: number
  avatar: string
  name: string
  content: string
  time: string
  likes: number
  comments: CommentItem[]
  images?: string[]
  isLiked: boolean
  showComments: boolean
}

interface VisitorItem {
  avatar: string
  name: string
  time: string
}

interface SpaceCommentApiData {
  id: number
  userAvatar: string
  userNickname: string
  content: string
  createTime: string
}

interface SpacePostApiData {
  id: number
  userAvatar: string
  userNickname: string
  content: string
  createTime: string
  likeCount: number
  comments: SpaceCommentApiData[]
  imageUrls: string[]
  liked: boolean
}

interface NewPostBody {
  content: string
}

@Entry
@Component
export struct DynamicSubPage {
  @StorageProp('userAvatar') userAvatar: string = '🐶'
  @StorageProp('userNickname') userNickname: string = 'QQ用户'
  @State pageTitle: string = '空间动态'
  @State pageIcon: string = '⭐'
  @State showNewPost: boolean = false
  @State newPostContent: string = ''
  @State showVisitors: boolean = false
  @State commentInput: string = ''
  @State activeCommentPostId: number = -1

  private visitorList: VisitorItem[] = [
    { avatar: '👤', name: '李明', time: '1小时前' },
    { avatar: '👤', name: '王芳', time: '3小时前' },
    { avatar: '🐶', name: 'water', time: '5小时前' },
    { avatar: '👤', name: '余泰安', time: '昨天' },
    { avatar: '👤', name: '张小丽', time: '昨天' },
    { avatar: '👤', name: '刘伟', time: '2天前' }
  ]

  @State postList: SpacePost[] = [
    {
      id: 1,
      avatar: '👤',
      name: '谢文杰',
      content: '今天在图书馆学习了一整天，感觉收获满满！明天继续加油 💪',
      time: '2小时前',
      likes: 12,
      comments: [
        { id: 1, avatar: '👤', name: '陈宇航', content: '加油！一起努力！', time: '1小时前' },
        { id: 2, avatar: '🐶', name: 'water', content: '带带我', time: '45分钟前' }
      ],
      isLiked: false,
      showComments: false
    },
    {
      id: 2,
      avatar: '👤',
      name: '陈宇航',
      content: '新买的篮球鞋到了，颜值超高，周末去球场试试！',
      time: '5小时前',
      likes: 28,
      comments: [
        { id: 1, avatar: '👤', name: '谢文杰', content: '什么牌子的？', time: '4小时前' },
        { id: 2, avatar: '👤', name: '余泰安', content: '帅！给我也看看', time: '3小时前' },
        { id: 3, avatar: '👤', name: '李明', content: '多少钱入手的', time: '2小时前' }
      ],
      images: ['👟', '🏀', '🏟️'],
      isLiked: true,
      showComments: false
    },
    {
      id: 3,
      avatar: '🐶',
      name: 'water',
      content: '分享一首好听的歌：晴天 - 周杰伦 🎵',
      time: '昨天',
      likes: 45,
      comments: [
        { id: 1, avatar: '👤', name: '王芳', content: '经典！百听不厌', time: '昨天' },
        { id: 2, avatar: '👤', name: '陈宇航', content: '爷青回', time: '昨天' }
      ],
      isLiked: false,
      showComments: false
    },
    {
      id: 4,
      avatar: '👤',
      name: '余泰安',
      content: '成都的天气终于放晴了，出去走走 ☀️',
      time: '昨天',
      likes: 8,
      comments: [],
      images: ['🌤️', '🌳', '🌸', '🏞️'],
      isLiked: false,
      showComments: false
    }
  ]

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      if (params['title'] !== undefined) {
        this.pageTitle = params['title'] as string
      }
      if (params['icon'] !== undefined) {
        this.pageIcon = params['icon'] as string
      }
    }
    if (this.pageTitle === '空间动态' || this.pageTitle === '脑洞秀') {
      this.loadPosts()
    }
  }

  async loadPosts(): Promise<void> {
    try {
      const data = await get<SpacePostApiData[]>(Api.SPACE_FEED + '?pageSize=20')
      if (data && Array.isArray(data) && data.length > 0) {
        const result: SpacePost[] = []
        for (let i = 0; i < data.length; i++) {
          const p = data[i]
          const comments: CommentItem[] = []
          if (p.comments && Array.isArray(p.comments)) {
            for (let j = 0; j < p.comments.length; j++) {
              const c = p.comments[j]
              comments.push({
                id: c.id || 0,
                avatar: c.userAvatar || '👤',
                name: c.userNickname || '',
                content: c.content || '',
                time: this.formatPostTime(c.createTime || '')
              })
            }
          }
          result.push({
            id: p.id || 0,
            avatar: p.userAvatar || '👤',
            name: p.userNickname || '',
            content: p.content || '',
            time: this.formatPostTime(p.createTime || ''),
            likes: p.likeCount || 0,
            comments: comments,
            images: p.imageUrls,
            isLiked: p.liked,
            showComments: false
          })
        }
        this.postList = result
      }
    } catch (_e) {
    }
  }

  private formatPostTime(timeStr: string): string {
    if (!timeStr) return '刚刚'
    try {
      const now = new Date()
      const date = new Date(timeStr)
      const diffMs = now.getTime() - date.getTime()
      const diffMin = Math.floor(diffMs / (1000 * 60))
      if (diffMin < 1) return '刚刚'
      if (diffMin < 60) return diffMin + '分钟前'
      const diffHours = Math.floor(diffMin / 60)
      if (diffHours < 24) return diffHours + '小时前'
      const diffDays = Math.floor(diffHours / 24)
      if (diffDays < 30) return diffDays + '天前'
      return (date.getMonth() + 1) + '月' + date.getDate() + '日'
    } catch (_e) {
      return timeStr
    }
  }

  async toggleLike(postId: number): Promise<void> {
    try {
      await post<void>(Api.spaceLike(postId))
    } catch (_e) {
      // continue with local update
    }
    const newList: SpacePost[] = []
    for (let i = 0; i < this.postList.length; i++) {
      const post = this.postList[i]
      if (post.id === postId) {
        newList.push({
          id: post.id,
          avatar: post.avatar,
          name: post.name,
          content: post.content,
          time: post.time,
          likes: post.isLiked ? post.likes - 1 : post.likes + 1,
          comments: post.comments,
          images: post.images,
          isLiked: !post.isLiked,
          showComments: post.showComments
        })
      } else {
        newList.push(post)
      }
    }
    this.postList = newList
  }

  toggleComments(postId: number): void {
    const newList: SpacePost[] = []
    for (let i = 0; i < this.postList.length; i++) {
      const post = this.postList[i]
      if (post.id === postId) {
        const newPost: SpacePost = {
          id: post.id,
          avatar: post.avatar,
          name: post.name,
          content: post.content,
          time: post.time,
          likes: post.likes,
          comments: post.comments,
          images: post.images,
          isLiked: post.isLiked,
          showComments: !post.showComments
        }
        newList.push(newPost)
        this.activeCommentPostId = post.showComments ? -1 : postId
      } else {
        newList.push(post)
      }
    }
    this.postList = newList
  }

  async addComment(postId: number): Promise<void> {
    if (this.commentInput.trim().length === 0) {
      return
    }
    try {
      await post<void>(Api.spaceComment(postId) + '?content=' + encodeURIComponent(this.commentInput.trim()))
    } catch (_e) {
      promptAction.showToast({ message: '评论失败' })
      return
    }
    const newComment: CommentItem = {
      id: Date.now(),
      avatar: this.userAvatar,
      name: this.userNickname || '我',
      content: this.commentInput,
      time: '刚刚'
    }
    const newList: SpacePost[] = []
    for (let i = 0; i < this.postList.length; i++) {
      const post = this.postList[i]
      if (post.id === postId) {
        const newComments: CommentItem[] = []
        for (let j = 0; j < post.comments.length; j++) {
          newComments.push(post.comments[j])
        }
        newComments.push(newComment)
        const newPost: SpacePost = {
          id: post.id,
          avatar: post.avatar,
          name: post.name,
          content: post.content,
          time: post.time,
          likes: post.likes,
          comments: newComments,
          images: post.images,
          isLiked: post.isLiked,
          showComments: true
        }
        newList.push(newPost)
      } else {
        newList.push(post)
      }
    }
    this.postList = newList
    this.commentInput = ''
  }

  async submitNewPost(): Promise<void> {
    if (this.newPostContent.trim().length === 0) {
      return
    }
    try {
      const newPostBody: NewPostBody = { content: this.newPostContent.trim() }
      await post<void>(Api.SPACE_POST, newPostBody)
      promptAction.showToast({ message: '发布成功' })
    } catch (_e) {
      promptAction.showToast({ message: '发布失败' })
      return
    }
    const newPost: SpacePost = {
      id: Date.now(),
      avatar: this.userAvatar,
      name: this.userNickname || '我',
      content: this.newPostContent,
      time: '刚刚',
      likes: 0,
      comments: [],
      isLiked: false,
      showComments: false
    }
    const newList: SpacePost[] = [newPost]
    for (let i = 0; i < this.postList.length; i++) {
      newList.push(this.postList[i])
    }
    this.postList = newList
    this.newPostContent = ''
    this.showNewPost = false
  }

  @Builder
  VisitorBar() {
    Column() {
      Row() {
        Text('最近访客')
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
        Text(` (${this.visitorList.length})`)
          .fontSize(13)
          .fontColor('#999999')
        Blank()
        Text('查看全部 ›')
          .fontSize(13)
          .fontColor('#12B7F5')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .onClick(() => {
        this.showVisitors = !this.showVisitors
      })

      Row() {
        ForEach(this.visitorList.slice(0, 5), (visitor: VisitorItem) => {
          Column() {
            Text(visitor.avatar)
              .fontSize(24)
              .width(36)
              .height(36)
              .textAlign(TextAlign.Center)
              .backgroundColor('#F0F0F0')
              .borderRadius(18)
            Text(visitor.name)
              .fontSize(11)
              .fontColor('#666666')
              .maxLines(1)
              .margin({ top: 4 })
          }
          .width('18%')
          .alignItems(HorizontalAlign.Center)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 12 })

      if (this.showVisitors) {
        List() {
          ForEach(this.visitorList, (visitor: VisitorItem) => {
            ListItem() {
              Row() {
                Text(visitor.avatar)
                  .fontSize(22)
                  .width(32)
                  .height(32)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#F0F0F0')
                  .borderRadius(16)
                Text(visitor.name)
                  .fontSize(14)
                  .fontColor('#333333')
                  .margin({ left: 12 })
                  .layoutWeight(1)
                Text(visitor.time)
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })
            }
          })
        }
        .width('100%')
        .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 60 })
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  MemoryAlbum() {
    Column() {
      Row() {
        Text('📸')
          .fontSize(18)
        Text('那年今日')
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .margin({ left: 8 })
        Blank()
        Text('查看 ›')
          .fontSize(13)
          .fontColor('#12B7F5')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Row() {
        Column() {
          Text('🌤️')
            .fontSize(32)
            .width(72)
            .height(72)
            .textAlign(TextAlign.Center)
            .backgroundColor('#FFF8E1')
            .borderRadius(8)
          Text('1年前的今天')
            .fontSize(11)
            .fontColor('#999999')
            .margin({ top: 6 })
        }
        .width('33%')
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('🎓')
            .fontSize(32)
            .width(72)
            .height(72)
            .textAlign(TextAlign.Center)
            .backgroundColor('#E8F7FE')
            .borderRadius(8)
          Text('2年前的今天')
            .fontSize(11)
            .fontColor('#999999')
            .margin({ top: 6 })
        }
        .width('33%')
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('🎂')
            .fontSize(32)
            .width(72)
            .height(72)
            .textAlign(TextAlign.Center)
            .backgroundColor('#FCE4EC')
            .borderRadius(8)
          Text('3年前的今天')
            .fontSize(11)
            .fontColor('#999999')
            .margin({ top: 6 })
        }
        .width('33%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  PostItem(post: SpacePost) {
    Column() {
      Row() {
        Text(post.avatar)
          .fontSize(36)
        Column() {
          Text(post.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          Text(post.time)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }
      .width('100%')

      Text(post.content)
        .fontSize(15)
        .fontColor('#333333')
        .width('100%')
        .margin({ top: 12 })

      if (post.images && post.images.length > 0) {
        Row() {
          ForEach(post.images, (img: string) => {
            Text(img)
              .fontSize(40)
              .width(80)
              .height(80)
              .textAlign(TextAlign.Center)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .margin({ right: 8 })
          })
        }
        .width('100%')
        .margin({ top: 12 })
      }

      Row() {
        Row() {
          Text(post.isLiked ? '❤️' : '🤍')
            .fontSize(16)
          Text(`${post.likes}`)
            .fontSize(13)
            .fontColor(post.isLiked ? '#FA5151' : '#999999')
            .margin({ left: 4 })
        }
        .onClick(() => {
          this.toggleLike(post.id)
        })

        Row() {
          Text('💬')
            .fontSize(16)
          Text(`${post.comments.length}`)
            .fontSize(13)
            .fontColor('#999999')
            .margin({ left: 4 })
        }
        .margin({ left: 24 })
        .onClick(() => {
          this.toggleComments(post.id)
        })

        Row() {
          Text('🔄')
            .fontSize(16)
          Text('转发')
            .fontSize(13)
            .fontColor('#999999')
            .margin({ left: 4 })
        }
        .margin({ left: 24 })
      }
      .width('100%')
      .margin({ top: 12 })

      if (post.showComments && post.comments.length > 0) {
        Column() {
          ForEach(post.comments, (comment: CommentItem) => {
            Row() {
              Text(comment.avatar)
                .fontSize(20)
                .width(28)
                .height(28)
                .textAlign(TextAlign.Center)
                .backgroundColor('#F0F0F0')
                .borderRadius(14)
              Column() {
                Row() {
                  Text(comment.name)
                    .fontSize(13)
                    .fontColor('#12B7F5')
                  Text(` ${comment.time}`)
                    .fontSize(11)
                    .fontColor('#CCCCCC')
                }
                Text(comment.content)
                  .fontSize(13)
                  .fontColor('#333333')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 8 })
              .layoutWeight(1)
            }
            .width('100%')
            .margin({ top: 8 })
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8 })
        .margin({ top: 8 })
        .backgroundColor('#F8F8F8')
        .borderRadius(8)
      }

      if (post.showComments) {
        Row() {
          TextInput({ placeholder: '写评论...', text: this.commentInput })
            .layoutWeight(1)
            .height(36)
            .fontSize(14)
            .borderRadius(18)
            .backgroundColor('#F5F5F5')
            .onChange((value: string) => {
              this.commentInput = value
            })
          Text('发送')
            .fontSize(14)
            .fontColor('#12B7F5')
            .margin({ left: 12 })
            .onClick(() => {
              this.addComment(post.id)
            })
        }
        .width('100%')
        .margin({ top: 8 })
      }

      Divider()
        .color('#F0F0F0')
        .height(0.5)
        .margin({ top: 16 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
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
        Text(this.pageIcon)
          .fontSize(20)
          .margin({ left: 8 })
        Text(this.pageTitle)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 8 })
        Blank()
        Text('✏️')
          .fontSize(22)
          .onClick(() => {
            this.showNewPost = !this.showNewPost
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 16 })

      if (this.showNewPost) {
        Column() {
          TextArea({ placeholder: '分享你的新鲜事...', text: this.newPostContent })
            .width('100%')
            .height(120)
            .fontSize(15)
            .backgroundColor('#F8F8F8')
            .borderRadius(8)
            .onChange((value: string) => {
              this.newPostContent = value
            })

          Row() {
            Text('📷')
              .fontSize(22)
              .margin({ right: 16 })
            Text('😊')
              .fontSize(22)
              .margin({ right: 16 })
            Text('📍')
              .fontSize(22)
            Blank()
            Text('发布')
              .fontSize(15)
              .fontColor('#FFFFFF')
              .backgroundColor('#12B7F5')
              .borderRadius(16)
              .padding({ left: 20, right: 20, top: 8, bottom: 8 })
              .onClick(() => {
                this.submitNewPost()
              })
          }
          .width('100%')
          .margin({ top: 12 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 16 })
        .backgroundColor('#FFFFFF')

        Divider()
          .color('#F0F0F0')
          .height(8)
      }

      if (this.pageTitle === '空间动态' || this.pageTitle === '脑洞秀') {
        List({ space: 0 }) {
          ListItem() {
            this.VisitorBar()
          }

          ListItem() {
            Column() {
              Divider()
                .color('#F0F0F0')
                .height(8)
            }
          }

          ListItem() {
            this.MemoryAlbum()
          }

          ListItem() {
            Column() {
              Divider()
                .color('#F0F0F0')
                .height(8)
            }
          }

          ForEach(this.postList, (post: SpacePost) => {
            ListItem() {
              this.PostItem(post)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        Column() {
          Text(this.pageIcon)
            .fontSize(64)
            .margin({ top: 80 })
          Text(this.pageTitle)
            .fontSize(18)
            .fontColor('#333333')
            .margin({ top: 16 })
          Text('功能开发中，敬请期待...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
