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
import { AnswerStatus } from '../enums/AnswerStatus'

import { PracticeStatus } from '../enums/PracticeStatus'
import { getRandomQuestions, Question } from '../model/Question'
import { promptAction } from '@kit.ArkUI'
import { Answer, ControlButtonStyleOption } from '../model/ButtonOption'
import { OptionButton } from './OptionButton'


// ----------------------------------------------------------------

@Entry
@Component
struct Practice {
  // ----------------------------------------------------------------

  @State
  practiceStatus: PracticeStatus = PracticeStatus.Stopped
  @State
  answerStatus: AnswerStatus = AnswerStatus.Answering
  // ----------------------------------------------------------------

  @State
  questions: Question[] = getRandomQuestions(10)
  @State
  currentIndex: number = 0
  // ----------------------------------------------------------------

  @State
  selectedOption: string = ''

  // ----------------------------------------------------------------

  start() {
    // 1.修改状态
    this.practiceStatus = PracticeStatus.Running
    // TODO 2.启动计时器
  }

  pause() {
    // 1.修改状态
    this.practiceStatus = PracticeStatus.Paused
    // TODO  2.停止计时器
  }

  stop() {
    // 1.修改状态
    this.practiceStatus = PracticeStatus.Stopped
    // TODO 2.停止计时器
    // TODO 3.弹窗提示
  }

  answer(answer: Answer) {
    // 1.判断练习状态
    if (this.practiceStatus !== PracticeStatus.Running) {
      promptAction.showToast({
        message: '请先点击开始测试',
        duration: 1_500
      })

      return
    }

    // TODO 2.判断正误
    this.selectedOption = answer.option

    // TODO 3.更新统计信息

    // TODO 4.切换题目
    this.answerStatus = AnswerStatus.Answered
    if (this.currentIndex < this.questions.length - 1) {
      setTimeout(() => {
        this.currentIndex++
        this.answerStatus = AnswerStatus.Answering
      }, answer.determineIsRight() ? 200 : 1_000)
    } else {
      // 结束测试
      this.stop()
    }
  }

  // ----------------------------------------------------------------

  determineAnswerIsAnswering() {
    return this.answerStatus === AnswerStatus.Answering
  }

  determinePracticeIsNotStopped() {
    return !this.determinePracticeIsStopped()
  }

  determinePracticeIsStopped() {
    return this.practiceStatus === PracticeStatus.Stopped
  }

  determinePracticeIsRunning() {
    return this.practiceStatus === PracticeStatus.Running
  }

  // ----------------------------------------------------------------

  build() {
    Column() {
      // TODO 统计面板
      Column() {
        Text('准确率')
        Text('进度')
        Text('个数')
        Text('用时')
      }
      .statBackgroundStyle()

      // TODO 题目
      Column() {
        Text(this.questions[this.currentIndex].word)
          .wordStyle()
        Text(this.questions[this.currentIndex].sentence)
          .sentenceStyle()
      }

      // TODO 选项
      Column({ space: 10 }) {
        ForEach(
          this.questions[this.currentIndex].options,
          (option: string) => {
            OptionButton({
              option: option,
              answer: this.questions[this.currentIndex].answer,
              selectedOption: this.selectedOption,
              answerStatus: this.answerStatus
            })
              .enabled(this.determineAnswerIsAnswering())
              .onClick(() => {
                this.answer({
                  option: option,
                  answer: this.questions[this.currentIndex].answer,
                  determineIsRight: () => {
                    return option === this.questions[this.currentIndex].answer
                  }
                })
              })
          },
          (option: string) => {
            /* 自定义 Key */
            return this.questions[this.currentIndex].word + '-' + option
          }
        )
      }

      Row({ space: 50 }) {
        Button('停止测试')
          .controlButtonStyle({
            // 停止 - 灰色
            font: this.determinePracticeIsStopped() ? Color.Gray : Color.Black,
            // 停止 - 灰色
            border: this.determinePracticeIsStopped() ? Color.Gray : Color.Black,
            // 背景色 - 透明
            background: Color.Transparent
          })
          .enabled(this.determinePracticeIsNotStopped())
          .onClick(() => {
            // 停止测试
            this.stop()
          })

        Button(this.determinePracticeIsRunning() ? '开始测试' : '开始测试')
          .controlButtonStyle({
            font: Color.White,
            border: this.determinePracticeIsRunning() ? '#555555' : Color.Black,
            background: this.determinePracticeIsRunning() ? '#555555' : Color.Black,
          })
          .stateEffect(false)
          .onClick(() => {
            if (this.determinePracticeIsRunning()) {
              // 暂停测试
              this.pause()
            } else {
              // 开始测试
              this.start()
            }
          })
      }
    }
    .practiceBackgroundStyle()
  }
}

// ----------------------------------------------------------------

@Extend(Column)
function practiceBackgroundStyle() {
  // 全屏
  .width('100%')
  .height('100%')
  // 背景图
  .backgroundImage($r('app.media.img_practice_bg'))
  .backgroundImageSize({ width: '100%', height: '100%' })
  // 主轴均匀分布
  .justifyContent(FlexAlign.SpaceEvenly)
}

@Styles
function statBackgroundStyle() {
  .width('90%')
  .backgroundColor(Color.White)
  .borderRadius(10)
  .padding(20)
}

@Extend(Text)
function wordStyle() {
  .fontSize(50)
  .fontWeight(FontWeight.Bold)
}

@Extend(Text)
function sentenceStyle() {
  .width('80%')
  .height(40)
  .fontSize(16)
  .fontColor('#9BA1A5')
  .fontWeight(FontWeight.Medium)
  .textAlign(TextAlign.Center)
}

@Extend(Button)
function controlButtonStyle(buttonOption: ControlButtonStyleOption) {
  .fontSize(16)
  .fontColor(buttonOption.font)
  .borderColor(buttonOption.border)
  .borderWidth(1)
  .backgroundColor(buttonOption.background)
}
