import router from '@ohos.router'
import { login, getToken } from './HttpRequest'
import { promptAction } from '@kit.ArkUI'
import { connect as connectWs } from './WsManager'

@Entry
@Component
struct LoginPage {
  @State account: string = ''
  @State password: string = ''
  @State showPassword: boolean = false
  @State isLoading: boolean = false

  aboutToAppear(): void {
    const token = getToken()
    if (token) {
      connectWs()
      router.replaceUrl({ url: 'pages/MainPage' })
    }
  }

  async handleLogin(): Promise<void> {
    if (!this.account) {
      promptAction.showToast({ message: '请输入账号' })
      return
    }
    if (!this.password) {
      promptAction.showToast({ message: '请输入密码' })
      return
    }

    this.isLoading = true
    try {
      await login(this.account, this.password)
      connectWs()
      promptAction.showToast({ message: '登录成功' })
      router.replaceUrl({ url: 'pages/MainPage' })
    } catch (err) {
      const error = err as Error
      promptAction.showToast({ message: error.message || '登录失败' })
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          Text('登录')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ top: 60 })
        }
        .width('100%')
        .height('100%')

        Text('‹')
          .fontSize(24)
          .margin({ top: 60, left: 16 })
          .onClick(() => {
            router.back()
          })
      }
      .width('100%')
      .height(120)

      Column({ space: 24 }) {
        Column({ space: 16 }) {
          Column() {
            TextInput({ placeholder: 'QQ号/手机号/邮箱', text: this.account })
              .fontSize(16)
              .onChange((value: string) => {
                this.account = value
              })
            Divider()
              .color('#E5E5E5')
          }
          .width('100%')
          .padding({ bottom: 12 })

          Column() {
            Row() {
              TextInput({ placeholder: '请输入密码', text: this.password })
                .type(this.showPassword ? InputType.Normal : InputType.Password)
                .fontSize(16)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.password = value
                })

              Text(this.showPassword ? '👁️' : '👁️‍🗨️')
                .fontSize(20)
                .onClick(() => {
                  this.showPassword = !this.showPassword
                })
            }
            .width('100%')
            Divider()
              .color('#E5E5E5')
          }
          .width('100%')
          .padding({ bottom: 12 })
        }
        .width('100%')
        .padding(24)

        Button(this.isLoading ? '登录中...' : '登录')
          .width('90%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#12B7F5')
          .borderRadius(24)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleLogin()
          })

        Row() {
          Text('忘记密码？')
            .fontSize(14)
            .fontColor('#12B7F5')
          Blank()
          Text('新用户注册')
            .fontSize(14)
            .fontColor('#12B7F5')
            .onClick(() => {
              router.pushUrl({ url: 'pages/RegisterPage' })
            })
        }
        .width('90%')
        .padding({ top: 16 })
      }
      .width('100%')
      .layoutWeight(1)

      Column({ space: 16 }) {
        Text('登录即代表同意')
          .fontSize(12)
          .fontColor('#999999')

        Row({ space: 8 }) {
          Text('《用户协议》')
            .fontSize(12)
            .fontColor('#12B7F5')
          Text('《隐私政策》')
            .fontSize(12)
            .fontColor('#12B7F5')
        }
      }
      .width('100%')
      .padding({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
