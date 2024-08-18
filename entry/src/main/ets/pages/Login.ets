/*
 * Copyright © 2024 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { promptAction, router } from '@kit.ArkUI'
import { AxiosResponse } from '@ohos/axios'
import { ApiResponse, createPost, login, sendCode } from '../api/Api'
import { PostPayload } from '../models/Post'
import { CURRENT_TAB_INDEX_NAME, PAGE_MOMENT_REFRESH_EVENT, TOKEN_NAME } from '../constants/HappyConstants'
import emitter from '@ohos.events.emitter'

@Entry
@Component
struct Login {

  // ----------------------------------------------------------------

  @State
  phone: string = ''
  @State
  code: string = ''
  // ----------------------------------------------------------------

  @StorageLink(TOKEN_NAME)
  token: string = ''
  @StorageLink(CURRENT_TAB_INDEX_NAME)
  currentTabIndex: number = 0;

  // ----------------------------------------------------------------

  async postLogin() {
    this.toMoment()
    // 回到上一页
    router.back()
  }

  async toMoment() {
    // 答题页面 - currentTabIndex === 0
    if (this.currentTabIndex !== 0) {
      // 不是答题页面跳转过来的 -> 直接返回
      return
    }

    let payload = router.getParams() as PostPayload

    // 1.发起打卡
    await createPost({
      rightCount: payload.rightCount,
      answeredCount: payload.answeredCount,
      timeUsed: payload.timeUsed,
    })

    promptAction.showToast({
      message: '打卡成功'
    })

    // 2.发送事件通知
    emitter.emit(PAGE_MOMENT_REFRESH_EVENT)

    // 3.跳转打卡圈
    this.currentTabIndex = 1
  }

  // ----------------------------------------------------------------

  build() {
    Column() {
      Image($r('app.media.ic_back'))
        .backStyle()
        .alignSelf(ItemAlign.Start)
        .onClick(() => {
          // 返回上一页面
          router.back()
        })

      Blank()
      Column() {
        Text('欢迎登录')
          .titleStyle()

        Row() {
          Image($r("app.media.ic_phone"))
            .iconStyle()
          TextInput({ placeholder: '请输入手机号码', text: this.phone })
            .inputStyle()
            .onChange((value) => {
              this.phone = value;
            })
        }.margin({ top: 30 })

        Divider()
          .color(Color.Black)

        Row() {
          Image($r("app.media.ic_code"))
            .iconStyle()
          TextInput({ placeholder: '请输入验证码', text: this.code })
            .inputStyle()
            .onChange((value) => {
              this.code = value;
            })
          Button('获取验证码')
            .extendButtonStyle(Color.White, Color.Black)
            .onClick(async () => {
              // 获取验证码
              let response: AxiosResponse<ApiResponse<string>> = await sendCode(this.phone)
              this.code = response.data.data
            })

        }.margin({ top: 20 })

        Divider()
          .margin({ right: 120 })
          .color(Color.Black)

        Button('立即登录')
          .extendButtonStyle(Color.Black, Color.White)
          .width('100%')
          .margin({ top: 50 })
          .onClick(async () => {
            // 登录
            let response: AxiosResponse<ApiResponse<string>> = await login({
              phone: this.phone,
              code: this.code
            })
            this.token = response.data.data

            this.postLogin()
          })

        Row() {
          Text('登录即表示已同意')
            .fontSize(10)
            .fontColor('#546B9D')
          Text('《用户使用协议》')
            .fontSize(10)
            .fontColor('#00B3FF')
        }.margin({ top: 20 })
      }
      .formBackgroundStyle()

      Row({ space: 10 }) {
        Image($r('app.media.ic_logo'))
          .width(36)
          .height(36)
        Text('快速记单词神器')
          .fontColor('#546B9D')
          .fontWeight(FontWeight.Bold)
          .fontSize(20)
      }
      .margin({ top: 70 })

      Text('Developed By Atguigu')
        .fontSize(12)
        .fontColor('#546B9D')
        .margin(10)

    }
    .loginBgStyle()
  }
}

@Styles
function loginBgStyle() {
  .width('100%')
  .height('100%')
  .backgroundImage($r("app.media.img_login_bg"))
  .backgroundImageSize({ width: '100%', height: '100%' })
  .padding({
    top: 30,
    bottom: 30,
    left: 20,
    right: 20
  })
}

@Styles
function backStyle() {
  .width(25)
  .height(25)
}

@Styles
function formBackgroundStyle() {
  .padding(30)
  .borderRadius(20)
  //.backgroundColor(Color.White)
  .backgroundColor(Color.Transparent)
}

@Extend(Text)
function titleStyle() {
  .fontSize(22)
  .fontWeight(FontWeight.Bold)
}

@Styles
function iconStyle() {
  .width(24)
  .height(24)
}

@Extend(TextInput)
function inputStyle() {
  .height(40)
  .fontSize(14)
  .layoutWeight(1)
  .backgroundColor(Color.Transparent)
}

@Extend(Button)
function extendButtonStyle(backgroundColor: ResourceColor, fontColor: ResourceColor) {
  .fontSize(14)
  .fontColor(fontColor)
  .fontWeight(FontWeight.Medium)
  .type(ButtonType.Normal)
  .backgroundColor(backgroundColor)
  .borderWidth(1)
  .borderRadius(5)
}
