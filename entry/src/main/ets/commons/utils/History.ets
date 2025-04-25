import { preferences } from '@kit.ArkData'

class History {
  store: preferences.Preferences | null = null

  // 初始化store
  getStore() {
    if (!this.store) {
      const context = AppStorage.get<Context>('context')
      this.store = preferences.getPreferencesSync(context, { name: 'history-store' })
    }
    return this.store
  }

  // 存储
  async setItem(keyword: string) {
    this.getStore().putSync(keyword, keyword)
    await this.getStore().flush()
  }

  // 删除
  async delItem(keyword: string) {
    this.getStore().deleteSync(keyword)
    this.getStore().flush()
  }

  // 清空
  async clear() {
    this.getStore().clearSync()
    await this.getStore().flush()
  }

  // 获取所有
  getAll() {
    const obj = this.getStore().getAllSync()
    return Object.keys(obj)
  }
}

export const history = new History()