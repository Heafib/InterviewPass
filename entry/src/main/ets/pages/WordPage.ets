import { HNavBar } from '../commons/components/HNavBar'
import { util } from '@kit.ArkTS'
import { logger } from '../commons/utils/Logger'

export interface WordItem {
  zh: string
  en: string
  code: string
}

type Words = Record<string, WordItem[]>

@Entry
@Component
struct WordPage {
  @State
  wordKey: string = ''
  words: Words = {}

  aboutToAppear(): void {
    this.initWords()
  }

  async initWords() {
    const ctx = getContext(this)
    const data = ctx.resourceManager.getRawFileContentSync('word.json')
    const textDecode = util.TextDecoder.create()
    const json = textDecode.decodeToString(data)
    logger.debug('json', json)
    this.words = JSON.parse(json) as Words
    this.wordKey = Object.keys(this.words)[0]
  }

  build() {
    Column() {
      HNavBar({ title: '常用单词', showRightIcon: false })
      Row() {
        Column({ space: 4 }) {
          Text('开发常用词汇')
          Text(`共 ${this.words[this.wordKey].length} 个单词`)
            .fontSize(12)
            .fontColor($r('app.color.common_gray_03'))
        }
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(this.wordKey)
            .fontSize(12)
            .fontColor($r('app.color.common_gray_01'))
          Image($r('sys.media.ohos_ic_public_arrow_down'))
            .width(16)
            .aspectRatio(1)
            .fillColor($r('app.color.common_gray_01'))
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
      .border({ width: { top: 0.5 }, color: $r('app.color.common_gray_bg') })

      Divider()
        .strokeWidth(8)
        .color($r('app.color.common_gray_bg'))

      List() {
        ForEach(this.words[this.wordKey], (item: WordItem) => {

          ListItem() {
            Row({ space: 6 }) {
              Image($r('sys.media.ohos_ic_public_sound'))
                .width(20)
                .aspectRatio(1)
                .alignSelf(ItemAlign.Start)
                .fillColor($r('app.color.common_gray_03'))
              Column({ space: 10 }) {
                Text(item.en)
                  .fontWeight(FontWeight.Bold)
                Text(item.zh)
                  .fontSize(14)
                  .fontColor($r('app.color.common_gray_03'))
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Row() {
                Text('详细代码')
                  .fontSize(12)
                  .fontColor(item.code ? $r('app.color.common_gray_01') : '#ddd')
                Image($r('sys.media.ohos_ic_public_arrow_right'))
                  .width(16)
                  .aspectRatio(1)
                  .fillColor(item.code ? $r('app.color.common_gray_01') : '#ddd')
              }
              .alignSelf(ItemAlign.End)
            }
            .padding(16)
          }
        })
      }
      .divider({
        strokeWidth: 0.5,
        color: $r('app.color.common_gray_bg')
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}