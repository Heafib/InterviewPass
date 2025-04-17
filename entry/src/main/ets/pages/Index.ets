import { HomePage } from './HomePage'
import { InterviewPage } from './InterviewPage'
import { MinePage } from './MinePage'
import { ProjectPage } from './ProjectPage'

interface TabItem {
  name: string
  icon: Resource
  activeIcon: Resource
}

@Entry
@Component
struct Index {
  @StorageProp('bottomHeight')
  bottomHeight: number = 0
  @State
  activeIndex: number = 0
  // 基于tab数据来实现
  tabList: TabItem[] = [
    { name: '首页', icon: $r('app.media.tabbar_home'), activeIcon: $r('app.media.tabbar_home_fill') },
    { name: '项目', icon: $r('app.media.tabbar_project'), activeIcon: $r('app.media.tabbar_project_fill') },
    { name: '面经', icon: $r('app.media.tabbar_interview'), activeIcon: $r('app.media.tabbar_interview_fill') },
    { name: '我的', icon: $r('app.media.tabbar_mine'), activeIcon: $r('app.media.tabbar_mine_fill') }
  ]

  @Builder
  TabItemBuilder(item: TabItem, index: number) {
    Column({ space: 4 }) {
      Image(this.activeIndex === index ? item.activeIcon : item.icon)
        .width(24)
        .aspectRatio(1)
      Text(item.name)
        .fontSize(12)
        .fontColor(this.activeIndex === index ? $r('app.color.black') : $r('app.color.common_gray_01'))
    }
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: this.activeIndex }) {
        ForEach(this.tabList, (item: TabItem, index) => {
          TabContent() {
            if (index === 0) {
              HomePage()
            } else if (index === 1) {
              ProjectPage()
            } else if (index === 2) {
              InterviewPage()
            } else {
              MinePage()
            }
          }.tabBar(this.TabItemBuilder(item, index))
        })
      }
      .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_border') })
      .scrollable(false)
      .onTabBarClick((index) => {
        this.activeIndex = index
      })
      .margin({
        bottom: this.bottomHeight

      })
    }

    .height('100%')
    .width('100%')
  }
}