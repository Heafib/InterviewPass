import { window } from '@kit.ArkUI'

class FullScreen {
  // 需求
  // 提供 enable disable 开启 关闭 全屏
  // 提供安全区的高度，顶部和底部安全区
  // 需要context再appStorage 共享

  async enable() {
    const ctx = AppStorage.get<Context>('context')
    if (ctx) {
      const win = await window.getLastWindow(ctx)
      win.setWindowLayoutFullScreen(true)
      // 获取安全区高度
      const top = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect
      AppStorage.setOrCreate('topHeight', px2vp(top.height))
      const bottom = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect
      AppStorage.setOrCreate('bottomHeight', px2vp(bottom.height))
    }
  }

  async disable() {
    const ctx = AppStorage.get<Context>('context')
    if (ctx) {
      const win = await window.getLastWindow(ctx)
      win.setWindowLayoutFullScreen(false)
      AppStorage.setOrCreate('topHeight', 0)
      AppStorage.setOrCreate('bottomHeight', 0)

    }
  }
}

export const fullScreen = new FullScreen()