enum ControllerEnumType {
  ///大小变化
  sizeChange,

  ///设置位置
  getPoint,

  ///设置隐藏
  setEnableHide,

  ///设置是否可以拖动
  setDragEnable,

  ///滑动时间
  scrollTime,

  ///从当前位置偏移[offset]的位置滑动
  scrollBy,

  ///从当前滑动到距离顶部[top]的位置
  scrollTop,

  ///从当前滑动到距离左边[left]的位置
  scrollLeft,

  ///从当前滑动到距离右边[right]的位置
  scrollRight,

  ///从当前滑动到距离底部[bottom]的位置
  scrollBottom,

  ///从当前滑动到距离顶部[top]和左边[left]的位置
  scrollTopLeft,

  ///从当前滑动到距离底部[bottom]和左边[left]的位置
  scrollBottomLeft,

  ///从当前滑动到距离顶部[top]和右边[right]的位置
  scrollTopRight,

  ///从当前滑动到距离底部[bottom]和右边[right]的位置
  scrollBottomRight,
}
