import 'package:flutter_floating/floating/assist/fposition.dart';

import '../listener/event_listener.dart';

class FloatingListenerController {
  final List<FloatingEventListener> _listener = [];

  /// 添加监听器（如果已存在则忽略）
  void addFloatingListener(FloatingEventListener listener) {
    if (!_listener.contains(listener)) _listener.add(listener);
  }

  /// 移除监听器，返回是否移除成功
  bool removeFloatingListener(FloatingEventListener listener) {
    return _listener.remove(listener);
  }

  /// 清空所有监听器
  void clearListeners() {
    _listener.clear();
  }


  void notifyOpen() {
    for (var listener in _listener) {
      listener.openListener?.call();
    }
  }

  void notifyClose() {
    for (var listener in _listener) {
      listener.closeListener?.call();
    }
  }

  void notifyHideFloating() {
    for (var listener in _listener) {
      listener.hideFloatingListener?.call();
    }
  }

  void notifyShowFloating() {
    for (var listener in _listener) {
      listener.showFloatingListener?.call();
    }
  }

  void notifyTouchDown(FPosition<double> point) {
    for (var listener in _listener) {
      listener.downListener?.call(point);
    }
  }

  void notifyTouchUp(FPosition<double> point) {
    for (var listener in _listener) {
      listener.upListener?.call(point);
    }
  }

  void notifyTouchMove(FPosition<double> point) {
    for (var listener in _listener) {
      listener.moveListener?.call(point);
    }
  }

  void notifyTouchMoveEnd(FPosition<double> point) {
    for (var listener in _listener) {
      listener.moveEndListener?.call(point);
    }
  }
}
