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

import { AxiosResponse } from '@ohos/axios';
import { ApiResponse, myPosts } from '../api/Api';
import { PAGE_SIZE_DEFAULT } from '../constants/HappyConstants';
import { IPosts, Post } from '../models/Post';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { convertMillisecondsToTime } from '../utils/DateUtils';

@Entry
@Component
struct PostHistory {

  // ----------------------------------------------------------------

  @State
  posts: Post[] = []
  @State
  page: number = 1
  @State
  total: number = 0
  // ----------------------------------------------------------------

  @State
  isLoading: boolean = false
  // ----------------------------------------------------------------

  scroller: Scroller = new Scroller()

  // ----------------------------------------------------------------

  aboutToAppear(): void {
    this.isLoading = true
    this.reset()
    this.loadPosts(this.page)
    this.isLoading = false
  }

  aboutToDisappear(): void {
    this.reset()
  }

  // ----------------------------------------------------------------

  onPageShow() {

  }

  onPageHide(): void {
    this.reset()
  }

  // ----------------------------------------------------------------

  reset() {
    this.posts = []
    this.page = 1
    this.total = 0
  }

  async loadPosts(page: number) {
    this.nextPosts(page)
  }

  async nextPosts(page: number) {
    let response: AxiosResponse<ApiResponse<IPosts>> = await myPosts({
      page: page,
      size: PAGE_SIZE_DEFAULT,
    })

    response.data.data.records.forEach(post => {
      this.posts.push(new Post(post))
    })

    this.total = response.data.data.total
    this.page++
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back()
          })
        Text('打卡记录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .visibility(Visibility.Hidden)
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 20, right: 20 })

      Divider()
        .color(Color.Black)
        .margin({ left: 20, right: 20 })

      if (this.isLoading) {
        this.loadingBuilder()
      } else {
        if (this.posts.length > 0) {
          this.listBuilder()
        } else {
          this.emptyBuilder()
        }
      }
    }
    .height('100%')
    .width('100%')
    .padding({
      top: 40
    })
  }

  @Builder
  listBuilder() {
    Stack() {
      List({ scroller: this.scroller }) {
        ForEach(this.posts, (post: Post) => {
          ListItem() {
            this.postItemBuilder(post)
          }
          .width('100%')
        })
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .alignListItem(ListItemAlign.Center)
      .onReachEnd(() => {
        if (this.posts.length < this.total) {
          this.nextPosts(this.page)
        } else {
          promptAction.showToast({
            message: '没有更多数据啦~',
            alignment: Alignment.Center
          })
        }
      })
      .onReachStart(() => {
        // FIXME
      })

      Column({ space: 20 }) {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_top'))
            .width(14)
            .height(14)
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Black)
        .opacity(0.5)
        .onClick(() => {
          // 返回顶部
          this.scroller.scrollToIndex(0)
        })
      }
      .offset({ x: -20, y: -20 })

    }
    .width('100%')
    .layoutWeight(1)
    .alignContent(Alignment.BottomEnd)
  }

  @Builder
  emptyBuilder() {
    Column() {
      Image($r('app.media.ic_empty'))
        .width(200)
        .height(200)
      Text('暂无数据')
        .fontSize(20)
        .fontColor('#7e8892')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  loadingBuilder() {
    Column({ space: 15 }) {
      Image($r('app.media.ic_loading'))
        .width(30)
        .height(30)
      Text('加载中...')
        .fontSize(16)
        .fontColor('#7e8892')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  postItemBuilder(post: Post) {
    Row() {
      Column({ space: 10 }) {
        Text(post.createTime)
          .height(21)
          .fontSize(14)
          .fontColor('#999999')
        Row() {
          Text('单词数 : ' + post.answeredCount)
            .height(21)
            .fontSize(14)
            .fontColor('#1C1C1C')
            .margin({
              right: 20
            })
          Text('准确率 : ' + (
            post.answeredCount === 0
              ? 0
              : post.rightCount / post.answeredCount * 100).toFixed(0) + '%')
            .height(21)
            .fontSize(14)
            .fontColor('#1C1C1C')
        }

        Text('用时 : ' + convertMillisecondsToTime(post.timeUsed))
          .height(21)
          .fontSize(14)
          .fontColor('#1C1C1C')

      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text(post.createTime.substring(8, 10))
        .width(58)
        .height(58)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .backgroundImage($r('app.media.ic_history_date'))
        .backgroundImageSize(ImageSize.Contain)
    }
    .width('90%')
    .padding(10)
    .margin({ top: 10 })
    .borderWidth(1)
    .borderRadius(10)
    .shadow({ radius: 20 })
  }
}

