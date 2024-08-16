// ----------------------------------------------------------------


interface OptionButtonStyleColor {
  background: ResourceColor,
  font: ResourceColor
}

interface ControlButtonStyleColor {
  background: ResourceColor,
  border: ResourceColor,
  font: ResourceColor
}

// ----------------------------------------------------------------

@Entry
@Component
struct Practice {
  @State
  message: string = 'Hello World';

  build() {
    Column() {
      // TODO: 统计面板
      Column() {

        Text('准确率')
        Text('进度')
        Text('个数')
        Text('用时')

      }
    }.practiceBackgroundStyle()
  }
}

// ----------------------------------------------------------------


@Extend(Column)
function practiceBackgroundStyle() {
  .width('100%')
  .height('100%')
  .backgroundImage($r('app.media.img_practice_bg'))
  .backgroundImageSize({ width: '100%', height: '100%' })
  .justifyContent(FlexAlign.SpaceEvenly) // 主轴均匀分布
}

@Styles
function statBgStyle() {
  .backgroundColor(Color.White)
  .width('90%')
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
  .height(40)
  .fontSize(16)
  .fontColor('#9BA1A5')
  .fontWeight(FontWeight.Medium)
  .width('80%')
  .textAlign(TextAlign.Center)
}

@Extend(Button)
function optionButtonStyle(color: OptionButtonStyleColor) {
  .width(240)
  .height(48)
  .fontSize(16)
  .type(ButtonType.Normal)
  .fontColor(color.font)
  .fontWeight(FontWeight.Medium)
  .backgroundColor(color.background)
  .borderRadius(8)
}

@Extend(Button)
function controlButtonStyle(color: ControlButtonStyleColor) {
  .fontSize(16)
  .fontColor(color.font)
  .borderColor(color.border)
  .borderWidth(1)
  .backgroundColor(color.background)
}
