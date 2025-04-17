import { QuestionListComp } from '../../commons/components/QuestionListComp'
import { httpClient } from '../../commons/utils/HttpClient'
import { QuestionType, SortType } from '../../models'

@Component
export struct HomeCategory {
  @State
  activeIndex: number = 0
  @State
  sort: number = SortType.Default
  @State
  questionTypeList: QuestionType[] = []
  @State
  show: boolean = false
  //支持筛选
  @State
  filterDateSort: SortType = SortType.Default
  @State
  filterDataIndex: number = 0

  @Builder
  FilterSheetBuilder() {
    Column() {
      Row() {
        Text('重置')
          .fontSize(16)
          .fontWeight(500)
          .fontColor($r('app.color.common_gray_03'))
          .onClick(() => {
            this.filterDateSort = SortType.Default
            this.filterDataIndex = 0
          })
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
          .onClick(() => {
            this.activeIndex = this.filterDataIndex
            this.sort = this.filterDateSort
            this.show = false
          })
      }
      .margin({ bottom: 4, top: 4 })

      Text('题目排序')
        .textTitle()
      // TODO 筛选按钮
      Flex({ wrap: FlexWrap.Wrap }) {
        FilterButton({ text: '默认', selected: this.filterDateSort === SortType.Default })
          .onClick(() => {
            this.filterDateSort = SortType.Default
          })
        FilterButton({
          text: '浏览量',
          sort: this.filterDateSort,
          isSort: true,
          selected: this.filterDateSort === SortType.ViewLow || this.filterDateSort === SortType.ViewHigh
        })
          .onClick(() => {
            // 已选中
            if (this.filterDateSort === SortType.ViewLow || this.filterDateSort === SortType.ViewHigh) {
              this.filterDateSort = this.filterDateSort === SortType.ViewLow ? SortType.ViewHigh : SortType.ViewLow
            } else {
              this.filterDateSort = SortType.ViewHigh
            }
          })
        FilterButton({
          text: '难度',
          sort: this.filterDateSort,
          isSort: true,
          selected: this.filterDateSort === SortType.DifficultyLow || this.filterDateSort === SortType.DifficultyHigh
        })
          .onClick(() => {
            // 已选中
            if (this.filterDateSort === SortType.DifficultyLow || this.filterDateSort === SortType.DifficultyHigh) {
              this.filterDateSort =
                this.filterDateSort === SortType.DifficultyLow ? SortType.DifficultyHigh : SortType.DifficultyLow
            } else {
              this.filterDateSort = SortType.DifficultyHigh
            }
          })
        FilterButton({ text: '推荐', selected: this.filterDateSort === SortType.Commend })
          .onClick(() => {
            this.filterDateSort = SortType.Commend
          })
      }

      Text('选择分类')
        .textTitle()
      // TODO 筛选按钮
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.questionTypeList, (item: QuestionType, i) => {
          FilterButton({ text: item.name, isNew: item.displayNewestFlag === 1, selected: this.filterDataIndex === i })
            .onClick(() => {
              this.filterDataIndex = i
            })
        })
      }
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
            QuestionListComp({
              typeId: item.id,
              sort: this.sort,
              activeIndex: this.activeIndex,
              index: index
            })
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
        //
        this.filterDataIndex = this.activeIndex
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
  .margin({ top: 20, bottom: 12 })
}

@Component
struct FilterButton {
  @Prop
  text: string = ''
  @Prop
  isSort: boolean = false
  @Prop
  isNew: boolean = false
  @Prop
  selected: boolean = false
  @Prop
  sort: SortType = SortType.Default

  build() {
    Row() {
      Text(this.text)
        .fontSize(12)
        .fontColor(this.selected ? $r('app.color.common_main_color') : $r('app.color.black'))
      if (this.isSort) {
        // 偶数升序 奇数降序
        Column() {
          Image($r('sys.media.ohos_ic_public_arrow_up'))
            .size({
              width: 12, height: 6
            })
            .fillColor((this.selected && this.sort % 2 === 0) ? $r('app.color.common_main_color') :
            $r('app.color.black'))
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .size({
              width: 12, height: 6
            })
            .fillColor((this.selected && this.sort % 2 === 1) ? $r('app.color.common_main_color') :
            $r('app.color.black'))
        }
        .margin({
          left: 2
        })
      }
      if (this.isNew) {
        Image($r('app.media.ic_home_new'))
          .width(32)
          .height(14)
          .objectFit(ImageFit.Contain)
          .position({ right: -26, top: -7 })
      }
    }
    .height(32)
    .padding({
      left: 10,
      right: 10
    })
    .borderRadius(4)
    .backgroundColor($r('app.color.common_gray_bg'))
    .margin({
      bottom: 12,
      right: this.isNew ? 26 : 10
    })
  }
}
