import { preferences } from '@kit.ArkData';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct TestPage {
  store: preferences.Preferences | null = null

  aboutToAppear(): void {
    this.store = preferences.getPreferencesSync(getContext(this), { name: 'test' })
  }

  build() {
    Column() {
      Text('首选项：')
      Button('增')
        .onClick(() => {
          this.store?.putSync('name', 'jack')
          this.store?.flushSync()
        })
      Button('改')
        .onClick(() => {
          this.store?.putSync('name', 'tom')
          this.store?.flushSync()
        })
      Button('查')
        .onClick(() => {
          const val = this.store?.getSync('name', '')
          promptAction.showToast({
            message: val?.toString()
          })
        })
      Button('删')
        .onClick(() => {
          this.store?.deleteSync('name')
          this.store?.flushSync()
        })
      Button('清空')
        .onClick(() => {
          preferences.deletePreferences(getContext(this), { name: 'test' })
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}