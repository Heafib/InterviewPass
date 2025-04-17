import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { auth } from './Auth'
import { logger } from './Logger'

const instance = axios.create({
  baseURL: 'https://api-harmony-teach.itheima.net/hm/',
  timeout: 10000
})

// 伪代码 获取数据层级多 泛型传递麻烦
// interface HRes {
//   code: number
//   message: string
//   data: string[]
// }
//
// interface HReq {
//   page: number
// }
//
// instance<null, AxiosResponse<HRes, null>, HReq>({
//   method: 'post',
//   data: {
//     page: 100
//   }
// }).then(res => {
//   res.data.data
// })
//响应拦截器
instance.interceptors.response.use((res: AxiosResponse) => {
  // 返回数据，是将来请求得到的数据
  logger.info('HttpClient 响应', JSON.stringify(res.data))
  if (res.data.code === 10000) {
    return res.data.data
  }
  return Promise.reject(res.data)
}, (err: AxiosError) => {
  return Promise.reject(err)
})
// 请求拦截器
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const user = auth.getUser()
  if (user.token) {
    config.headers.Authorization = 'Bearer ' + user.token
  }
  return config
}, (err: AxiosError) => {
  return Promise.reject(err)
})

class HttpClient {
  // 请求参数和响应类型 泛型
  request<Res, Req = Object>(config: AxiosRequestConfig<Req>) {
    logger.info('HttpClient 请求', JSON.stringify(config))
    return instance <null, Res, Req>(config)
  }
}


export const httpClient = new HttpClient()