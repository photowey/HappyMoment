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
import { getRandomQuestions, Question } from '../models/Question'
import { promptAction } from '@kit.ArkUI'
import { AnswerOption, ControlButtonStyleOption } from '../models/ButtonOption'
import { OptionButton } from './OptionButton'
import { StatBar } from './Statistics'
import { StatisticsDialog } from './StatisticsDialog'

// ----------------------------------------------------------------

@Entry
@Component
struct Practice {
  // ----------------------------------------------------------------

  @State
  answeredCount: number = 0
  @State
  rightCount: number = 0
  @State
  totalCount: number = 10
  // ----------------------------------------------------------------

  @State
  range: string[] = ['5', '10', '15', '20']
  // ----------------------------------------------------------------

  @State
  practiceStatus: PracticeStatus = PracticeStatus.Stopped
  @State
  answerStatus: AnswerStatus = AnswerStatus.Answering
  // ----------------------------------------------------------------

  @State
  questions: Question[] = getRandomQuestions(this.totalCount)
  @State
  currentIndex: number = 0
  // ----------------------------------------------------------------

  @State
  selectedOption: string = ''
  // ----------------------------------------------------------------

  timerController: TextTimerController = new TextTimerController();
  timeUsed: number = 0;
  // ----------------------------------------------------------------

  dialogController: CustomDialogController = new CustomDialogController({
    builder: StatisticsDialog({
      answeredCount: this.answeredCount,
      rightCount: this.rightCount,
      timeUsed: this.timeUsed,
      reset: () => {
        this.reset()
      },
      restart: () => {
        this.restart()
      }
    }),
    customStyle: true,
    // 不允许点击遮障层(蒙皮)关闭
    autoCancel: false,
  })

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

  currentQuestion(): Question {
    return this.questions[this.currentIndex]
  }

  // ----------------------------------------------------------------

  reset() {
    this.questions = getRandomQuestions(this.totalCount)
    this.currentIndex = 0
    this.answeredCount = 0
    this.rightCount = 0
    this.timeUsed = 0
    this.timerController.reset()
    this.answerStatus = AnswerStatus.Answering
  }

  restart() {
    this.start()
  }

  start() {
    // 1.修改状态
    this.practiceStatus = PracticeStatus.Running
    // 2.启动计时器
    this.timerController.start()
  }

  pause() {
    // 1.修改状态
    this.practiceStatus = PracticeStatus.Paused
    //  2.停止计时器
    this.timerController.pause()
  }

  stop() {
    // 1.修改状态
    this.practiceStatus = PracticeStatus.Stopped
    // 2.停止计时器
    this.timerController.pause()
    // 3.弹窗提示
    this.dialogController.open()
  }

  answer(answer: AnswerOption) {
    // 1.判断练习状态
    if (this.practiceStatus !== PracticeStatus.Running) {
      promptAction.showToast({
        message: '请先点击开始测试',
        duration: 1_500
      })

      return
    }

    // 2.判断正误
    this.selectedOption = answer.option

    // 3.更新统计信息
    // 答题数量
    this.answeredCount++
    if (answer.judge()) {
      // 正确数量
      this.rightCount++
    }

    // 4.切换题目
    this.answerStatus = AnswerStatus.Answered
    if (this.currentIndex < this.questions.length - 1) {
      setTimeout(() => {
        this.currentIndex++
        this.answerStatus = AnswerStatus.Answering
      }, answer.judge() ? 200 : 1_000)
    } else {
      // 结束测试
      this.stop()
    }
  }

  // ----------------------------------------------------------------

  build() {
    Column() {
      // 统计面板
      Column() {
        StatBar({
          icon: $r('app.media.ic_accuracy'),
          name: '准确率',
          fontColor: Color.Black,
        }) {
          Text((this.answeredCount === 0 ? 0 : this.rightCount / this.answeredCount * 100).toFixed() + "%")
            .width(100)
            .textAlign(TextAlign.Center)
        }

        StatBar({
          icon: $r('app.media.ic_progress'),
          name: '进度',
          fontColor: Color.Black,
        }) {
          Progress({
            value: this.answeredCount,
            total: this.totalCount,
          })
            .width(100)
        }

        StatBar({
          icon: $r('app.media.ic_count'),
          name: '个数',
          fontColor: Color.Black,
        }) {
          Button(this.totalCount.toString())
            .width(100)
            .height(25)
            .fontColor(Color.Black)
            .backgroundColor('#EBEBEB')
            .enabled(this.determinePracticeIsStopped())
            .onClick(() => {
              TextPickerDialog.show({
                range: this.range,
                value: this.totalCount.toString(),
                onAccept: (picked) => {
                  this.totalCount = parseInt(picked.value.toString())
                  this.questions = getRandomQuestions(this.totalCount)
                }
              })
            })
        }

        StatBar({
          icon: $r('app.media.ic_timer'),
          name: '用时',
          fontColor: Color.Black,
        }) {
          Row() {
            TextTimer({ controller: this.timerController })
              .onTimer(( /* current.timestamp: utc */_: number, /* unit: ms */elapsedTime: number) => {
                this.timeUsed = elapsedTime
              })
          }
          .width(100)
          .justifyContent(FlexAlign.Center)
        }
      }
      .statBackgroundStyle()

      // 题目
      Column() {
        Text(this.currentQuestion().word)
          .wordStyle()
        Text(this.currentQuestion().sentence)
          .sentenceStyle()
      }

      // 选项
      Column({ space: 10 }) {
        ForEach(
          this.currentQuestion().options,
          (option: string) => {
            OptionButton({
              option: option,
              answer: this.currentQuestion().answer,
              selectedOption: this.selectedOption,
              answerStatus: this.answerStatus
            })
              .enabled(this.determineAnswerIsAnswering())
              .onClick(() => {
                this.answer({
                  option: option,
                  answer: this.currentQuestion().answer,
                  judge: () => {
                    return option === this.currentQuestion().answer
                  }
                })
              })
          },
          (option: string) => {
            /* 自定义 Key */
            return this.currentQuestion().word + '-' + option
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
  .borderWidth(1)
  .fontColor(buttonOption.font)
  .borderColor(buttonOption.border)
  .backgroundColor(buttonOption.background)
}
