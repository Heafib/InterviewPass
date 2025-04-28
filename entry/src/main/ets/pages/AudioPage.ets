import { HNavBar } from '../commons/components/HNavBar'
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit'
import { logger } from '../commons/utils/Logger'

@Entry
@Component
struct AudioPage {
  aboutToAppear(): void {
    this.requestPermission()
  }

  async requestPermission() {
    // 1.用户授权
    const permissionList: Permissions[] = ['ohos.permission.MICROPHONE']
    const ctx = getContext(this)
    const atManager = abilityAccessCtrl.createAtManager()
    const res = await atManager.requestPermissionsFromUser(ctx, permissionList)
    const flag = res.authResults.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    logger.debug('requestPermissionUser', String(flag))
    // 2.二次授权
    if (!flag) {
      const result = await atManager.requestPermissionOnSetting(ctx, permissionList)
      const flag2 = result.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
      logger.debug('requestPermissionSetting', String(flag2))
    }
  }

  build() {
    Column({ space: 20 }) {
      HNavBar({ title: '面试录音', showRightIcon: false })
    }
    .height('100%')
    .width('100%')
  }
}