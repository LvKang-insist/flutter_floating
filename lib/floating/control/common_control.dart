import 'package:flutter_floating/floating/assist/Point.dart';
import 'common_type.dart';

/// @name：common_control
/// @package：
/// @author：345 QQ:1831712732
/// @time：2023/04/17 20:29
/// @des：通用控制器

typedef CommonTypeCallback = dynamic Function(CommonType type, dynamic any);

class CommonControl {
  CommonTypeCallback? _eventListener;

  handlerListener(CommonTypeCallback eventListener) {
    _eventListener = eventListener;
  }

  ///设置 Floating 位置监听
  Point<double> getPoint() {
    return _eventListener?.call(CommonType.setPoint, null) as Point<double>;
  }

  ///设置隐藏状态
  setFloatingHide(bool isHide) {
    _eventListener?.call(CommonType.setEnableHide, isHide);
  }

  refresh() {
    _eventListener?.call(CommonType.refresh, null);
  }

  ///设置滑动时间，单位毫秒
  scrollTime(int millis) {
    _eventListener?.call(CommonType.scrollTime, millis);
  }

  ///从当前滑动到距离顶部[top]的位置
  scrollTop(double top) {
    _eventListener?.call(CommonType.scrollTop, top);
  }

  ///从当前滑动到距离左边[left]的位置
  scrollLeft(double left) {
    _eventListener?.call(CommonType.scrollLeft, left);
  }

  ///从当前滑动到距离右边[right]的位置
  scrollRight(double right) {
    _eventListener?.call(CommonType.scrollRight, right);
  }

  ///从当前滑动到距离底部[bottom]的位置
  scrollBottom(double bottom) {
    _eventListener?.call(CommonType.scrollBottom, bottom);
  }

  ///从当前滑动到距离顶部[top]和左边[left]的位置
  scrollTopLeft(double top, double left) {
    _eventListener?.call(CommonType.scrollTopLeft, Point<double>(left, top));
  }

  ///从当前滑动到距离顶部[top]和右边[right]的位置
  scrollTopRight(double top, double right) {
    _eventListener?.call(CommonType.scrollTopRight, Point<double>(right, top));
  }

  ///从当前滑动到距离底部[bottom]和左边[left]的位置
  scrollBottomLeft(double bottom, double left) {
    _eventListener?.call(CommonType.scrollBottomLeft, Point<double>(left, bottom));
  }

  ///从当前滑动到距离底部[bottom]和右边[right]的位置
  scrollBottomRight(double bottom, double right) {
    _eventListener?.call(CommonType.scrollBottomRight, Point<double>(right, bottom));
  }
}
