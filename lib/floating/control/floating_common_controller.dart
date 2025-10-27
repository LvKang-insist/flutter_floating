import 'package:flutter_floating/floating/assist/point.dart';
import '../listener/event_listener.dart';
import 'controller_type.dart';
import 'floating_listener_controller.dart';

/// @name：common_control
/// @package：
/// @author：345 QQ:1831712732
/// @time：2023/04/17 20:29
/// @des：通用控制器

typedef CommonTypeCallback = dynamic Function(ControllerEnumType type, dynamic any);

class FloatingCommonController {
  CommonTypeCallback? _typeListener;

  handlerListener(CommonTypeCallback eventListener) {
    _typeListener = eventListener;
  }

  ///获取 Floating 位置
  Point<double> currentPosition() {
    return _typeListener?.call(ControllerEnumType.setPoint, null);
  }

  ///设置隐藏
  setFloatingHide(bool isHide) {
    _typeListener?.call(ControllerEnumType.setEnableHide, isHide);
  }

  ///刷新 Floating
  refresh() {
    _typeListener?.call(ControllerEnumType.refresh, null);
  }

  ///设置滑动时间，单位毫秒
  scrollTime(int millis) {
    _typeListener?.call(ControllerEnumType.scrollTime, millis);
  }

  ///从当前滑动到距离顶部[top]的位置
  scrollTop(double top) {
    _typeListener?.call(ControllerEnumType.scrollTop, top);
  }

  ///从当前滑动到距离左边[left]的位置
  scrollLeft(double left) {
    _typeListener?.call(ControllerEnumType.scrollLeft, left);
  }

  ///从当前滑动到距离右边[right]的位置
  scrollRight(double right) {
    _typeListener?.call(ControllerEnumType.scrollRight, right);
  }

  ///从当前滑动到距离底部[bottom]的位置
  scrollBottom(double bottom) {
    _typeListener?.call(ControllerEnumType.scrollBottom, bottom);
  }

  ///从当前滑动到距离顶部[top]和左边[left]的位置
  scrollTopLeft(double top, double left) {
    _typeListener?.call(ControllerEnumType.scrollTopLeft, Point<double>(left, top));
  }

  ///从当前滑动到距离顶部[top]和右边[right]的位置
  scrollTopRight(double top, double right) {
    _typeListener?.call(ControllerEnumType.scrollTopRight, Point<double>(right, top));
  }

  ///从当前滑动到距离底部[bottom]和左边[left]的位置
  scrollBottomLeft(double bottom, double left) {
    _typeListener?.call(ControllerEnumType.scrollBottomLeft, Point<double>(left, bottom));
  }

  ///从当前滑动到距离底部[bottom]和右边[right]的位置
  scrollBottomRight(double bottom, double right) {
    _typeListener?.call(ControllerEnumType.scrollBottomRight, Point<double>(right, bottom));
  }
}
