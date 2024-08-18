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

import { router } from '@kit.ArkUI';
import { CURRENT_TAB_INDEX_NAME, TOKEN_NAME } from '../constants/HappyConstants';

// ----------------------------------------------------------------

PersistentStorage.persistProp<string>(TOKEN_NAME, '');
AppStorage.setOrCreate<number>(CURRENT_TAB_INDEX_NAME, 0);

// ----------------------------------------------------------------

@Entry
@Component
struct Splash {

  @State
  showLogo: boolean = false;

  onPageShow(): void {
    animateTo({
      duration: 1000,
      onFinish: () => {
        setTimeout(() => {
          router.replaceUrl({
            url: 'pages/Index'
          })
        }, 500)
      }
    }, () => {
      this.showLogo = true;
    })
  }

  build() {
    Column() {
      if (this.showLogo) {
        Image($r('app.media.ic_logo'))
          .logoStyle()
          .transition({
            type: TransitionType.Insert,
            opacity: 0,
            translate: { x: -150 },
          })

        Text('快速单词记忆神器')
          .titleStyle()
          .transition({
            type: TransitionType.Insert,
            opacity: 0,
            translate: { x: 150 },
          })
      }

      Blank()

      Text('Atguigu HarmonyOS project')
        .footerStyle()
    }
    .backgroundStyle()
  }
}

@Styles
function backgroundStyle() {
  .width('100%')
  .height('100%')
  .backgroundImage($r('app.media.img_splash_bg'))
  .backgroundImageSize({ width: '100%', height: '100%' })
}

@Extend(Image)
function logoStyle() {
  .width(90)
  .height(90)
  .margin({ top: 120 })
}

@Extend(Text)
function titleStyle() {
  .fontSize(21)
  .fontColor(Color.White)
  .fontWeight(FontWeight.Bold)
  .margin({ top: 15 })
}

@Extend(Text)
function footerStyle() {
  .fontSize(12)
  .fontColor('#546B9D')
  .fontWeight(FontWeight.Bold)
  .margin({ bottom: 30 })
}
