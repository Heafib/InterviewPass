import { HClockIn } from '../commons/components/HClockIn'
import { HSearch } from '../commons/components/HSearch'

@Component
export struct HomePage {
  @StorageProp('topHeight')
  topHeight: number = 0

  build() {
    Column() {
      Row({ space: 16 }) {
        Image($r('app.media.ic_home_scan'))
          .width(24)
          .aspectRatio(1)
        //搜索盒子
        HSearch({ layoutWeightValue: 1 })
        // 打卡
        HClockIn()
      }
      .padding({
        left: 16,
        right: 16
      })
      .width('100%')
      .height(64)
    }
    .padding({
      top: this.topHeight
    })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_gray_bg'))
  }
}