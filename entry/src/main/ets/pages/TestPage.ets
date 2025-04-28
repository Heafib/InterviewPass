import relationalStore from '@ohos.data.relationalStore'
import { BusinessError } from '@kit.BasicServicesKit'
import { logger } from '../commons/utils/Logger'
import { promptAction } from '@kit.ArkUI'
import { ValuesBucket } from '@kit.ArkData'

@Entry
@Component
struct TestPage {
  store?: relationalStore.RdbStore
  tableName: string = 'article'
  list: Article[] = []

  aboutToAppear(): void {

  }

  async createStore() {
    const ctx = getContext(this)
    // 建库
    const store = await relationalStore.getRdbStore(ctx, {
      name: 'article.db',
      securityLevel: relationalStore.SecurityLevel.S1
    })
    // 建表
    await store.executeSql(`
    CREATE TABLE IF NOT EXISTS ${this.tableName} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    create_time INTEGER NOT NULL
    )
    `)
    this.store = store
  }

  build() {
    Column({ space: 10 }) {
      Text('关系型数据库')
      Button('初始化数据库')
        .onClick(() => {
          this.createStore()
        })
      Button('添加文章')
        .onClick(() => {
          this.store?.insert(this.tableName, {
            title: '第一篇文字',
            content: '文字呃逆日日日日日日日日日日日日日日',
            create_time: Date.now()
          }).catch((e: BusinessError) => {
            logger.error('store?.insert', JSON.stringify(e))
          })
        })
      Button('查询文章数量')
        .onClick(async () => {
          const pre = new relationalStore.RdbPredicates(this.tableName)
          const res = await this.store?.query(pre)
        }
        )
      Button('查询文章')
        .onClick(async () => {
          const pre = new relationalStore.RdbPredicates(this.tableName)
          const res = await this.store?.query(pre)
          const list: Article[] = []
          if (res) {
            while (res.goToNextRow()) {
              list.push({
                id: res.getLong(res.getColumnIndex('id')),
                title: res.getString(res.getColumnIndex('title')),
                content: res.getString(res.getColumnIndex('content')),
                create_time: res.getString(res.getColumnIndex('create_time')),
              })
            }
          }
          res?.close()
          this.list = list
          promptAction.showDialog({
            message: JSON.stringify(list)
          })
        })
      Button('修改文章')
        .onClick(async () => {
          const item = this.list[0]
          if (item) {
            const pre = new relationalStore.RdbPredicates(this.tableName)
            pre.equalTo('id', item.id)
            item.title = '修改标题'
            this.store?.updateSync(item, pre);
            promptAction.showToast({
              message: '修改成功'
            })
          }
        }
        )
      Button('删除最后一条文章')
        .onClick(async () => {
          const item = this.list[this.list.length-1]
          if (item) {
            const pre = new relationalStore.RdbPredicates(this.tableName)
            pre.equalTo('id', item.id)
            this.store?.deleteSync(pre);
            promptAction.showToast({
              message: '删除成功'
            })
          }
        }
        )
      Button('删除数据库')
        .onClick(async () => {
          const ctx = getContext(this)
          const store = await relationalStore.deleteRdbStore(ctx, {
            name: 'article.db',
            securityLevel: relationalStore.SecurityLevel.S1
          })
        })

    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}

interface Article extends ValuesBucket {
  id: number
  title: string
  content: string
  create_time: string
}