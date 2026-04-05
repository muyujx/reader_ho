import router from '@ohos.router';
import { loginApi, registerApi } from '@ohos/bookshelf';
import { userStore, loginStateStore } from '@ohos/common';

@Entry
@Component
struct LoginPage {
  @State isLoginMode: boolean = true;
  @State account: string = '';
  @State password: string = '';
  @State regAccount: string = '';
  @State regPassword: string = '';
  @State regPasswordConfirm: string = '';
  @State errorMessage: string = '';
  @State isLoading: boolean = false;

  private accountPattern: RegExp = /[^a-zA-Z0-9_\-+=\\.]/g;
  private passwordPattern: RegExp = /[^a-zA-Z0-9_\-+=\\.]/g;

  build() {
    Column() {
      if (this.isLoginMode) {
        this.loginForm()
      } else {
        this.registerForm()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  loginForm() {
    Column({ space: 20 }) {
      Text('登录')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })

      TextInput({ placeholder: '账号', text: this.account })
        .width('80%')
        .height(50)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onChange((value: string) => {
          this.account = value.replace(this.accountPattern, '');
        })

      TextInput({ placeholder: '密码', text: this.password })
        .width('80%')
        .height(50)
        .type(InputType.Password)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onChange((value: string) => {
          this.password = value.replace(this.passwordPattern, '');
        })

      if (this.errorMessage !== '') {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#FF4444')
          .margin({ top: 10 })
      }

      Button('登录')
        .width('80%')
        .height(50)
        .backgroundColor('#00C5CD')
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 20 })
        .enabled(!this.isLoading)
        .onClick(() => {
          this.doLogin();
        })

      Text('还没有账号？去注册')
        .fontSize(14)
        .fontColor('#00C5CD')
        .margin({ top: 20 })
        .onClick(() => {
          this.isLoginMode = false;
          this.errorMessage = '';
        })
    }
    .width('100%')
    .padding(30)
  }

  @Builder
  registerForm() {
    Column({ space: 20 }) {
      Text('注册')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })

      TextInput({ placeholder: '账号', text: this.regAccount })
        .width('80%')
        .height(50)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onChange((value: string) => {
          this.regAccount = value.replace(this.accountPattern, '');
        })

      TextInput({ placeholder: '密码', text: this.regPassword })
        .width('80%')
        .height(50)
        .type(InputType.Password)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onChange((value: string) => {
          this.regPassword = value.replace(this.passwordPattern, '');
        })

      TextInput({ placeholder: '确认密码', text: this.regPasswordConfirm })
        .width('80%')
        .height(50)
        .type(InputType.Password)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onChange((value: string) => {
          this.regPasswordConfirm = value.replace(this.passwordPattern, '');
        })

      if (this.errorMessage !== '') {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#FF4444')
          .margin({ top: 10 })
      }

      Button('注册')
        .width('80%')
        .height(50)
        .backgroundColor('#00C5CD')
        .fontColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 20 })
        .enabled(!this.isLoading)
        .onClick(() => {
          this.doRegister();
        })

      Text('已有账号？去登录')
        .fontSize(14)
        .fontColor('#00C5CD')
        .margin({ top: 20 })
        .onClick(() => {
          this.isLoginMode = true;
          this.errorMessage = '';
        })
    }
    .width('100%')
    .padding(30)
  }

  checkAccountPassword(account: string, pwd: string): boolean {
    if (account.length === 0) {
      this.errorMessage = '账号不能为空';
      return true;
    }
    if (account.length < 6) {
      this.errorMessage = '账号长度必须在 6-30 位';
      return true;
    }
    if (pwd.length === 0) {
      this.errorMessage = '密码不能为空';
      return true;
    }
    if (pwd.length < 8) {
      this.errorMessage = '密码长度必须在 8-30 位';
      return true;
    }
    return false;
  }

  async doLogin() {
    if (this.checkAccountPassword(this.account, this.password)) {
      return;
    }
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const res = await loginApi(this.account, this.password);
      await userStore.saveUser({
        userId: res.userId,
        role: res.role,
        account: res.account
      });
      await loginStateStore.setLoginSuccess(true);
      router.replaceUrl({ url: 'pages/TabPage' });
    } catch (err) {
      this.errorMessage = '登录失败，请检查账号密码';
      console.error('Login error:', JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }

  async doRegister() {
    if (this.checkAccountPassword(this.regAccount, this.regPassword)) {
      return;
    }
    if (this.regPasswordConfirm !== this.regPassword) {
      this.errorMessage = '两次密码不一致';
      return;
    }
    this.isLoading = true;
    this.errorMessage = '';

    try {
      await registerApi(this.regAccount, this.regPassword);
      await this.doLogin();
    } catch (err) {
      this.errorMessage = '注册失败';
      console.error('Register error:', JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }
}