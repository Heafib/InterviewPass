import { logger } from '../commons/utils/Logger'

@Component
export struct ProjectPage {
  // 1.使用 grid 布局 栅格布局
  // 2.所有点的代表一个月多少天
  // 3.每个月第一天星期几需要便宜
  // 4.激活当前日期

  @State
  days: Date[] = []
  @State
  offsetDate: number = 0
  @State
  curDate: Date = new Date()

  aboutToAppear(): void {
    //1 当前月的天数
    // 取得下个月的号是0的日期（当前月最后一天的日期）
    const now = new Date()
    const year = now.getFullYear()
    const month = now.getMonth()
    const date = now.getDate()
    const currentMonthLastDate = new Date(year, month + 1, 0).getDate()
    logger.info("当前月最后一天", currentMonthLastDate.toString())
    for (let index = 1; index <= currentMonthLastDate; index++) {
      this.days.push(new Date(year, month, index))
    }
    //  每个月第一天星期几需要偏移
    const firstDate = this.days[0]
    this.offsetDate = firstDate.getDay()
    // 算出当前日期0点整数毫秒的时间
    this.curDate = new Date(year, month, date)

  }

  build() {
    Column() {
      GridRow({ columns: 7, gutter: 16 }) {
        ForEach(this.days, (date: Date, i) => {
          GridCol({ offset: i === 0 ? this.offsetDate : 0 }) {
            Text()
              .width(8)
              .height(8)
              .border({
                width: 2,
                color: this.curDate.getTime() === date.getTime()
                  ? $r('app.color.common_green')
                  : $r('app.color.common_gray_01'),
                radius: 4
              })
          }
        })

      }
    }
  }
}