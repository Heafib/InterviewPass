export const formatTime = (second: number) => {
  //天 > 1天
  //小时 > 1小时
  // 分钟 > 1分
  const day = 60 * 60 * 24
  const hour = 60 * 60
  const minute = 60

  if (second > day) {
    return (second / day).toFixed(1) + '天'
  } else if (second > hour) {
    return (second / hour).toFixed(1) + '小时'
  } else {
    return (second / minute).toFixed(0) + '分钟'
  }

}