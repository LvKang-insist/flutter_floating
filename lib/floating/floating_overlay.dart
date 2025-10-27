import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/utils/floating_log.dart';
import 'package:flutter_floating/floating/view/floating_view.dart';

import 'assist/floating_common_params.dart';
import 'assist/floating_data.dart';
import 'assist/floating_edge_type.dart';
import 'assist/point.dart';
import 'base/floating_base.dart';
import 'control/floating_common_controller.dart';
import 'control/floating_listener_controller.dart';
import 'listener/event_listener.dart';

/// @name：floating
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/10 14:23
/// @des：

class FloatingOverlay implements FloatingBase {
  late OverlayEntry _overlayEntry;

  late FloatingView _floatingView;

  late FloatingData _floatingData;

  late FloatingCommonController _commonControl;

  late FloatingListenerController _listenerController;

  late FloatingParams _params;

  late FloatingLog _log;
  String logKey = "";

  ///是否真正显示
  bool get isShowing => _isShowing;
  bool _isShowing = false;

  ///[child]需要悬浮的 widget
  ///
  ///[top],[left],[left],[bottom],[point] 对应 [slideType]，设置与起始点的距离
  ///例如设置[slideType]为[FloatingEdgeType.onRightAndBottom]，则需要传入[bottom]和[right]
  ///设置 [slideType]为 [FloatingEdgeType.onPoint] 则需要传入 [point]
  ///

  ///
  FloatingOverlay(
    Widget child, {
    FloatingEdgeType slideType = FloatingEdgeType.onRightAndBottom,
    double? top,
    double? left,
    double? right,
    double? bottom,
    FPosition<double>? point,
    FloatingParams? params,
    FloatingCommonController? controller,
  }) {
    _floatingData = FloatingData(slideType,
        left: left, right: right, top: top, bottom: bottom, position: point);
    _params = params ?? const FloatingParams();
    _log = FloatingLog(_params.isShowLog);
    _commonControl = controller ?? FloatingCommonController();
    _listenerController = FloatingListenerController();
    _floatingView = FloatingView(
      child,
      _floatingData,
      _params,
      _listenerController,
      _commonControl,
      _log,
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
    // dispose internally created controller to avoid leaks
    try {
      _commonControl.dispose();
    } catch (_) {}
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
    _listenerController.addFloatingListener(listener);
  }

  /// 设置 [FloatingLog] 标识
  setLogKey(String key) {
    _log.logKey = key;
  }

  _notifyOpen() {
    _log.log("打开");
    _listenerController.notifyOpen();
  }

  _notifyClose() {
    _log.log("关闭");
    _listenerController.notifyClose();
  }

  _notifyShowFloating() {
    _log.log("显示");
    _listenerController.notifyShowFloating();
  }

  _notifyHideFloating() {
    _log.log("隐藏");
    _listenerController.notifyHideFloating();
  }

  ///获取悬浮窗
  @override
  Widget getFloating() => _floatingView;

  /// 获取或设置外部控制器（如果需要直接调用控制器方法）
  FloatingCommonController get controller => _commonControl;
}
