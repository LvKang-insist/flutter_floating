/// @name：change_position_listener
/// @package：
/// @author：345 QQ:1831712732
/// @time：2023/03/28 17:47
/// @des：
class ScrollPositionControl {
  ///滑动时间
  int timeMillis = 300;

  ///从当前滑动到距离顶部[top]的位置
  Function(double top)? _scrollTop;

  ///从当前滑动到距离左边[left]的位置
  Function(double left)? _scrollLeft;

  ///从当前滑动到距离右边[right]的位置
  Function(double right)? _scrollRight;

  ///从当前滑动到距离底部[bottom]的位置
  Function(double bottom)? _scrollBottom;

  ///从当前滑动到距离顶部[top]和左边[left]的位置
  Function(double top, double left)? _scrollTopLeft;

  ///从当前滑动到距离顶部[top]和右边[right]的位置
  Function(double bottom, double left)? _scrollBottomLeft;

  ///从当前滑动到距离底部[bottom]和右边[right]的位置
  Function(double top, double right)? _scrollTopRight;

  ///从当前滑动到距离底部[bottom]和右边[right]的位置
  Function(double bottom, double right)? _scrollBottomRight;

  setScrollTime(int timeMillis) {
    this.timeMillis = timeMillis;
  }

  getScrollTime() {
    return timeMillis;
  }

  setScrollTop(Function(double top) scrollTop) {
    _scrollTop = scrollTop;
  }

  setScrollLeft(Function(double left) scrollLeft) {
    _scrollLeft = scrollLeft;
  }

  setScrollRight(Function(double right) scrollRight) {
    _scrollRight = scrollRight;
  }

  setScrollBottom(Function(double bottom) scrollBottom) {
    _scrollBottom = scrollBottom;
  }

  setScrollTopLeft(Function(double top, double left) scrollTopLeft) {
    _scrollTopLeft = scrollTopLeft;
  }

  setScrollBottomLeft(Function(double bottom, double left) scrollBottomLeft) {
    _scrollBottomLeft = scrollBottomLeft;
  }

  setScrollTopRight(Function(double top, double right) scrollTopRight) {
    _scrollTopRight = scrollTopRight;
  }

  setScrollBottomRight(
      Function(double bottom, double right) scrollBottomRight) {
    _scrollBottomRight = scrollBottomRight;
  }

  scrollTop(double top) {
    _scrollTop?.call(top);
  }

  scrollLeft(double left) {
    _scrollLeft?.call(left);
  }

  scrollRight(double right) {
    _scrollRight?.call(right);
  }

  scrollBottom(double bottom) {
    _scrollBottom?.call(bottom);
  }

  scrollTopLeft(double top, double left) {
    _scrollTopLeft?.call(top, left);
  }

  scrollBottomLeft(double bottom, double left) {
    _scrollBottomLeft?.call(bottom, left);
  }

  scrollTopRight(double top, double right) {
    _scrollTopRight?.call(top, right);
  }

  scrollBottomRight(double bottom, double right) {
    _scrollBottomRight?.call(bottom, right);
  }
}
