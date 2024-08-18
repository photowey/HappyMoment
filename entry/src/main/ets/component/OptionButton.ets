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

import { OptionStatus } from '../enums/OptionStatus'
import { OptionButtonStyleOption } from '../models/ButtonOption'

@Component
export struct OptionButton {
  // ----------------------------------------------------------------
  option: string = ''
  answer: string = ''
  // ----------------------------------------------------------------

  @Prop
  selectedOption: string = ''
  @Prop
  @Watch("onAnswerStatusChanged")
  answerStatus: AnswerStatus = AnswerStatus.Answering
  // ----------------------------------------------------------------

  @State
  optionStatus: OptionStatus = OptionStatus.Default

  // ----------------------------------------------------------------

  onAnswerStatusChanged() {
    // 选项 === 答案 -> 是正确答案
    if (this.option === this.answer) {
      this.optionStatus = OptionStatus.Right
    } else {
      // 不是正确答案
      if (this.option === this.selectedOption) {
        // 被选中 -> 选择错误
        this.optionStatus = OptionStatus.Wrong
      } else {
        this.optionStatus = OptionStatus.Default
      }
    }
  }

  // ----------------------------------------------------------------

  determineBackgroundColor(): ResourceColor {
    switch (this.optionStatus) {
      case OptionStatus.Right:
        return '#1DBF7B'
      case OptionStatus.Wrong:
        return '#FA635F'
      default:
        return Color.White
    }
  }

  determineOptionFontColor(): ResourceColor {
    switch (this.optionStatus) {
      case OptionStatus.Default:
        return Color.Black
      default:
        return Color.White
    }
  }

  // ----------------------------------------------------------------

  /**
   * @deprecated since 1.0.0
   */
  determineOptionIsRight(): boolean {
    return this.optionStatus === OptionStatus.Right
  }

  /**
   * @deprecated since 1.0.0
   */
  determineOptionIsWrong(): boolean {
    return this.optionStatus === OptionStatus.Wrong
  }

  // ----------------------------------------------------------------

  build() {
    Stack() {
      Button(this.option)
        .optionButtonStyle({
          font: this.determineOptionFontColor(),
          background: this.determineBackgroundColor()
        })
      if (this.optionStatus === OptionStatus.Right) {
        Image($r('app.media.ic_right'))
          .width(22)
          .height(22)
          .offset({ x: 10 })
      }
      if (this.optionStatus === OptionStatus.Wrong) {
        Image($r('app.media.ic_wrong'))
          .width(22)
          .height(22)
          .offset({ x: 10 })
      }
    }
    .alignContent(Alignment.Start)
  }
}

@Extend(Button)
function optionButtonStyle(buttonOption: OptionButtonStyleOption) {
  .width(240)
  .height(48)
  .fontSize(16)
  .fontColor(buttonOption.font)
  .fontWeight(FontWeight.Medium)
  .type(ButtonType.Normal)
  .backgroundColor(buttonOption.background)
  .borderRadius(8)
}
