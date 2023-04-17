import 'package:flutter/cupertino.dart';
import 'package:flutter_floating/floating/assist/slide_stop_type.dart';
import 'package:flutter_floating/floating/control/common_control.dart';
import 'package:flutter_floating/floating/listener/event_listener.dart';
import 'package:flutter_floating/floating/manager/scroll_position_manager.dart';
import 'package:flutter_floating/floating/utils/floating_log.dart';
import 'package:flutter_floating/floating/view/floating_view.dart';

import 'assist/floating_data.dart';
import 'assist/floating_slide_type.dart';
import 'control/scroll_position_control.dart';

/// @name：floating
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/10 14:23
/// @des：

class Floating {
  late OverlayEntry _overlayEntry;

  late FloatingView _floatingView;

  late FloatingData _floatingData;

  late ScrollPositionControl _scrollPositionControl;
  late ScrollPositionManager _scrollPositionManager;

  late CommonControl _commonControl;

  final List<FloatingEventListener> _listener = [];

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
  ///[top],[left],[left],[bottom] 对应 [slideType]，
  ///例如设置[slideType]为[FloatingSlideType.onRightAndBottom]，则需要传入[bottom]和[right]
  ///
  ///[isPosCache]启用之后当调用之后 [Floating.close] 重新调用 [Floating.open] 后会保持之前的位置
  ///[isSnapToEdge]是否自动吸附边缘，默认为 true ，请注意，移动默认是有透明动画的，如需要关闭透明度动画，
  ///请修改 [moveOpacity]为 1
  ///[isStartScroll] 是否启动悬浮窗滑动，默认为 true，false 表示无法滑动悬浮窗
  ///[slideTopHeight] 滑动边界控制，可滑动到顶部的距离
  ///[slideBottomHeight] 滑动边界控制，可滑动到底部的距离
  ///[slideStopType] 移动后回弹停靠的位置
  Floating(
    Widget child, {
    FloatingSlideType slideType = FloatingSlideType.onRightAndBottom,
    double? top,
    double? left,
    double? right,
    double? bottom,
    double moveOpacity = 0.3,
    bool isPosCache = true,
    bool isShowLog = true,
    bool isSnapToEdge = true,
    bool isStartScroll = true,
    this.slideTopHeight = 0,
    this.slideBottomHeight = 0,
    SlideStopType slideStopType = SlideStopType.slideStopAutoType,
  }) {
    _floatingData = FloatingData(slideType,
        left: left, right: right, top: top, bottom: bottom);
    _log = FloatingLog(isShowLog);
    _commonControl = CommonControl();
    _commonControl.setInitIsScroll(isStartScroll);
    _scrollPositionControl = ScrollPositionControl();
    _scrollPositionManager = ScrollPositionManager(_scrollPositionControl);
    _floatingView = FloatingView(
      child,
      _floatingData,
      isPosCache,
      isSnapToEdge,
      _listener,
      _scrollPositionControl,
      _commonControl,
      _log,
      moveOpacity: moveOpacity,
      slideTopHeight: slideTopHeight,
      slideBottomHeight: slideBottomHeight,
      slideStopType: slideStopType,
    );
  }

  ///打开悬浮窗
  ///此方法配合 [close]方法进行使用，调用[close]之后在调用此方法会丢失 Floating 状态
  ///否则请使用 [hideFloating] 进行隐藏，使用 [showFloating]进行显示，而不是使用 [close]
  open(BuildContext context) {
    if (_isShowing) return;
    _overlayEntry = OverlayEntry(builder: (context) {
      return _floatingView;
    });
    Overlay.of(context)?.insert(_overlayEntry);
    _isShowing = true;
    _notifyOpen();
  }

  ///关闭悬浮窗
  close() {
    if (!_isShowing) return;
    _overlayEntry.remove();
    _isShowing = false;
    _notifyClose();
  }

  ///隐藏悬浮窗，保留其状态
  ///只有在悬浮窗显示的状态下才可以使用，否则调用无效
  hideFloating() {
    if (!_isShowing) return;
    _commonControl.setFloatingHide(true);
    _isShowing = false;
    _notifyHideFloating();
  }

  ///显示悬浮窗，恢复其状态
  ///只有在悬浮窗是隐藏的状态下才可以使用，否则调用无效
  showFloating() {
    if (_isShowing) return;
    _commonControl.setFloatingHide(false);
    _isShowing = true;
    _notifyShowFloating();
  }

  ///添加监听
  addFloatingListener(FloatingEventListener listener) {
    _listener.contains(listener) ? null : _listener.add(listener);
  }

  ///设置是否启动悬浮窗滑动
  ///[isScroll] true 表示启动，否则关闭
  setIsStartScroll(bool isScroll) {
    _commonControl.setIsStartScroll(isScroll);
  }

  ///设置 [FloatingLog] 标识
  setLogKey(String key) {
    _log.logKey = key;
  }

  /// 获取滑动管理
  ScrollPositionManager scrollManager() {
    return _scrollPositionManager;
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
