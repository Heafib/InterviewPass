import abilityAccessCtrl, { Context, Permissions } from '@ohos.abilityAccessCtrl';

class Permission {
  // 用户授权
  async fromUser(permissionList: Permissions[]) {
    const ctx = AppStorage.get<Context>('context')
    if (!ctx) {
      return false
    }
    const atManager = abilityAccessCtrl.createAtManager()
    const result = await atManager.requestPermissionsFromUser(ctx, permissionList)
    return result.authResults.every(e => e === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
  }

  // 二次授权
  async onSetting(permissionList: Permissions[]) {
    const ctx = AppStorage.get<Context>('context')
    if (!ctx) {
      return false
    }
    const atManager = abilityAccessCtrl.createAtManager()
    const result = await atManager.requestPermissionOnSetting(ctx, permissionList)
    return result.every(e => e === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
  }
}

export const permission = new Permission()