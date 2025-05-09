import { HLoadingDialog } from '../commons/components/HLoadingDialog'
import { HNavBar } from '../commons/components/HNavBar'
import { auth, UserStoreKey } from '../commons/utils/Auth'
import { httpClient } from '../commons/utils/HttpClient'
import { User } from '../models'
import promptAction from '@ohos.promptAction'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { fileIo } from '@kit.CoreFileKit'
import { FormData } from '@ohos/axios'

@Entry
@Component
struct ProfilePage {
  @StorageProp(UserStoreKey) user: User = {} as User
  dialog: CustomDialogController = new CustomDialogController({
    builder: HLoadingDialog({ message: '更新中...' }),
    customStyle: true,
    alignment: DialogAlignment.Center
  })

  async updateNickname() {
    await httpClient.request<null>({
      url: 'userInfo/profile',
      method: 'post',
      data: {
        nickName: this.user.username
      }
    })
    promptAction.showToast({
      message: '修改昵称成功'
    })
    auth.setUser(this.user)
  }

  async updateAvatar() {
    //选中相册图片
    const picker = new photoAccessHelper.PhotoViewPicker()
    const selectOp = new photoAccessHelper.PhotoSelectOptions()
    selectOp.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
    selectOp.maxSelectNumber = 1
    const result = await picker.select(selectOp)
    const uri = result.photoUris[0]
    // 拷贝沙箱+准备数据
    const ctx = getContext(this)
    const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
    const path = ctx.cacheDir + '/' + file.name
    fileIo.copyFileSync(file.fd, path)
    fileIo.closeSync(file.fd)
    const formData = new FormData()
    formData.append('file', `internal://cache/${file.name}`)
    this.dialog.open()
    // 提交头像
    httpClient.request<null>({
      url: 'userInfo/avatar',
      method: 'post',
      headers: { 'Content-Type': 'multipart/form-data' },
      context: ctx
    })
    // logger.debug('userInfo/avatar', JSON.stringify(url))
    const user = await httpClient.request<User>({
      url: 'userInfo'
    })
    this.user.avatar = user.avatar
    auth.setUser(user)
    promptAction.showToast({
      message: '修改头像成功'
    })
    this.dialog.close()
  }

  build() {
    Column() {
      HNavBar({ title: '编辑资料', showRightIcon: false })
      List() {
        ListItem() {
          Row() {
            Text('头像')
            Image(this.user.avatar || $r('app.media.ic_mine_avatar'))
              .alt($r('app.media.ic_mine_avatar'))
              .width(40)
              .aspectRatio(1)
              .borderRadius(20)
              .border({ width: 0.5, color: $r('app.color.common_gray_border') })
              .onClick(() => {
                // 更新头像
                this.updateAvatar()
              })
          }
          .width('100%')
          .height(60)
          .justifyContent(FlexAlign.SpaceBetween)
        }

        ListItem() {
          Row() {
            Text('昵称')
            TextInput({ text: this.user.nickName })
              .fontColor($r('app.color.common_gray_03'))
              .textAlign(TextAlign.End)
              .layoutWeight(1)
              .padding(0)
              .height(60)
              .backgroundColor($r('app.color.white'))
              .borderRadius(0)
              .onChange((value) => this.user.nickName = value)
              .onSubmit(() => {
                // 更新昵称
                this.updateNickname()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 35,
        right: 35,
        top: 15,
        bottom: 15
      })
      .divider({ strokeWidth: 0.5, color: $r('app.color.common_gray_bg') })
    }
  }
}