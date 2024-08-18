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

// ----------------------------------------------------------------

export interface IQuery {
  page: number;
  size: number;
}

// ----------------------------------------------------------------

export interface LoginPayload {
  phone: string;
  code: string;
}

export interface PostPayload {
  rightCount: number;
  answeredCount: number;
  timeUsed: number;
}

// ----------------------------------------------------------------

export interface IPost {
  id: number; // 标识
  postText: string; // 打卡文案
  rightCount: number; // 正确个数
  answeredCount: number; // 答题个数
  timeUsed: number; // 用时
  createTime: string; // 打卡时间
  likeCount: number; // 点赞个数
  nickname: string; // 用户昵称
  avatarUrl: string; // 用户头像
  isLike: boolean; // 当前登录用户是否已点赞
}

export interface IPosts {
  page: number,
  size: number,
  total: number,
  records: IPost[]
}

export interface IUser {
  nickname: string;
  avatarUrl: string;
}

// ----------------------------------------------------------------

@Observed
export class Post {

  id: number;
  postText: string;
  rightCount: number;
  answeredCount: number;
  timeUsed: number;
  createTime: string;
  likeCount: number;
  nickname: string;
  avatarUrl: string
  isLike: boolean;

  constructor(post: IPost) {
    this.id = post.id;
    this.postText = post.postText;
    this.rightCount = post.rightCount;
    this.answeredCount = post.answeredCount;
    this.timeUsed = post.timeUsed;
    this.createTime = post.createTime;
    this.likeCount = post.likeCount;
    this.nickname = post.nickname;
    this.avatarUrl = post.avatarUrl;
    this.isLike = post.isLike;
  }
}

@Observed
export class Posts {
  page?: number;
  size?: number;
  total?: number;
  records?: Post[];

  constructor(posts: IPosts) {
    this.page = posts.page;
    this.size = posts.size;
    this.total = posts.total;
    this.records = posts.records;
  }
}

@Observed
export class User {
  nickname?: string;
  avatarUrl?: string;

  constructor(user: IUser) {
    this.nickname = user.nickname;
    this.avatarUrl = user.avatarUrl;
  }
}
