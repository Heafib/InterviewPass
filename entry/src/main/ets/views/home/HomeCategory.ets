import { QuestionListComp } from '../../commons/components/QuestionListComp'
import { httpClient } from '../../commons/utils/HttpClient'
import { QuestionType } from '../../models'

@Component
export struct HomeCategory {
  @State
  activeIndex: number = 0
  @State
  questionTypeList: QuestionType[] = []
  @State
  show: boolean = false

  @Builder
  FilterSheetBuilder() {
    Column() {
      Row() {
        Text('重置')
          .fontSize(16)
          .fontWeight(500)
          .fontColor($r('app.color.common_gray_03'))
        Text('筛选题目')
          .layoutWeight(1)
          .fontSize(18)
          .fontWeight(500)
          .fontColor($r('app.color.black'))
          .textAlign(TextAlign.Center)
        Text('完成')
          .fontWeight(500)
          .fontSize(16)
          .fontColor($r('app.color.common_main_color'))
      }
      .margin({ bottom: 4, top: 4 })

      Text('题目排序')
        .textTitle()
      // TODO 筛选按钮

      Text('选择分类')
        .textTitle()
      // TODO 筛选按钮
    }
    .padding(16)
    .backgroundColor($r('app.color.white'))
    .height('100%')
  }

  aboutToAppear(): void {
    this.getQuestionTypeList()
  }

  async getQuestionTypeList() {
    const res = await httpClient.request<QuestionType[]>({ url: 'question/type' })
    this.questionTypeList = res
  }

  @Builder
  TabBarBuilder(item: QuestionType, index: number) {
    Row({ space: 4 }) {
      Stack({ alignContent: Alignment.Bottom }) {
        Text(item.name)
          .fontSize(15)
          .height(44)
          .fontColor(this.activeIndex === index ? $r('app.color.black') : $r('app.color.common_gray_02'))
        Text()
          .width(this.activeIndex === index ? 20 : 0)
          .height(2)
          .backgroundColor($r('app.color.black'))
          .animation({ duration: this.activeIndex === index ? 300 : 0 })
      }

      if (item.displayNewestFlag === 1) {
        Image($r('app.media.ic_home_new'))
          .width(32)
          .height(14)
          .objectFit(ImageFit.Contain)
          .margin({ left: 4 })
      }

    }
    .padding({
      left: 16,
      right: this.questionTypeList.length - 1 === index ? 56 : 0
    })

  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Tabs({ index: this.activeIndex }) {
        ForEach(this.questionTypeList, (item: QuestionType, index) => {
          TabContent() {
            // 试题列表组件（上拉，下拉）
            QuestionListComp({ typeId: item.id })
          }
          .tabBar(this.TabBarBuilder(item, index))
        })
      }
      .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_border') })
      .barMode(BarMode.Scrollable)
      .barHeight(44)
      .onTabBarClick((index) => {
        this.activeIndex = index
      })

      //筛选按钮
      Row() {
        Image($r('app.media.ic_home_filter'))
          .width(24)
          .aspectRatio(1)
      }
      .width(56)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .linearGradient({
        angle: 90,
        colors: [['#00FFFFFF', 0], ['#FFFFFF', 0.285]]
      })
      .onClick(() => {
        this.show = true
      })
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor($r('app.color.white'))
    .bindSheet($$this.show, this.FilterSheetBuilder(), {
      showClose: false,
      height: 400
    })
  }
}

@Extend(Text)
function textTitle() {
  .fontSize(14)
  .fontWeight(500)
  .fontColor($r('app.color.black'))
  .width('100%')
  .margin({ top: 20 })
}
