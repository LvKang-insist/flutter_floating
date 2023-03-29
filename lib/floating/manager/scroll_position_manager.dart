import '../control/scroll_position_control.dart';

/// @name：scroll_position_manager
/// @package：
/// @author：345 QQ:1831712732
/// @time：2023/03/29 11:08
/// @des： 手动控制悬浮窗滑动管理 ,通过[Floating.scrollManager]获取

class ScrollPositionManager {
  final ScrollPositionControl _control;

  ScrollPositionManager(this._control);

  setScrollTime(int timeMillis) {
    _control.setScrollTime(timeMillis);
  }

  ///从当前滑动到距离顶部[top]的位置
  scrollTop(double top) {
    _control.scrollTop(top);
  }

  ///从当前滑动到距离左边[left]的位置
  scrollLeft(double left) {
    _control.scrollLeft(left);
  }

  ///从当前滑动到距离右边[right]的位置
  scrollRight(double right) {
    _control.scrollRight(right);
  }

  ///从当前滑动到距离底部[bottom]的位置
  scrollBottom(double bottom) {
    _control.scrollBottom(bottom);
  }

  ///从当前滑动到距离顶部[top]和左边[left]的位置
  scrollTopLeft(double top, double left) {
    _control.scrollTopLeft(top, left);
  }

  ///从当前滑动到距离顶部[top]和右边[right]的位置
  scrollTopRight(double top, double right) {
    _control.scrollTopRight(top, right);
  }

  ///从当前滑动到距离底部[bottom]和右边[right]的位置
  scrollBottomLeft(double bottom, double left) {
    _control.scrollBottomLeft(bottom, left);
  }

  ///从当前滑动到距离底部[bottom]和右边[right]的位置
  scrollBottomRight(double bottom, double right) {
    _control.scrollBottomRight(bottom, right);
  }
}
