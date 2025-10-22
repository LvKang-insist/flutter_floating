import 'package:flutter_floating/floating/assist/Point.dart';

/// @name：common_control
/// @package：
/// @author：345 QQ:1831712732
/// @time：2023/04/17 20:29
/// @des： 通用的回调

class CommonControl {
  Function(bool isHide)? _hideControl;
  Function(bool isScroll)? _startScroll;
  Point<double> point = Point(0, 0);
  Function(Point<double> point)? _floatingPoint;
  bool _initIsScroll = false;
  Function ()? _refresh;

  ///设置 Floating 位置监听
  setFloatingPoint(Function(Point<double> point) floatingPoint) {
    _floatingPoint = floatingPoint;
  }

  /// 获取 Floating 位置
  Point<double> getFloatingPoint() {
    _floatingPoint?.call(point);
    return point;
  }

  ///设置初始化时是否可以滑动
  setInitIsScroll(bool initIsScroll) {
    _initIsScroll = initIsScroll;
  }

  ///获取初始化时是否可以滑动状态
  bool getInitIsScroll() {
    return _initIsScroll;
  }

  ///设置是否滑动监听
  setIsStartScrollListener(Function(bool isScroll) fun) {
    _startScroll = fun;
  }

  ///设置是否滑动
  setIsStartScroll(bool isScroll) {
    _startScroll?.call(isScroll);
  }

  ///设置隐藏状态
  setFloatingHide(bool isHide) {
    _hideControl?.call(isHide);
  }

  ///设置隐藏监听
  setHideControlListener(Function(bool isHide) hideControl) {
    _hideControl = hideControl;
  }

  setRefreshListener(Function () refresh) {
    _refresh = refresh;
  }

  refresh() {
    _refresh?.call();
  }
}
