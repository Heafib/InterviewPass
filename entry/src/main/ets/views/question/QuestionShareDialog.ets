import { UserStoreKey } from '../../commons/utils/Auth'
import { QuestionDetail, User } from '../../models'
import { componentSnapshot, promptAction } from '@kit.ArkUI'
import { image } from '@kit.ImageKit'
import { fileIo } from '@kit.CoreFileKit'

@CustomDialog
export struct QuestionShareDialog {
  @Prop item: QuestionDetail
  @StorageProp(UserStoreKey) user: User = {} as User
  controller: CustomDialogController

  async saveImage() {
    // 保存到应用缓存
    // 截图
    const snap = await componentSnapshot.get('share')
    // 转成二进制图片
    const imagePacker = image.createImagePacker()
    const buffer = await imagePacker.packToData(snap, { format: 'image/jpeg', quality: 100 })
    // 写入文件
    const ctx = getContext(this)
    const imagePath = ctx.cacheDir + '/' + Date.now() + '.jpeg'
    const file = fileIo.openSync(imagePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    fileIo.writeSync(file.fd, buffer)
    fileIo.closeSync(file.fd)

    promptAction.showToast({ message: "保存成功" })
    // 保存到相册
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 20 }) {
        Image($r('app.media.ic_interview_logo'))
          .width(40)
          .height(40)
        Text('面试通，搞定企业面试题')
        Divider()
          .strokeWidth(0.5)
          .color($r('app.color.common_gray_border'))
        Text('大厂面试题：' + this.item.stem)
          .fontSize(12)
          .maxLines(2)
          .fontWeight(600)
          .width('100%')
          .lineHeight(24)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        QRCode(this.item.id)
          .width(160)
          .height(160)
          .alignSelf(ItemAlign.Center)
        Text('扫码查看答案')
          .fontSize(12)
          .alignSelf(ItemAlign.Center)
        Blank()
        Text('分享来自：' + this.user.nickName || this.user.username)
          .fontSize(12)
      }
      .id('share')
      .padding(20)
      .alignItems(HorizontalAlign.Start)
      .width(300)
      .height(500)
      .backgroundColor($r('app.color.white'))


      Row() {
        Text('保存到本地')
          .fontColor($r('app.color.white'))
          .fontSize(14)
          .padding(12)
          .backgroundColor($r('app.color.common_main_color'))
          .onClick(() => {
            this.saveImage()
          })
      }
      .borderRadius({ topLeft: 8 })
      .clip(true)
    }
    .borderRadius(8)
    .clip(true)
  }
}