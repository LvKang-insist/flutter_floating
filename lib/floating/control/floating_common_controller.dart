import 'package:flutter_floating/floating/assist/point.dart';
import 'controller_type.dart';

/// @name：common_control
/// @package：
/// @author：345 QQ:1831712732
/// @time：2023/04/17 20:29
/// @des：通用控制器

typedef CommonTypeCallback = dynamic Function(ControllerEnumType type, dynamic any);

class FloatingCommonController {
  CommonTypeCallback? _typeListener;

  /// 绑定内部回调（FloatingView 会调用此方法以接收控制器事件）
  handlerListener(CommonTypeCallback eventListener) {
    _typeListener = eventListener;
  }

  /// 获取 Floating 位置（可能返回 null）
  Point<double>? currentPosition() {
    final res = _typeListener?.call(ControllerEnumType.setPoint, null);
    return res is Point<double> ? res : null;
  }

  /// 设置隐藏（true 隐藏）
  setFloatingHide(bool isHide) {
    _typeListener?.call(ControllerEnumType.setEnableHide, isHide);
  }

  /// 设置是否允许拖动（运行时可切换）
  setDragEnable(bool enable) {
    _typeListener?.call(ControllerEnumType.setDragEnable, enable);
  }

  /// 刷新 Floating
  refresh() {
    _typeListener?.call(ControllerEnumType.refresh, null);
  }

  /// 设置滑动时间，单位毫秒
  scrollTime(int millis) {
    _typeListener?.call(ControllerEnumType.scrollTime, millis);
  }

  /// 从当前滑动到距离顶部[top]的位置
  scrollTop(double top) {
    _typeListener?.call(ControllerEnumType.scrollTop, top);
  }

  /// 从当前滑动到距离左边[left]的位置
  scrollLeft(double left) {
    _typeListener?.call(ControllerEnumType.scrollLeft, left);
  }

  /// 从当前滑动到距离右边[right]的位置
  scrollRight(double right) {
    _typeListener?.call(ControllerEnumType.scrollRight, right);
  }

  /// 从当前滑动到距离底部[bottom]的位置
  scrollBottom(double bottom) {
    _typeListener?.call(ControllerEnumType.scrollBottom, bottom);
  }

  /// 从当前滑动到距离顶部[top]和左边[left]的位置
  scrollTopLeft(double top, double left) {
    _typeListener?.call(ControllerEnumType.scrollTopLeft, Point<double>(left, top));
  }

  /// 从当前滑动到距离顶部[top]和右边[right]的位置
  scrollTopRight(double top, double right) {
    _typeListener?.call(ControllerEnumType.scrollTopRight, Point<double>(right, top));
  }

  /// 从当前滑动到距离底部[bottom]和左边[left]的位置
  scrollBottomLeft(double bottom, double left) {
    _typeListener?.call(ControllerEnumType.scrollBottomLeft, Point<double>(left, bottom));
  }

  /// 从当前滑动到距离底部[bottom]和右边[right]的位置
  scrollBottomRight(double bottom, double right) {
    _typeListener?.call(ControllerEnumType.scrollBottomRight, Point<double>(right, bottom));
  }
}
