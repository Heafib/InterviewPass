import { PageData, QuestionItem, QuestionListParams, SortType } from '../../models'
import { httpClient } from '../utils/HttpClient'
import { QuestionItemComp } from './QuestionItemComp'
import { promptAction } from '@kit.ArkUI'

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
  @Prop
  typeId: number
  @Prop
  @Watch('onChange')
  sort: SortType = SortType.Default
  @Prop
  page: number
  @Prop
  activeIndex: number
  @Prop
  index: number

  onChange() {
    if (this.activeIndex === this.index) {
      // 排序改变触发更新（当前激活的选项卡的试题列表才触发）
      this.isRefresh = true
    }
  }

  // 获取试题列表
  getQuestionList(): Promise<PageData<QuestionItem>> {
    return httpClient.request<PageData<QuestionItem>>({
      url: 'question/list',
      params: {
        type: this.typeId,
        questionBankType: 10,
        sort: this.sort,
        page: 10
      } as QuestionListParams
    })
  }

  async onRefresh() {
    // 更新第一页数据
    this.page = 1
    const res = await this.getQuestionList()
    this.list = res.rows
    this.isRefresh = false
    // 有没有更多数据
    if (this.page >= res.pageTotal) {
      this.isFinish = true
    } else {
      this.isFinish = false
      this.page++
    }
    promptAction.showToast({
      message: '已更新'
    })
  }

  async onLoad() {
    this.isLoading = true
    const res = await this.getQuestionList()
    this.list.push(...res.rows)
    this.isLoading = false
    // 有没有更多数据
    if (this.page >= res.pageTotal) {
      this.isFinish = true
    } else {
      this.page++
    }
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
        ForEach(this.list, (item: QuestionItem) => {
          ListItem() {
            QuestionItemComp({
              item
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