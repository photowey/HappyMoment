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

import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import promptAction from '@ohos.promptAction';
import { IPost, IPosts, IQuery, LoginPayload, PostPayload } from '../models/Post';
import { TOKEN_NAME } from '../constants/HappyMomentConstants';

// ----------------------------------------------------------------

const BASE_URL: string = 'http://192.168.85.1:3000'

// ----------------------------------------------------------------

export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T,
}

// ----------------------------------------------------------------

// 创建 axios 实例
export const actor = axios.create({
  baseURL: BASE_URL,
  timeout: 2000
})

// 添加请求拦截器
actor.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  // 通过 AppStorage(PersistStorage) 获取 token
  const token = AppStorage.get<string>(TOKEN_NAME)
  if (token) {
    // 若 token 存在,则将其添加到请求头
    config.headers[TOKEN_NAME] = token
  }
  return config;
}, (error: AxiosError) => {
  // 若出现异常,则提示异常信息
  promptAction.showToast({ message: error.message })
  return Promise.reject(error);
});

// 添加响应拦截器
actor.interceptors.response.use((response: AxiosResponse) => {
  // 若服务器返回的是正常数据,不做任何处理
  if (response.data.code === 200) {
    return response
  } else {
    // 若服务器返回的是异常数据,则提示异常信息
    promptAction.showToast({ message: response.data.message })
    return Promise.reject(response.data.message)
  }
}, (error: AxiosError) => {
  // 若出现异常,则提示异常信息
  promptAction.showToast({ message: error.message })
  return Promise.reject(error);
});

// 获取验证码
export function sendCode(phone: string) {
  return actor.get<ApiResponse<string>, AxiosResponse<ApiResponse<string>>>('/word/user/code', {
    params: { phone: phone }
  });
}

// 登录
export function login(payload: LoginPayload) {
  return actor.post<ApiResponse<string>, AxiosResponse<ApiResponse<string>>, LoginPayload>('/word/user/login', payload);
}

export function createPost(payload: PostPayload) {
  return actor.post<ApiResponse<IPost>, AxiosResponse<ApiResponse<IPost>>, PostPayload>('/word/post/create',
    payload)
}

// 获取全部打卡列表
export function posts(query: IQuery) {
  return actor.get<ApiResponse<IPosts>, AxiosResponse<ApiResponse<IPosts>>>('/word/post/getAll', {
    params: query
  })
}

// 点赞
export function like(postId: number) {
  return actor.get('/word/like/create', { params: { postId: postId } })
}

// 取消点赞
export function cancelLike(postId: number) {
  return actor.get('/word/like/cancel', { params: { postId: postId } })
}
