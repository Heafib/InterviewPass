// 维护 key
// 提供操作用户信息方法
import { User } from '../../models'

export const UserStoreKey = 'user'

class Auth {
  initUser() {
    PersistentStorage.persistProp<User>(UserStoreKey, {} as User)

  }

  getUser() {
    return AppStorage.get<User>(UserStoreKey) || {} as User
  }

  setUser(user: User) {
    AppStorage.setOrCreate(UserStoreKey, user)
  }
}

export const auth = new Auth()