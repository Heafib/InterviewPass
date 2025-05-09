import { ConfigurationConstant } from '@kit.AbilityKit'

export const ColorModeKey: string = 'color-mode-key'

class Theme {
  // 应用默认浅色
  initTheme() {
    // 持久化颜色主题，默认值亮色模式
    PersistentStorage.persistProp<ConfigurationConstant.ColorMode>(ColorModeKey,
      ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
    // 取出现在应用存储的颜色主题模式
    const colorMode = AppStorage.get<ConfigurationConstant.ColorMode>(ColorModeKey)
    // 设置应用颜色主题模式
    this.setTheme(colorMode!)
  }

  // 设置颜色模式
  setTheme(mode: ConfigurationConstant.ColorMode) {
    AppStorage.set<ConfigurationConstant.ColorMode>(ColorModeKey, mode)
    const ctx = AppStorage.get<Context>('context')
    ctx?.getApplicationContext().setColorMode(mode)
  }

  // 跟随系统
  notSet() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
  }

  // 浅色
  setLight() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
  }

  // 深色
  setDark() {
    this.setTheme(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
  }
}

export const theme = new Theme()