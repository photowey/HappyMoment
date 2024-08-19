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

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ApiResponse, info } from '../api/Api';
import { AxiosResponse } from '@ohos/axios';
import { IUser, User } from '../models/Post';
import { TOKEN_NAME } from '../constants/HappyConstants';

@Component
export struct Mine {

  @StorageLink(TOKEN_NAME)
  @Watch('onTokenChanged')
  token: string = ''
  @State
  user: User = new User({} as IUser);

  async onTokenChanged() {
    if (this.token) {
      let response: AxiosResponse<ApiResponse<IUser>> = await info()
      this.user = new User(response.data.data)
    } else {
      this.user = new User({} as IUser);
    }
  }

  async aboutToAppear() {
    if (this.token) {
      let response: AxiosResponse<ApiResponse<IUser>> = await info()
      this.user = new User(response.data.data)
    }
  }

  build() {
    Stack() {
      Column() {
        Image(this.token ? this.user.avatarUrl : $r('app.media.img_avatar'))
          .width(100)
          .height(100)
          .borderRadius(50)
          .margin({ top: 120 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/Login' })
          })

        Text(this.token ? this.user.nickname : '请登录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .margin({ top: 20 })

        if (!this.token) {
          Text('请点击头像登录')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
            .margin({ top: 4 })
        }
      }
      .width('100%')
      .height('50%')
      .backgroundImage(this.token ? this.user.avatarUrl : $r('app.media.img_avatar'))
      .backgroundImageSize({ height: '100%', width: '100%' })
      .backgroundBlurStyle(BlurStyle.Regular)

      Column({ space: 10 }) {
        this.mineItemBuilder({
          icon: $r('app.media.ic_mine_card'),
          title: '打卡记录',
          callback: () => {
            if (this.token) {
              router.pushUrl({ url: 'pages/PostHistory' })
            } else {
              promptAction.showToast({
                message: '请先点击头像登录',
                alignment: Alignment.Center
              })
            }
          }
        })

        Divider()

        this.mineItemBuilder({
          icon: $r('app.media.ic_mine_update'),
          title: '检查更新',
          callback: () => {
            promptAction.showToast({
              message: '您已是最新版本',
              alignment: Alignment.Center
            })
          }
        })

        Divider()

        this.mineItemBuilder({
          icon: $r('app.media.ic_mine_about'),
          title: '关于我们',
          callback: () => {
            promptAction.showToast({
              message: '牛仔很忙~',
              alignment: Alignment.Center
            })
          }
        })

        Blank()

        if (this.token) {
          Button('退出登录')
            .width('100%')
            .fontSize(18)
            .backgroundColor(Color.Gray)
            .fontColor(Color.White)
            .onClick(() => {
              this.token = ''
            })
        }

      }
      .width('100%')
      .height('60%')
      .offset({ y: '40%' })
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 50, topRight: 50 })
      .padding(30)

    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  mineItemBuilder(item: MineItem) {
    Row({ space: 10 }) {
      Image(item.icon)
        .width(24)
        .height(24)
      Text(item.title)
        .fontSize(16)
        .height(24)
        .fontWeight(FontWeight.Medium)

      Blank()

      Image($r('app.media.ic_arrow_right'))
        .width(24)
        .height(24)
    }
    .width('100%')
    .height(40)
    .onClick(() => {
      item.callback();
    })
  }
}

interface MineItem {
  icon: Resource;
  title: string;
  callback: () => void;
}
