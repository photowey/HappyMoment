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

import { Practice } from './Practice';

@Entry
@Component
struct Index {

  @State
  currentTabIndex: number = 0;

  tabSelected(index: number) {
    return this.currentTabIndex === index
  }

  build() {
    Tabs() {
      TabContent() {
        Practice()
      }.tabBar(this.barBuilder(2, $r('app.media.ic_practice'), $r('app.media.ic_practice_selected'), '答题'))

      TabContent() {
        Text('圈子')
      }.tabBar(this.barBuilder(2, $r('app.media.ic_circle'), $r('app.media.ic_circle_selected'), '圈子'))

      TabContent() {
        Text('我的')
      }.tabBar(this.barBuilder(2, $r('app.media.ic_mine'), $r('app.media.ic_mine_selected'), '我的'))
    }
    .barPosition(BarPosition.End)
    .onChange((index) => {
      this.currentTabIndex = index
    })
  }

  @Builder
  barBuilder(index: number, icon: Resource, selectedIcon: Resource, title: string) {
    Column() {
      Image(this.tabSelected(index) ? selectedIcon : icon)
        .tabIconStyle()
      Text(title)
        .tabTitleStyle(this.tabSelected(index) ? Color.Black : '#959595')
    }
  }
}

@Styles
function tabIconStyle() {
  .width(25)
  .height(25)
}

@Extend(Text)
function tabTitleStyle(color: ResourceColor) {
  .fontSize(10)
  .fontWeight(FontWeight.Medium)
  .fontColor(color)
  .margin({ bottom: 2 })
}
