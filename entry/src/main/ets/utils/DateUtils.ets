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

export function convertMillisecondsToTime(timeUsed: number): string {
  // 计算小时、分钟和秒
  const hours = Math.floor(timeUsed / 3600000); // 1 小时 = 3600000 毫秒
  const minutes = Math.floor((timeUsed % 3600000) / 60000); // 1 分钟 = 60000 毫秒
  const seconds = Math.floor((timeUsed % 60000) / 1000); // 1 秒 = 1000 毫秒

  // 将结果格式化为时分秒字符串
  if (hours > 0) {
    return `${hours}时  ${minutes}分 ${seconds}秒`
  } else if (minutes > 0) {
    return `${minutes}分 ${seconds}秒`
  } else {
    return `${seconds}秒`
  }
}
