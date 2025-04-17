@Component
export struct HTag {
  // 根据不同难度 5 困难 43 一般 12 简单
  @Prop
  difficulty: number = 1
  // 自定义文字 和 颜色
  @Prop
  text: string
  @Prop
  color: ResourceColor

  build() {
    Text(this.text ? this.text : infoMap[this.difficulty].text)
      .fontColor(this.color ? this.color : infoMap[this.difficulty].color)
      .fontSize(10)
      .padding({ left: 6, right: 6 })
      .height(18)
      .constraintSize({ minWidth: 34 })
      .borderRadius(2)
      .backgroundColor($r('app.color.common_gray_bg'))
      .textAlign(TextAlign.Center)

  }
}

interface HTagInfo {
  text: string;
  color: ResourceColor;
}


const infoMap: Record<number, HTagInfo> = {
  1: { text: "简单", color: $r("app.color.common_green") },
  2: { text: "简单", color: $r("app.color.common_green") },
  3: { text: "一般", color: $r("app.color.common_blue") },
  4: { text: "一般", color: $r("app.color.common_blue") },
  5: { text: "困难", color: $r("app.color.common_main_color") }
}