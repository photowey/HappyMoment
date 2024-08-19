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

import { createPost } from '../api/Api';
import { ControlButtonStyleOption } from '../models/ButtonOption';
import { convertMillisecondsToTime } from '../utils/DateUtils';
import { StatBar } from './Statistics';
import { promptAction, router } from '@kit.ArkUI';
import { CURRENT_TAB_INDEX_NAME, PAGE_MOMENT_REFRESH_EVENT, TOKEN_NAME } from '../constants/HappyConstants';
import emitter from '@ohos.events.emitter';

function emptyFx(): void { }

/**
 * 自定义统计弹窗
 *
 * 点击关闭按钮,关闭弹窗并重置题目和统计信息;
 * 点击再来一局,关闭弹窗并重置题目和统计信息,然后直接开始测试;
 * 点击登录打卡,关闭弹窗并重置题目和统计信息,然后跳转到登录页面,这部分功能后边再进行实现.
 */
@CustomDialog
export struct StatisticsDialog {
  answeredCount: number = 0;
  rightCount: number = 0;
  timeUsed: number = 0;
  reset: () => void = emptyFx;
  restart: () => void = emptyFx;
  controller: CustomDialogController = new CustomDialogController({
    builder: StatisticsDialog()
  })
  // ----------------------------------------------------------------

  @StorageProp(TOKEN_NAME)
  token: string = ''
  // ----------------------------------------------------------------

  @StorageLink(CURRENT_TAB_INDEX_NAME)
  currentTabIndex: number = 0;

  // ----------------------------------------------------------------

  async triggerMoment() {
    if (this.token) {
      // 已经登录
      // 1.发起打卡
      await createPost({
        rightCount: this.rightCount,
        answeredCount: this.answeredCount,
        timeUsed: this.timeUsed,
      })

      promptAction.showToast({
        message: '打卡成功',
        alignment: Alignment.Center
      })

      // 2.发送事件通知
      emitter.emit(PAGE_MOMENT_REFRESH_EVENT)

      // 3.跳转打卡圈
      this.currentTabIndex = 1
    } else {
      // 1.未登录 -> 发起登录
      router.pushUrl({
        url: 'pages/Login',
        params: {
          rightCount: this.rightCount,
          answeredCount: this.answeredCount,
          timeUsed: this.timeUsed,
        }
      })

      // 已迁移到登录界面
      // 2.发起打卡
      // 3.跳转打卡圈
    }
  }

  build() {
    Column({ space: 10 }) {
      Image($r('app.media.ic_close'))
        .width(25)
        .height(25)
        .alignSelf(ItemAlign.End)// 交叉轴对其方式 - 居右
        .onClick(() => {
          this.controller.close()
          this.reset()
        })

      Column({ space: 10 }) {
        Image($r('app.media.img_post'))
          .width('100%')
          .borderRadius(10)

        StatBar({
          icon: $r('app.media.ic_timer'),
          name: '用时',
          fontColor: Color.Black,
        }) {
          Text(convertMillisecondsToTime(this.timeUsed))
        }

        StatBar({
          icon: $r('app.media.ic_accuracy'),
          name: '准确率',
          fontColor: Color.Black,
        }) {
          Text((this.answeredCount === 0 ? 0 : this.rightCount / this.answeredCount * 100).toFixed() + "%")
        }

        StatBar({
          icon: $r('app.media.ic_count'),
          name: '个数',
          fontColor: Color.Black,
        }) {
          Text(this.answeredCount.toString())
        }

        Divider()

        Row({ space: 30 }) {
          Button('再来一次')
            .controlButtonStyle({
              font: Color.Black,
              border: Color.Black,
              background: Color.Transparent,
            })
            .onClick(() => {
              this.controller.close()
              this.reset()
              this.restart()
            })
          Button(this.token ? '立即打卡' : '登录打卡')
            .controlButtonStyle({
              font: Color.White,
              border: Color.Black,
              background: Color.Black,
            })
            .onClick(async () => {
              this.controller.close()
              this.reset()

              // 触发打开
              this.triggerMoment()
            })
        }
      }
      .width('100%')
      .padding(20)
      .borderRadius(10)
      .backgroundColor(Color.White)
    }
    .width('80%')
    .backgroundColor(Color.Transparent)
  }
}

@Extend(Button)
function controlButtonStyle(buttonOption: ControlButtonStyleOption) {
  .fontSize(16)
  .borderWidth(1)
  .fontColor(buttonOption.font)
  .borderColor(buttonOption.border)
  .backgroundColor(buttonOption.background)
}
