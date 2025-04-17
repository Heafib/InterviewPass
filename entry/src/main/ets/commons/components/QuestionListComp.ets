import { QuestionItem } from '../../models'
import { QuestionItemComp } from './QuestionItemComp'

@Component
export struct QuestionListComp {
  @State
  isRefresh: boolean = false
  @State
  isLoading: boolean = false
  @State
  isFinish: boolean = false
  @State
  list: QuestionItem[] = []

  onRefresh() {
    // 模拟刷新
    setTimeout(() => {
      this.isRefresh = false
    }, 1000)
  }

  onLoad() {
    this.isLoading = true
    setTimeout(() => {
      for (let index = 0; index < 10; index++) {
        this.list.push({} as QuestionItem)
      }
      this.isLoading = false
      if (this.list.length >= 40) {
        this.isFinish = true
      }
    }, 1000)
  }

  @Builder
  LoadMoreBuilder() {
    ListItem() {
      // 是否加载完毕
      if (this.isFinish) {
        Row() {
          Text('没有更多了')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_03'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.isLoading) {
        Row({ space: 20 }) {
          LoadingProgress()
            .width(20)
          Text('正在加载...')
            .fontSize(14)
            .fontColor($r('app.color.common_gray_03'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .height(80)
  }

  build() {
    Refresh({ refreshing: $$this.isRefresh }) {
      List() {
        ForEach(this.list, () => {
          ListItem() {
            QuestionItemComp({
              item: {
                id: '100',
                stem: '请说下ArkUI的容器组件有哪些？',
                difficulty: 3,
                likeCount: 23,
                views: 423,
                readFlag: 1
              }
            })
          }
        })
        // 加载更多
        this.LoadMoreBuilder()
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .divider({
        strokeWidth: 0.5,
        color: $r('app.color.common_gray_border'),
        startMargin: 16,
        endMargin: 16
      })
      .width('100%')
      .height('100%')
      .onReachEnd(() => {
        //没有更多数据，正在加载中，正在刷新中，都不能加载
        if (this.isFinish || this.isLoading || this.isRefresh) {
          return
        }
        this.onLoad()
      })
    }
    .onRefreshing(() => {
      this.onRefresh()
    })
  }
}