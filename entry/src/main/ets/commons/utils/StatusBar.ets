import { window } from '@kit.ArkUI'
import { logger } from './Logger'

class StatusBar {
  // setBar setLightBar setDarkBar

  async setBar(properties: window.SystemBarProperties) {
    try {
      const ctx = AppStorage.get<Context>('context')
      if (ctx) {
        const win = await window.getLastWindow(ctx)
        await win.setWindowSystemBarProperties(properties)
      }
    } catch (e) {
      logger.error('StatusBar setBar', JSON.stringify(e))
    }
  }

  async setLightBar() {
    this.setBar({
      statusBarContentColor: '#ffffff'
    })
  }

  async setDarkBar() {
    this.setBar({
      statusBarContentColor: '#000000'
    })
  }
}

export const statusBar = new StatusBar()