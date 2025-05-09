import { relationalStore, ValuesBucket } from '@kit.ArkData'

export interface InterviewAudioItem extends ValuesBucket {
  id: number | null
  user_id: string
  name: string
  path: string
  duration: number
  size: number
  create_time: number
}

class AudioDB {
  store?: relationalStore.RdbStore
  tableName = 'interview_audio'

  // 初始化数据库实例
  async initDB() {
    const ctx = AppStorage.get<Context>('context')
    if (ctx) {
      const store = await relationalStore.getRdbStore(ctx, {
        name: 'interview_record.db',
        securityLevel: relationalStore.SecurityLevel.S2
      })
      // 第一次创建数据库
      if (store.version === 0) {
        // 建表
        await store.executeSql(`
        CREATE TABLE IF NOT EXISTS ${this.tableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          path TEXT NOT NULL,
          duration INTEGER NOT NULL,
          size INTEGER NOT NULL,
          create_time INTEGER NOT NULL
        )
      `)
        store.version = 2
      }
      this.store = store
    }
  }

  /**
   * 新增录音
   * @param item
   */
  async insert(item: InterviewAudioItem) {
    const rowId = await this.store?.insert(this.tableName, item)
    if (rowId === undefined || rowId === -1) {
      return Promise.reject('insert fail')
    } else {
      return Promise.resolve()
    }
  }

  /**
   * 删除录音
   * @param id
   */
  async delete(id: number) {
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    const rows = this.store?.deleteSync(predicates)
    if (rows === undefined || rows === 0) {
      return Promise.reject('delete fail')
    } else {
      return Promise.resolve()
    }
  }

  /**
   * 修改
   * @param id
   * @returns
   */
  async update(item: InterviewAudioItem) {
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', item.id)
    const rows = this.store?.updateSync(item, predicates)
    if (rows === undefined || rows === 0) {
      return Promise.reject('update fail')
    } else {
      return Promise.resolve()
    }
  }

  /**
   * 查询
   * @param userId
   * @returns
   */
  async query(userId: string) {
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('user_id', userId)
    const resultSet = await this.store?.query(predicates)
    if (resultSet === undefined) {
      return Promise.reject('query fail')
    }
    const list: InterviewAudioItem[] = []
    // 查询成功
    while (resultSet.goToNextRow()) {
      list.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        user_id: resultSet.getString(resultSet.getColumnIndex('user_id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        path: resultSet.getString(resultSet.getColumnIndex('path')),
        duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
        size: resultSet.getLong(resultSet.getColumnIndex('size')),
        create_time: resultSet.getLong(resultSet.getColumnIndex('create_time'))
      })
    }
    resultSet.close()
    return Promise.resolve(list)
  }
}

export const audioDB = new AudioDB()