enum ControllerEnumType {
  ///大小变化
  sizeChange,

  ///设置位置
  getPoint,

  ///设置隐藏
  setEnableHide,

  ///设置是否可以拖动
  setDragEnable,

  ///获取吸边距离
  getSnapToEdgeSpace,

  ///设置吸边距离
  setSnapToEdgeSpace,

  ///滑动时间
  scrollTime,

  ///自动吸边
  autoEdge,

  ///从当前位置偏移[offset]的位置滑动
  scrollBy,

  ///配合[FloatingParams.snapToEdgeSpace]使用
  ///若设置了边缘吸附距离，调用此方法，可在(切边)到该距离之间切换吸附位置
  scrollSnapToEdgeSpaceToggle,

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
