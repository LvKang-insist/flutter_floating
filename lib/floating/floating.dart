import 'package:floating/floating/listener/floating_listener.dart';
import 'package:floating/floating/utils/floating_log.dart';
import 'package:floating/floating/view/floating_view.dart';
import 'package:floating/floating/assist/hide_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

import 'assist/floating_data.dart';
import 'assist/floating_slide_type.dart';

/// @name：floating
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/10 14:23
/// @des：

class Floating {
  final GlobalKey<NavigatorState>? _navigatorKey;
  late OverlayEntry _overlayEntry;

  late FloatingView _floatingView;

  late FloatingData _floatingData;

  late HideController _hideController;

  final List<FloatingListener> _listener = [];

  final double slideTopHeight;
  final double slideBottomHeight;
  late FloatingLog _log;
  String logKey = "";

  ///是否真正显示
  bool get isShowing => _isShowing;
  bool _isShowing = false;

  ///[child]需要悬浮的 widget
  ///[slideType]，可参考[FloatingSlideType]
  ///
  /// [width],[height] 悬浮窗的宽高，若不传，默认为 100x100
  ///
  ///[top],[left],[left],[bottom] 对应 [slideType]，
  ///例如设置[slideType]为[FloatingSlideType.onRightAndBottom]，则需要传入[bottom]和[right]
  ///
  ///[isPosCache]启用之后当调用之后 [Floating.close] 重新调用 [Floating.open]
  ///后会保持之前的位置
  Floating(
    this._navigatorKey,
    Widget child, {
    double? width,
    double? height,
    FloatingSlideType slideType = FloatingSlideType.onRightAndBottom,
    double? top,
    double? left,
    double? right,
    double? bottom,
    double moveOpacity = 0.3,
    bool isPosCache = false,
    bool isShowLog = true,
    this.slideTopHeight = 0,
    this.slideBottomHeight = 0,
  }) {
    _floatingData = FloatingData(slideType,
        left: left, right: right, top: top, bottom: bottom);
    _log = FloatingLog(isShowLog);
    _hideController = HideController();
    _floatingView = FloatingView(
        child, _floatingData, isPosCache, _hideController, _listener, _log,
        moveOpacity: moveOpacity,
        width: width,
        height: height,
        slideTopHeight: slideTopHeight,
        slideBottomHeight: slideBottomHeight);
  }

  ///打开悬浮窗
  ///此方法配合 [close]方法进行使用，调用[close]之后在调用此方法会丢失 Floating 状态
  ///否则请使用 [hideFloating] 进行隐藏，使用 [showFloating]进行显示，而不是使用 [close]
  open() {
    if (_isShowing) return;
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      _overlayEntry = OverlayEntry(builder: (context) {
        return _floatingView;
      });
      _navigatorKey!.currentState?.overlay?.insert(_overlayEntry);
      _isShowing = true;
      _notifyOpen();
    });
  }

  ///关闭悬浮窗
  close() {
    if (!_isShowing) return;
    _overlayEntry.remove();
    _isShowing = false;
    _notifyClose();
  }

  ///隐藏悬浮窗，保留其状态
  ///只有在悬浮窗是隐藏的状态下才可以使用，否则调用无效
  hideFloating() {
    if (!_isShowing) return;
    _hideController.hideControl?.call(true);
    _isShowing = false;
    _notifyHideFloating();
  }

  ///显示悬浮窗，恢复其状态
  ///只有在悬浮窗是隐藏的状态下才可以使用，否则调用无效
  showFloating() {
    if (_isShowing) return;
    _hideController.hideControl?.call(false);
    _isShowing = true;
    _notifyShowFloating();
  }

  ///添加监听
  addFloatingListener(FloatingListener listener) {
    _listener.contains(listener) ? null : _listener.add(listener);
  }

  ///设置 [FloatingLog] 标识
  setLogKey(String key) {
    _log.logKey = key;
  }

  _notifyClose() {
    _log.log("关闭");
    for (var listener in _listener) {
      listener.closeListener?.call();
    }
  }

  _notifyOpen() {
    _log.log("打开");
    for (var listener in _listener) {
      listener.openListener?.call();
    }
  }

  _notifyHideFloating() {
    _log.log("隐藏");
    for (var listener in _listener) {
      listener.hideFloatingListener?.call();
    }
  }

  _notifyShowFloating() {
    _log.log("显示");
    for (var listener in _listener) {
      listener.showFloatingListener?.call();
    }
  }
}
