import { QuestionListComp } from '../../commons/components/QuestionListComp'
import { httpClient } from '../../commons/utils/HttpClient'
import { QuestionType } from '../../models'

@Component
export struct HomeCategory {
  @State
  activeIndex: number = 0
  @State
  questionTypeList: QuestionType[] = []

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
      right: this.questionTypeList.length - 1 === index ? 16 : 0
    })

  }

  build() {
    Column() {
      Tabs({ index: this.activeIndex }) {
        ForEach(this.questionTypeList, (item: QuestionType, index) => {
          TabContent() {
            // 试题列表组件（上拉，下拉）
            QuestionListComp()
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
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor($r('app.color.white'))
  }
}