import { HClockIn } from '../commons/components/HClockIn'
import { HSearch } from '../commons/components/HSearch'
import { HomeCategory } from '../views/home/HomeCategory'
import { auth } from '../commons/utils/Auth'
import scanBarcode from '@hms.core.scan.scanBarcode'
import { httpClient } from '../commons/utils/HttpClient'
import { QuestionDetail } from '../models'
import { promptAction, router } from '@kit.ArkUI'

@Component
export struct HomePage {
  @StorageProp('topHeight')
  topHeight: number = 0

  async scanQuestionCode() {
    /// 判断某个能力 设备是否支持
    if (canIUse('SystemCapability.Multimedia.Scan.ScanBarcode')) {
      // 调起扫码界面
      const result = await scanBarcode.startScanForResult(getContext(this))
      // 根据结果查询试题
      if (result.originalValue) {
        try {
          const item = await httpClient.request<QuestionDetail>({ url: `/question/${result.originalValue}` })
          // 跳转
          router.pushUrl({
            url: 'pages/QuestionPage',
            params: {
              item,
              list: [item]
            }
          })
        } catch (e) {
          promptAction.showToast({ message: '没有找到试题' })
        }
      }
    }
  }

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
          .onClick(() => {
            auth.checkAuth(() => {
              console.log('扫描')
              this.scanQuestionCode()
            })
          })
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
      .onClick(() => {
        router.pushUrl({
          url: 'pages/TestPage'
        })
      })
      .margin({
        bottom: 16
      })
      .autoPlay(true)
      .indicator(DotIndicator
        .dot()
        .bottom(4)
        .itemWidth(10)
        .itemHeight(4)
        .selectedItemHeight(4)
        .selectedItemWidth(10)
        .selectedColor($r('app.color.white')))

      // 分类
      HomeCategory()
    }
    .padding({
      top: this.topHeight
    })
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_gray_bg'))
  }
}