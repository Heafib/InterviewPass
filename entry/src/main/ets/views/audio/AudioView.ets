import { HNavBar } from '../../commons/components/HNavBar'
import { audioDB, InterviewAudioItem } from '../../commons/utils/AudioDB'
import { auth } from '../../commons/utils/Auth'
import { AudioItemComp } from './AudioItemComp'
import { AudioRecordComp } from './AudioRecordComp'
import { InputDialog } from './InputDialog'
import { fileIo } from '@kit.CoreFileKit'
import { AudioPlayer } from './AudioPlayer'

@Component
export struct AudioView {
  @State
  list: InterviewAudioItem[] = []
  @State
  isShow: boolean = false
  @State
  currentItem: InterviewAudioItem = {} as InterviewAudioItem
  dialog = new CustomDialogController({
    builder: InputDialog({
      name: this.currentItem.name,
      onSubmit: async (newName) => {
        // 更新
        this.dialog.close()
        this.currentItem.name = newName
        await audioDB.update(this.currentItem)
        this.getList()
      }
    }),
    customStyle: true,
    alignment: DialogAlignment.Center

  })

  @Builder
  PlayerBuilder() {
    Column() {
      AudioPlayer({ item: this.currentItem })
    }
  }

  aboutToAppear(): void {
    audioDB.initDB().then(() => {
      this.getList()
    })
  }

  async getList() {
    const list = await audioDB.query(auth.getUser().id)
    this.list = list
  }

  @Builder
  ListItemSwipeBuilder(item: InterviewAudioItem) {
    Row() {
      Text('编辑')
        .actionButton($r('app.color.common_blue'))
        .onClick(async () => {
          // 弹出编辑名称的对话框
          this.currentItem = item
          this.dialog.open()
        })
      Text('删除')
        .actionButton('#FF0033')
        .onClick(async () => {
          if (item.id) {
            await audioDB.delete(item.id)
            this.getList()
            // 删除文件
            fileIo.unlinkSync(item.path)
          }
        })
    }
    .height('100%')
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
                .onClick(() => {
                  this.currentItem = item
                  this.isShow = true
                })
            }
            .swipeAction({
              end: this.ListItemSwipeBuilder(item)
            })
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
    .width('100%')
    .height('100%')
    .bindContentCover($$this.isShow, this.PlayerBuilder())
  }
}

@Extend(Text)
function actionButton(color: ResourceColor) {
  .width(80)
  .aspectRatio(1)
  .backgroundColor(color)
  .textAlign(TextAlign.Center)
  .fontColor($r('app.color.white'))
}