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

@Component
export struct StatBar {
  icon: Resource = $r('app.media.img_practice_bg');
  name: string = '';
  fontColor: Color = Color.White
  @BuilderParam
  statComponent: () => void;

  build() {
    Row({ space: 10 }) {
      Image(this.icon)
        .width(14)
        .height(14)
      Text(this.name)
        .fontSize(14)
        .fontColor(this.fontColor)
        .fontWeight(FontWeight.Medium)
      Blank()
      this.statComponent()
    }
    .width('100%')
    .height(30)
  }
}
