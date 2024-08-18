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

import { AxiosResponse } from '@ohos/axios'
import emitter from '@ohos.events.emitter'
import { promptAction, router } from '@kit.ArkUI'
import { ApiResponse, cancelLike, like, posts } from '../api/Api'
import { StatBar } from '../component/Statistics'
import { PAGE_MOMENT_REFRESH_EVENT, TOKEN_NAME } from '../constants/HappyMomentConstants'
import { IPosts, Post } from '../models/Post'
import { convertMillisecondsToTime } from '../utils/DateUtils'

const PAGE_SIZE: number = 10

@Component
export struct Moment {

  @StorageProp(TOKEN_NAME)
  @Watch("onTokenChanged")
  token: string = ''
  @State
  posts: Post[] = [
  /*new Post({
    id: 1,
    postText: '既然选择远方，当不负青春，砥砺前行',
    rightCount: 3,
    answeredCount: 4,
    timeUsed: 5747,
    createTime: '2024-08-18 21:48:30',
    likeCount: 1,
    nickname: '138****8888',
    avatarUrl: 'https://oss.aliyuncs.com/aliyun_id_photo_bucket/default_handsome.jpg',
    isLike: false
  })*/
  ]
  // ----------------------------------------------------------------

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
    if (this.determineIsLogined()) {
      this.loadPosts()
    }

    // 监听事件
    emitter.on(PAGE_MOMENT_REFRESH_EVENT, () => {
      this.refresh()
    })
  }

  // ----------------------------------------------------------------

  onTokenChanged() {
    if (this.determineIsLogined()) {
      // 登录
      this.loadPosts()
    } else {
      // 退出登录
      this.destroy()
    }
  }

  // ----------------------------------------------------------------

  determineIsLogined(): boolean {
    return this.token !== ''
  }

  determineOnReachEnd(): boolean {
    return this.posts.length < this.total
  }

  // ----------------------------------------------------------------

  destroy() {
    this.reset()
  }

  reset() {
    this.posts = []
    this.page = 1
    this.total = 0
  }

  // ----------------------------------------------------------------

  async refresh() {
    this.isLoading = true
    this.reset()
    await this.loadPosts()
    this.isLoading = false
  }

  async loadPosts() {
    this.nextPosts()
  }

  async nextPosts() {
    let response: AxiosResponse<ApiResponse<IPosts>> = await posts({
      page: this.page,
      size: PAGE_SIZE,
    })

    promptAction.showToast({
      message: "加载完毕"
    })

    response.data.data.records.forEach((post => {
      this.posts.push(new Post(post))
    }))

    this.total = response.data.data.total
    this.page++
  }

  // ----------------------------------------------------------------

  build() {
    Column() {
      Text('英语打卡圈')
        .fontSize(18)
        .margin({ top: 45 })
        .fontWeight(FontWeight.Bold)

      Divider()
        .color(Color.Black)
        .margin({ left: 20, right: 20, top: 10 })

      if (this.determineIsLogined()) {
        // 打卡列表
        if (this.isLoading) {
          this.loadingBuilder()
        } else {
          this.momentBuilder()
        }
      } else {
        // 未登录
        this.unLoginBuilder()
      }
    }
    .width('100%')
    .height('100%')
  }

  // ----------------------------------------------------------------

  @Builder
  momentBuilder() {
    Stack() {
      List({ scroller: this.scroller }) {
        ForEach(this.posts, (post: Post) => {
          ListItem() {
            PostComp({ post: post })
          }
        })
      }
      .width('100%')
      .height('100%')
      .alignListItem(ListItemAlign.Center)
      .onReachEnd(() => {
        // 没加载完 -> 加载下一个
        if (this.determineOnReachEnd()) {
          this.nextPosts()
        } else {
          promptAction.showToast({
            message: '没有更多数据啦~'
          })
        }
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

        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_refresh'))
            .width(14)
            .height(14)
        }
        .width(40)
        .height(40)
        .opacity(0.5)
        .backgroundColor(Color.Black)
        .onClick(() => {
          // FIXME 刷新
          this.refresh()
        })
      }
      .offset({ x: -20, y: -50 })
    }.width('100%')
    .layoutWeight(1)
    .alignContent(Alignment.BottomEnd)
  }

  // ----------------------------------------------------------------

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
  unLoginBuilder() {
    Column({ space: 30 }) {
      Image($r("app.media.ic_unLogin_bg"))
        .unLoginImageStyle()

      Text('未登录暂无数据')
        .unLoginTextStyle()

      Button('去登录')
        .unLoginStyle()
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Login'
          })
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct PostComp {
  @ObjectLink
  post: Post;

  build() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        Image(this.post.avatarUrl)
          .height(40)
          .width(40)
          .borderRadius(20)
        Text(this.post.nickname)
          .height(40)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(this.post.createTime)
          .height(40)
          .fontSize(14)
          .fontColor('#999999')
          .fontWeight(FontWeight.Medium)
      }.width('100%')

      Text(this.post.postText)
        .width('100%')

      Row() {
        Column() {
          StatBar({
            icon: $r('app.media.ic_timer_white'),
            name: '用时',
            fontColor: Color.White
          }) {
            Text(convertMillisecondsToTime(this.post.timeUsed))
              .statTextStyle()
          }

          StatBar({
            icon: $r('app.media.ic_accuracy_white'),
            name: '准确率',
            fontColor: Color.White
          }) {
            Text((this.post.answeredCount === 0
              ? 0
              : this.post.rightCount / this.post.answeredCount * 100).toFixed(0) + '%')
              .statTextStyle()
          }

          StatBar({
            icon: $r('app.media.ic_count_white'),
            name: '个数',
            fontColor: Color.White
          }) {
            Text(this.post.answeredCount.toString())
              .statTextStyle()
          }
        }
        .padding(10)
        .borderRadius(10)
        .layoutWeight(1)
        .backgroundImage($r('app.media.img_post_bg'))
        .backgroundImageSize(ImageSize.Cover)

        Column() {
          Text(this.post.likeCount.toString())
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.post.isLike ? '#3ECBA1' : '#000000')
          Image(this.post.isLike ? $r('app.media.ic_post_like_selected') : $r('app.media.ic_post_like'))
            .width(26)
            .height(26)
            .onClick(() => {
              // 点赞/取消点赞
              if (this.post.isLike) {
                // 取消点赞
                this.post.isLike = false
                this.post.likeCount--
                cancelLike(this.post.id)
              } else {
                // 点赞
                this.post.isLike = true
                this.post.likeCount++
                like(this.post.id)
              }
            })
        }
        .width(50)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
    }
    .width('90%')
    .padding(10)
    .margin({ top: 10 })
    .borderRadius(10)
    .shadow({ radius: 20 })
  }
}

// ----------------------------------------------------------------

@Extend(Text)
function statTextStyle() {
  .width(100)
  .fontSize(16)
  .textAlign(TextAlign.End)
  .fontWeight(FontWeight.Medium)
  .fontColor(Color.White)
}

// ----------------------------------------------------------------

@Extend(Image)
function unLoginImageStyle() {
  .width(177)
  .height(177)
}

@Extend(Text)
function unLoginTextStyle() {
  .fontSize(14)
  .fontColor('#999999')
}

@Extend(Button)
function unLoginStyle() {
  .width(100)
  .height(34)
  .fontSize(14)
  .fontColor(Color.White)
  .backgroundColor('#43C6A0')
}
