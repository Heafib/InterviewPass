// 维护 key
// 提供操作用户信息方法
import { User } from '../../models'
import { router } from '@kit.ArkUI'

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

  // 鉴权
  checkAuth(option: Function | router.RouterOptions) {

    const user = this.getUser()
    if (typeof option === 'function') {
      // 1 执行某些逻辑判断 判断是否需要登录，如果登录， 就执行，如果没有，就跳转登录页
      if (user.token) {
        // 执行业务逻辑
        option()
      } else {
        router.pushUrl({
          url: 'pages/LoginPage'
        })
      }
    } else {
      // 2.跳转页面的时候，判断是否登录，如果登录了，跳转到目标页面，如果没有，跳转到登录页，登录成功后跳转到目标页面并带参数
      if (user.token) {
        // 执行业务逻辑
        router.pushUrl(option)
      } else {
        // 跳转到登陆 目标url+param
        // 登录成功，取出目标url+param 进行跳转
        const param = option.params as Record<string, string> || {}
        param.returnUrl = option.url
        router.pushUrl({
          url: 'pages/LoginPage',
          params: param
        })
      }
    }
  }
}

export const auth = new Auth()