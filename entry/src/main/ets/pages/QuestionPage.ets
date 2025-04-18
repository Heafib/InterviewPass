import { logger } from '../commons/utils/Logger';
import { router } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';

@Entry
@Component
struct QuestionPage {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    logger.debug('QuestionPage Param', JSON.stringify(router.getParams()))
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('QuestionPageHelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
        })
    }
    .height('100%')
    .width('100%')
  }
}