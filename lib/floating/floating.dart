import 'package:flutter/cupertino.dart';
import 'package:flutter_floating/floating/assist/Point.dart';
import 'package:flutter_floating/floating/assist/slide_stop_type.dart';
import 'package:flutter_floating/floating/base/floating_base.dart';
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

class Floating implements FloatingBase {
  late OverlayEntry _overlayEntry;

  late FloatingView _floatingView;

  late FloatingData _floatingData;

  late ScrollPositionControl _scrollPositionControl;
  late ScrollPositionManager _scrollPositionManager;

  late CommonControl _commonControl;

  final List<FloatingEventListener> _listener = [];

  late FloatingLog _log;
  String logKey = "";

  ///是否真正显示
  bool get isShowing => _isShowing;
  bool _isShowing = false;

  ///[child]需要悬浮的 widget
  ///[slideType]，悬浮窗坐标的起始点位置，可参考[FloatingSlideType]
  ///
  ///[top],[left],[left],[bottom],[point] 对应 [slideType]，设置与起始点的距离
  ///例如设置[slideType]为[FloatingSlideType.onRightAndBottom]，则需要传入[bottom]和[right]
  ///设置 [slideType]为 [FloatingSlideType.onPoint] 则需要传入 [point]
  ///
  ///[isPosCache]是否在调用 [Floating.open] 时，保持上一次 [Floating.close] 前的位置
  ///[isSnapToEdge]是否自动吸附左右边缘，默认为 true
  ///请注意，移动默认是有透明动画的，如需要关闭透明度动画，请修改 [moveOpacity]为 1
  ///[isStartScroll] 是否允许拖动悬浮窗，默认为 true
  ///[slideTopHeight] 拖动范围限制，与顶部的最小距离（可设为负数）
  ///[slideBottomHeight] 拖动范围限制，与底部的最小距离（可设为负数）
  ///[snapToEdgeSpace] 吸附后回弹至与边缘的距离，不开启吸附则用于范围限制（可设为负数）
  ///[edgeSpeed] 吸附边缘的速度，默认 250，越大越快
  ///[slideStopType] 拖动后吸附在哪一侧
  Floating(
    Widget child, {
    FloatingSlideType slideType = FloatingSlideType.onRightAndBottom,
    double? top,
    double? left,
    double? right,
    double? bottom,
    Point<double>? point,
    double moveOpacity = 0.3,
    bool isPosCache = true,
    bool isShowLog = true,
    bool isSnapToEdge = true,
    bool isStartScroll = true,
    double slideTopHeight = 0,
    double slideBottomHeight = 0,
    double snapToEdgeSpace = 0,
    int edgeSpeed = 250,
    SlideStopType slideStopType = SlideStopType.slideStopAutoType,
  }) {
    _floatingData = FloatingData(slideType,
        left: left,
        right: right,
        top: top,
        bottom: bottom,
        point: point,
        snapToEdgeSpace: snapToEdgeSpace);
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
      edgeSpeed: edgeSpeed,
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
    Overlay.of(context).insert(_overlayEntry);
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

  refresh(){
    _commonControl.refresh();
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

  ///获取悬浮窗
  @override
  Widget getFloating() => _floatingView;

  /// 获取滑动管理
  @override
  ScrollPositionManager getScrollManager() =>_scrollPositionManager;

  /// 获取悬浮窗位置
  @override
  Point<num> getFloatingPoint() => _commonControl.getFloatingPoint();

}
