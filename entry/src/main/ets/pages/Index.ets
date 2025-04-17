import { fullScreen } from '../commons/utils/FullScreen';
import { statusBar } from '../commons/utils/StatusBar';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @StorageProp('topHeight')
  topHeight: number = 0

  build() {
    Column({ space: 16 }) {
      Text('111')
      Text('111')
      Text('111')
      Button('开启全屏')
        .onClick(() => {
          fullScreen.enable()
        })
      Button('关闭全屏')
        .onClick(() => {
          fullScreen.disable()
        })
      Button('设置黑色状态栏')
        .onClick(() => {
          statusBar.setDarkBar()
        })
      Button('设置白色状态栏')
        .onClick(() => {
          statusBar.setLightBar()
        })
    }
    .padding({
      top: this.topHeight
    })
    .height('100%')
    .width('100%')
    .backgroundColor(Color.Grey)
  }
}