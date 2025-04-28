import { HNavBar } from '../commons/components/HNavBar'
import { Permissions } from '@kit.AbilityKit'
import { permission } from '../commons/utils/Permission'
import { logger } from '../commons/utils/Logger'
import { promptAction, router } from '@kit.ArkUI'
import { fileIo } from '@kit.CoreFileKit'
import { media } from '@kit.MediaKit'

@Entry
@Component
struct AudioPage {
  // 存放文件路径
  filePath: string = ''
  fd: number = 0
  avRecorder: media.AVRecorder | null = null

  async startRecord() {
    // 准备文件
    const ctx = getContext(this)
    this.filePath = ctx.filesDir + '/' + Date.now() + '.m4a'
    const file = fileIo.openSync(this.filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    this.fd = file.fd
    // 准备配置
    const config: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      profile: {
        audioBitrate: 100000, // 音频比特率
        audioChannels: 1, // 音频声道数
        audioCodec: media.CodecMimeType.AUDIO_AAC, // 音频编码格式，当前只支持aac
        audioSampleRate: 48000, // 音频采样率
        fileFormat: media.ContainerFormatType.CFT_MPEG_4A, // 封装格式，当前只支持m4a
      },
      url: `fd://${file.fd}`
    }
    // 开启录音
    const avRecorder = await media.createAVRecorder()
    await avRecorder.prepare(config)
    await avRecorder.start()
    this.avRecorder = avRecorder
  }

  async stopRecord() {
    if (this.avRecorder) {
      await this.avRecorder.stop()
      await this.avRecorder.release()
      fileIo.closeSync(this.fd)
    }
  }

  aboutToAppear(): void {
    this.requestPermission()
  }

  async requestPermission() {
    // 未授权不允许访问
    try {
      const permissionList: Permissions[] = ['ohos.permission.MICROPHONE']
      const flag = await permission.fromUser(permissionList)
      logger.debug('fromUser', String(flag))
      if (flag) {
        return
      }
      // 用户引导
      // 二次授权
      const result = await promptAction.showDialog({
        title: '温馨提示',
        message: '未授权使用麦克风将无法使用该面试录音功能，是否前往设置进行授权？',
        buttons: [
          {
            text: '离开', color: $r('app.color.common_gray_01')
          },
          {
            text: '去授权', color: $r('app.color.black')
          }
        ]
      })
      if (result.index === 1) {
        // 二次授权
        const flag2 = await permission.onSetting(permissionList)
        if (flag2) {
          return
        }
      }
      router.back()
    } catch (e) {
      router.back()

    }
  }

  build() {
    Column({ space: 20 }) {
      HNavBar({ title: '面试录音', showRightIcon: false })
      Button('开启录音')
        .onClick(() => {
          this.startRecord()
        })
      Button('结束录音')
        .onClick(() => {
          this.stopRecord()
        })
    }
    .height('100%')
    .width('100%')
  }
}