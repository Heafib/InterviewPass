import { HNavBar } from '../../commons/components/HNavBar'
import { audioDB, InterviewAudioItem } from '../../commons/utils/AudioDB'
import { auth } from '../../commons/utils/Auth'
import { AudioItemComp } from './AudioItemComp'
import { AudioRecordComp } from './AudioRecordComp'

@Component
export struct AudioView {
  @State
  list: InterviewAudioItem[] = []

  aboutToAppear(): void {
    audioDB.initDB().then(() => {
      this.getList()
    })
  }

  async getList() {
    const list = await audioDB.query(auth.getUser().id)
    this.list = list
  }

  build() {
    Column() {
      HNavBar({ title: '面试录音', showRightIcon: false })
      Column() {
        List() {
          ForEach(this.list, (item: InterviewAudioItem) => {
            ListItem() {
              AudioItemComp({
                item: item
              })
            }
          })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .layoutWeight(1)

      AudioRecordComp({
        onRecordEnd: async (item) => {
          // 入库
          await audioDB.insert(item)
          this.getList()
        }
      })
    }
  }
}