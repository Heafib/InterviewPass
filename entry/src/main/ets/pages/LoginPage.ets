import { HNavBar } from '../commons/components/HNavBar'

@Entry
@Component
struct LoginPage {
  build() {
    Column() {
      HNavBar({ showRightIcon: false })
    }
    .height('100%')
    .width('100%')
  }
}