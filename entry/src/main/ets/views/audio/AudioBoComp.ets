@Component
export struct AudioBoComp {
  @Prop
  @Watch('onMaxAmplitudeChange')
  maxAmplitude: number = 0
  // 柱子高度百分比
  @State
  per: number = 0

  onMaxAmplitudeChange() {

    animateTo({ duration: 100 }, () => {
      this.maxAmplitude = this.maxAmplitude * 500 + Math.random() * 5000
      if (this.maxAmplitude < 500) {
        this.per = 0
      } else if (this.maxAmplitude > 32000) {
        this.per = 1
      } else {
        this.per = this.maxAmplitude / 32000
      }
    })

  }

  build() {
    Row({ space: 5 }) {
      ForEach(new Array(30).fill(0), () => {
        Column()
          .layoutWeight(1)
          .backgroundColor($r('app.color.common_blue'))
          .height(this.per * 100 * Math.random())

      })
    }
    .padding({ left: 32, right: 32 })
    .width('100%')
    .height(100)
  }
}