import 'package:flutter_floating/floating/assist/point.dart';

import '../listener/event_listener.dart';

class FloatingListenerController {
  final List<FloatingEventListener> _listener = [];


  addFloatingListener(FloatingEventListener listener) {
    _listener.contains(listener) ? null : _listener.add(listener);
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

  void notifyTouchDown(Point<double> point) {
    for (var listener in _listener) {
      listener.downListener?.call(point);
    }
  }

  void notifyTouchUp(Point<double> point) {
    for (var listener in _listener) {
      listener.upListener?.call(point);
    }
  }

  void notifyTouchMove(Point<double> point) {
    for (var listener in _listener) {
      listener.moveListener?.call(point);
    }
  }

  void notifyTouchMoveEnd(Point<double> point) {
    for (var listener in _listener) {
      listener.moveEndListener?.call(point);
    }
  }
}
