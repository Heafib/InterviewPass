import { HNavBar } from '../commons/components/HNavBar'
import { HTag } from '../commons/components/HTag'
import { QuestionDetail, QuestionDetailParams, QuestionOptParams } from '../models'
import { promptAction, router } from '@kit.ArkUI'
import { httpClient } from '../commons/utils/HttpClient'
import { webview } from '@kit.ArkWeb'
import { HLoadingDialog } from '../commons/components/HLoadingDialog'
import { QuestionShareDialog } from '../views/question/QuestionShareDialog'
import { tracking } from '../commons/utils/Tracking'


@Entry
@Component
struct QuestionPage {
  @StorageProp('bottomHeight') bottomHeight: number = 0
  @State
  item: QuestionDetail = {} as QuestionDetail
  @State
  list: QuestionDetail[] = []
  @State
  activeIndex: number = 0
  startTime: number = Date.now()
  webController = new webview.WebviewController()
  dialog = new CustomDialogController({
    builder: HLoadingDialog(),
    customStyle: true,
    alignment: DialogAlignment.Center
  })
  shareDialog = new CustomDialogController({
    builder: QuestionShareDialog({ item: this.item }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  onPageShow(): void {
    this.startTime = Date.now()
  }

  onPageHide(): void {
    this.dialog.close()
    tracking.record(this.item.id, this.startTime, Date.now())
    tracking.report()
  }

  async aboutToAppear() {
    const params = router.getParams() as QuestionDetailParams
    if (params) {
      this.item = params.item as QuestionDetail
      this.list = params.list as QuestionDetail[] // 里面数据并不是完整的

      // 么有答案才请求
      if (!this.item.answer) {
        this.activeIndex = this.list.findIndex(item => item.id === this.item.id)
        this.item = await this.getQuestionDetail(this.item.id)
        this.list[this.activeIndex] = this.item
      }
      this.webController.loadUrl($rawfile('question.html'))

    }
  }

  async getQuestionDetail(id: string) {
    this.dialog.open()
    const res = await httpClient.request<QuestionDetail>({ url: `/question/${id}` })
    this.dialog.close()
    return res
  }

  // 点赞 收藏 取消点赞 取消收藏
  async questionOpt(optType: 1 | 2, flag: 0 | 1) {
    try {
      // 1. 准备参数
      const data: QuestionOptParams = {
        id: this.item.id,
        type: 0,
        optType
      }
      // 2. 发送请求
      await httpClient.request<null, QuestionOptParams>({
        url: flag === 1 ? '/question/opt' : '/question/unOpt',
        method: 'post',
        data
      })
      // 3. 更改状态
      if (optType === 1) {
        this.item.likeFlag = flag
        promptAction.showToast({
          message: flag === 1 ? '点赞成功' : '取消点赞'
        })
      }
      if (optType === 2) {
        this.item.collectFlag = flag
        promptAction.showToast({
          message: flag === 1 ? '收藏成功' : '取消收藏'
        })
      }
    } catch (e) {
      promptAction.showToast({
        message: '操作失败'
      })
    }
  }

  async toggle(step: number) {
    const index = this.activeIndex + step
    if (index < 0 || index > this.list.length - 1) {
      return promptAction.showToast({
        message: '没有更多了'
      })
    }

    //记录学习时间
    tracking.record(this.item.id, this.startTime, Date.now())
    this.startTime = Date.now()

    this.activeIndex = index
    const item = this.list[index]
    if (item.answer) {
      // 如果列表中根据索引查处的试题是完整的，直接赋值给item
      this.item = item
    } else {
      // 如果不是完整的，发请求获取，存储到数组中再赋值给item
      const fullItem = await this.getQuestionDetail(item.id)
      this.list[index] = fullItem
      this.item = fullItem
    }
    // 切换答案
    this.webController.runJavaScript(`writeHtml(\`${this.item.answer}\`)`)
  }

  @Builder
  TitleBuilder(text: string) {
    Row() {
      Text()
        .width(2)
        .height(12)
        .backgroundColor($r('app.color.black'))
        .margin({ right: 13 })
      Text(text)
        .fontWeight(700)
    }
    .width('100%')
    .padding({ top: 10 })
    .height(32)
  }

  @Builder
  MenuBuilder() {
    Menu() {
      MenuItem({ content: this.item.likeFlag ? '取消点赞' : '点赞' })
        .onClick(() => {
          this.questionOpt(1, this.item.likeFlag === 1 ? 0 : 1)
        })
      MenuItem({ content: this.item.collectFlag ? '取消收藏' : '收藏' })
        .onClick(() => {
          this.questionOpt(2, this.item.collectFlag === 1 ? 0 : 1)
        })
      MenuItem({ content: '点我反馈' })
      MenuItem({ content: '试题分享' })
        .onClick(() => {
          this.shareDialog.open()
        })
    }
    .width(108)
  }

  build() {
    Column() {
      HNavBar({ title: '试题详情', showRightIcon: false })
      // 题目
      this.TitleBuilder('题目：')
      Text(this.item.stem)
        .width('100%')
        .padding(16)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: 12 }) {
        ForEach(this.item.stage, (tag: string) => {
          HTag({ text: tag })
        })
        Blank()
        Image($r("app.media.ic_home_more"))
          .width(20)
          .aspectRatio(1)
          .bindMenu(this.MenuBuilder())

      }
      .width('100%')
      .padding({ bottom: 16, left: 16, right: 16 })

      Divider()
        .strokeWidth(8)
        .color($r('app.color.common_gray_bg'))
      // 内容
      this.TitleBuilder('答案：')

      Web({
        src: $rawfile('question.html'),
        controller: this.webController
      })
        .width('100%')
        .layoutWeight(1)
        .onPageEnd(() => {
          // 页面加载完毕
          if (this.item.answer) {
            this.webController.runJavaScript(`writeHtml(\`${this.item.answer}\`)`)
          }
        })
      Row({ space: 80 }) {
        Row() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(20)
            .aspectRatio(1)
            .fillColor(this.activeIndex <= 0 ? $r('app.color.common_gray_01') : $r('app.color.common_gray_03'))
          Text(' 上一题')
            .fontColor(this.activeIndex <= 0 ? $r('app.color.common_gray_01') : $r('app.color.common_gray_03'))
        }
        .onClick(() => {

          this.toggle(-1)
        })

        Row() {
          Text('下一题 ')
            .fontColor(this.activeIndex >= this.list.length - 1 ? $r('app.color.common_gray_01') :
            $r('app.color.common_gray_03'))
          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(20)
            .aspectRatio(1)
            .fillColor(this.activeIndex >= this.list.length - 1 ? $r('app.color.common_gray_01') :
            $r('app.color.common_gray_03'))
        }
        .onClick(() => {
          this.toggle(1)
        })
      }
      .height(44)
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: this.bottomHeight })
  }
}