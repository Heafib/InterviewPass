import { HClockIn } from '../commons/components/HClockIn'
import { HSearch } from '../commons/components/HSearch'

@Component
export struct HomePage {
  @StorageProp('topHeight')
  topHeight: number = 0

  @Builder
  SwiperItemBuilder(src: Resource) {
    Row() {
      Image(src)
        .width('100%')
        .aspectRatio(2.65)
        .objectFit(ImageFit.Fill)
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16
    })
  }

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

      Swiper() {
        ForEach([$r('app.media.banner_qa'), $r('app.media.banner_pj'), $r('app.media.banner_ai')], (src: Resource) => {
          this.SwiperItemBuilder(src)
        })
      }
      .margin({
        bottom: 16
      })
      .autoPlay(true)
      .indicator(DotIndicator
        .dot()
        .bottom(4)
        .itemWidth(10)
        .itemHeight(4)
        .selectedItemWidth(10)
        .selectedColor($r('app.color.white')))
    }
    .padding({
      top: this.topHeight
    })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_gray_bg'))
  }
}