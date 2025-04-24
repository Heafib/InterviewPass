import { HNavBar } from '../commons/components/HNavBar';
import { router } from '@kit.ArkUI';
import webview from '@ohos.web.webview';

@Entry
@Component
struct WebPage {
  webController = new webview.WebviewController()
  @State
  src: string = ''
  @State
  title: string = ''

  aboutToAppear(): void {
    const param = router.getParams() as Record<string, string>
    this.src = param.src
    this.title = param.title
  }

  build() {
    Column() {
      HNavBar({ title: this.title, showRightIcon: false })
      Web({
        src: this.src,
        controller: this.webController
      })
        .width('100%')
        .height('100%')
        .layoutWeight(1)
    }
    .height('100%')
    .width('100%')
  }
}