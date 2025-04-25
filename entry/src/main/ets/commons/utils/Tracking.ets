import { TimeItem } from '../../models'
import { logger } from './Logger'
import { httpClient } from './HttpClient'

class Tracking {
  list: TimeItem[] = []

  // 记录
  record(questionId: string, startTime: number, endTime: number) {
    this.list.push({
      questionId,
      startTime,
      endTime
    })
    logger.debug("Track Log", JSON.stringify(this.list))
  }

  async report() {
    await httpClient.request<null>({
      url: 'time/tracking',
      method: 'post',
      data: { timeList: this.list }
    })
    this.list = []
  }
}

export const tracking = new Tracking()