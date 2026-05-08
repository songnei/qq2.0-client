import router from '@ohos.router'
import { sendSmsCode, register } from './HttpRequest'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct RegisterPage {
  @State phone: string = ''
  @State code: string = ''
  @State password: string = ''
  @State showPassword: boolean = false
  @State isLoading: boolean = false
  @State countdown: number = 0
  private timer: number = -1

  aboutToDisappear(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer)
    }
  }

  async handleSendCode(): Promise<void> {
    if (!this.phone || this.phone.length !== 11) {
      promptAction.showToast({ message: '请输入正确的手机号' })
      return
    }
    if (this.countdown > 0) {
      return
    }

    try {
      const code = await sendSmsCode(this.phone, 1)
      promptAction.showToast({ message: code ? ('验证码：' + code) : '验证码已发送' })
      this.countdown = 60
      this.timer = setInterval(() => {
        this.countdown--
        if (this.countdown <= 0) {
          clearInterval(this.timer)
          this.timer = -1
        }
      }, 1000)
    } catch (err) {
      const error = err as Error
      promptAction.showToast({ message: error.message || '发送失败' })
    }
  }

  async handleRegister(): Promise<void> {
    if (!this.phone || this.phone.length !== 11) {
      promptAction.showToast({ message: '请输入正确的手机号' })
      return
    }
    if (!this.code) {
      promptAction.showToast({ message: '请输入验证码' })
      return
    }
    if (!this.password || this.password.length < 6) {
      promptAction.showToast({ message: '密码至少6位' })
      return
    }

    this.isLoading = true
    try {
      await register(this.phone, this.code, this.password)
      promptAction.showToast({ message: '注册成功' })
      router.replaceUrl({ url: 'pages/MainPage' })
    } catch (err) {
      const error = err as Error
      promptAction.showToast({ message: error.message || '注册失败' })
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          Text('注册')
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
            TextInput({ placeholder: '请输入手机号', text: this.phone })
              .type(InputType.PhoneNumber)
              .fontSize(16)
              .onChange((value: string) => {
                this.phone = value
              })
            Divider()
              .color('#E5E5E5')
          }
          .width('100%')
          .padding({ bottom: 12 })

          Column() {
            Row() {
              TextInput({ placeholder: '请输入验证码', text: this.code })
                .type(InputType.Number)
                .fontSize(16)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.code = value
                })

              Text(this.countdown > 0 ? this.countdown + 's' : '获取验证码')
                .fontSize(14)
                .fontColor(this.countdown > 0 ? '#999999' : '#12B7F5')
                .onClick(() => {
                  this.handleSendCode()
                })
            }
            .width('100%')
            Divider()
              .color('#E5E5E5')
          }
          .width('100%')
          .padding({ bottom: 12 })

          Column() {
            Row() {
              TextInput({ placeholder: '请设置密码', text: this.password })
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

        Button(this.isLoading ? '注册中...' : '注册')
          .width('90%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#12B7F5')
          .borderRadius(24)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleRegister()
          })

        Row() {
          Text('已有账号？')
            .fontSize(14)
            .fontColor('#999999')
          Text('去登录')
            .fontSize(14)
            .fontColor('#12B7F5')
            .onClick(() => {
              router.replaceUrl({ url: 'pages/LoginPage' })
            })
        }
        .width('90%')
        .padding({ top: 16 })
      }
      .width('100%')
      .layoutWeight(1)

      Column({ space: 16 }) {
        Text('注册即代表同意')
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
