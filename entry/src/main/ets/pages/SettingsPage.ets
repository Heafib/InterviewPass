import { router } from '@kit.ArkUI';
import { HNavBar } from '../commons/components/HNavBar';
import { auth } from '../commons/utils/Auth';
import { ColorModeKey } from '../commons/utils/Theme';
import { User } from '../models';
import { SettingsThemeDialog } from '../views/setting/SettingsThemeDialog';
import { bundleManager, common, ConfigurationConstant, Want } from '@kit.AbilityKit';
import { fileIo, storageStatistics } from '@kit.CoreFileKit';

export interface Tool {
  icon?: ResourceStr
  name: string
  value?: string
  onClick?: () => void,
  radius?: 0 | 1 | 2
}

@Entry
@Component
struct SettingsPage {
  @StorageProp(ColorModeKey)
  colorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
  themeDialog = new CustomDialogController({
    builder: SettingsThemeDialog(),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })
  @State
  cache: string = '0MB'
  @State
  version: string = ''

  aboutToAppear(): void {
    this.getVersion()
  }

  async getVersion() {
    const info = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    this.version = 'V' + info.versionName
  }

  calcCache() {
    storageStatistics.getCurrentBundleStats()
      .then(res => {
        this.cache = (res.cacheSize / (1000 * 1000)).toFixed(2) + 'MB'
      })
  }

  async clearCache() {
    const ctx = getContext(this)
    // hap缓存
    const ctxCacheDir = ctx.cacheDir
    const ctxExist = fileIo.accessSync(ctxCacheDir)
    if (ctxExist) {
      fileIo.rmdirSync(ctxCacheDir)
    }
    // 应用
    const appCtx = ctx.getApplicationContext()
    const appCacheDir = appCtx.cacheDir
    const appCacheExist = fileIo.accessSync(appCacheDir)
    if (appCacheExist) {
      fileIo.rmdirSync(appCacheDir)
    }
    this.calcCache()
  }

  onPageShow(): void {
    this.calcCache()
  }

  @Builder
  toolsBuilder(tool: Tool) {
    Row() {
      if (tool.icon) {
        Image(tool.icon)
          .width(16)
          .aspectRatio(1)
          .margin({ right: 12 })
      }
      Text(tool.name)
        .fontSize(16)
      Blank()
      if (tool.value) {
        Text(tool.value)
          .fontSize(14)
          .fontColor($r('app.color.common_gray_01'))
          .margin({ right: 10 })
      }
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(18)
        .aspectRatio(1)
        .fillColor($r('app.color.common_gray_01'))
    }
    .height(50)
    .width('100%')
    .backgroundColor($r('app.color.white'))
    .padding({ left: 16, right: 10 })
    .borderRadius({
      topLeft: tool.radius === 1 ? 8 : 0,
      topRight: tool.radius === 1 ? 8 : 0,
      bottomLeft: tool.radius === 2 ? 8 : 0,
      bottomRight: tool.radius === 2 ? 8 : 0
    })
    .onClick(() => {
      tool.onClick && tool.onClick()
    })
  }

  build() {
    Column() {
      HNavBar({ title: '设置', showRightIcon: false, showBorder: true })
      Column({ space: 0.5 }) {
        Blank()
          .height(15)
        this.toolsBuilder({
          name: '编辑资料', radius: 1, onClick: () => {
            auth.checkAuth({
              url: 'pages/ProfilePage'
            })
          }
        })
        this.toolsBuilder({ name: '账号设置', radius: 2 })
        Blank()
          .height(15)
        this.toolsBuilder({
          name: '消息推送', radius: 1, onClick: () => {
            let want: Want = {
              bundleName: 'com.huawei.hmos.settings',
              abilityName: 'com.huawei.hmos.settings.MainAbility',
              // 具体页面
              uri: 'application_info_entry',
              parameters: {
                // 应用包名
                pushParams: 'com.heafib.interviewpass'
              }
            };
            const context = getContext(this) as common.UIAbilityContext
            context.startAbility(want)
          }
        })
        this.toolsBuilder({
          name: '深色模式',
          value: this.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? '已开启' : '已关闭',
          radius: 1,
          onClick: () => {
            //  设置主题
            this.themeDialog.open()
          }
        })
        this.toolsBuilder({
          name: '清除应用缓存', value: this.cache, onClick: () => {
            //  清除缓存
            this.clearCache()
          }
        })
        this.toolsBuilder({ name: '当前版本', value: this.version, radius: 2 })
        Blank()
          .height(15)
        Text('退出账号')
          .height(50)
          .fontColor($r('app.color.common_main_color'))
          .opacity(0.6)
          .onClick(async () => {
            auth.setUser({} as User)
            router.back()
          })
      }
      .layoutWeight(1)
      .padding({ right: 15, left: 15 })
      .backgroundColor($r('app.color.common_gray_bg'))
    }
  }
}