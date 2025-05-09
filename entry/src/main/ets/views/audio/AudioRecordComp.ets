import { media } from '@kit.MediaKit'
import { fileIo } from '@kit.CoreFileKit'
import { InterviewAudioItem } from '../../commons/utils/AudioDB'
import { auth } from '../../commons/utils/Auth'
import dayjs from 'dayjs'

@Component
export struct AudioRecordComp {
  @StorageProp('bottomHeight') bottomHeight: number = 0
  avRecorder?: media.AVRecorder
  fd?: number
  filePath?: string
  timer?: number
  @State maxAmplitude: number = 0
  @State
  isRecording: boolean = false
  startTime: number = Date.now()
  // 录音完毕
  onRecordEnd: (item: InterviewAudioItem) => void = () => {

  }

  async startRecord() {
    // 1. 准备一个文件接收录音
    const ctx = getContext(this)
    const filePath = ctx.filesDir + '/' + Date.now() + '.m4a'
    this.filePath = filePath
    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
    this.fd = file.fd
    // 2. 准备录音配置对象
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
    // 3. 开始录制
    const avRecorder = await media.createAVRecorder()
    await avRecorder.prepare(config)
    await avRecorder.start()
    this.avRecorder = avRecorder
    // 4. 每100ms获取一下声音振幅
    this.timer = setInterval(async () => {
      this.maxAmplitude = await avRecorder.getAudioCapturerMaxAmplitude()
    }, 100)
    this.startTime = Date.now()
  }

  async stopRecord() {
    if (this.avRecorder) {
      clearInterval(this.timer)
      await this.avRecorder.stop()
      await this.avRecorder.release()
      fileIo.closeSync(this.fd)
      this.maxAmplitude = 0
    }
  }

  build() {
    Column() {
      AudioBoComp({ maxAmplitude: this.maxAmplitude })
      Row() {
        Image($r('sys.media.ohos_ic_public_voice'))
          .width(24)
          .aspectRatio(1)
          .fillColor($r('app.color.white'))
          .onClick(async () => {
            if (this.isRecording) {
              // 结束
              this.stopRecord()
              this.isRecording = false
              const file = fileIo.openSync(this.filePath, fileIo.OpenMode.READ_ONLY)
              const size = fileIo.statSync(file.fd).size
              // 组织录音对象传给父组件
              this.onRecordEnd({
                id: null,
                name: dayjs().format('YYYY年MM月DD日_HH时mm分ss秒'),
                path: this.filePath!,
                duration: Date.now() - this.startTime,
                size: size,
                user_id: auth.getUser().id,
                create_time: Date.now()
              })
            } else {
              this.startRecord()
              this.isRecording = true
            }
          })
      }
      .justifyContent(FlexAlign.Center)
      .height(50)
      .width(50)
      .borderRadius(25)
      .margin({ top: 20 })
      .backgroundColor(this.isRecording ? $r('app.color.common_blue') : $r('app.color.black'))
    }
    .width('100%')
    .height(240)
    .backgroundColor($r('app.color.common_gray_bg'))
    .padding({
      bottom: this.bottomHeight,
      left: 80,
      right: 80,
      top: 20
    })
  }
}

@Component
export struct AudioBoComp {
  @Prop @Watch('onChange') maxAmplitude: number
  @State per: number = 0

  onChange() {
    animateTo({ duration: 100 }, () => {
      if (this.maxAmplitude < 500) {
        this.per = 0
      } else if (this.maxAmplitude > 30000) {
        this.per = 1
      } else {
        this.per = this.maxAmplitude / 30000
      }
    })
  }

  build() {
    Row({ space: 5 }) {
      ForEach(Array.from({ length: 30 }), () => {
        Column()
          .layoutWeight(1)
          .height(this.per * 100 * Math.random())
          .backgroundColor($r('app.color.common_blue'))
      })
    }
    .width('100%')
    .height(100)
    .backgroundColor($r('app.color.common_gray_bg'))
  }
}