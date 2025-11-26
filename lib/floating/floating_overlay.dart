import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/utils/floating_log.dart';
import 'package:flutter_floating/floating/view/floating_view.dart';

import 'assist/floating_common_params.dart';
import 'assist/floating_data.dart';
import 'assist/floating_edge_type.dart';
import 'assist/fposition.dart';
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
  OverlayEntry? _overlayEntry;

  late FloatingView _floatingView;

  late FloatingData _floatingData;

  late FloatingCommonController _commonControl;

  late FloatingListenerController _listenerController;

  late FloatingLog _log;
  String logKey = "";

  ///是否真正显示（OverlayEntry 是否已插入）
  bool get isShowing => _isShowing;
  bool _isShowing = false;

  /// 是否处于隐藏（Offstage/不可见）状态，仅在 Overlay 已插入时生效
  bool _isHidden = false;

  /// 对外可读的隐藏状态
  bool get isHidden => _isHidden;

  ///[child]需要悬浮的 widget
  ///
  ///[top],[left],[left],[bottom],[position] 对应 [slideType]，设置与起始点的距离
  ///例如设置[slideType]为[FloatingEdgeType.onRightAndBottom]，则需要传入[bottom]和[right]
  ///设置 [slideType]为 [FloatingEdgeType.onPoint] 则需要传入 [position]
  /// [logKey]设置 [FloatingLog] 标识
  ///
  FloatingOverlay(
    Widget child, {
    FloatingEdgeType slideType = FloatingEdgeType.onRightAndBottom,
    double? top,
    double? left,
    double? right,
    double? bottom,
    String? logKey,
    FPosition<double>? position,
    FloatingParams? params,
    FloatingCommonController? controller,
  }) {
    _floatingData = FloatingData(slideType,
        left: left, right: right, top: top, bottom: bottom, position: position);
    var param = params ?? const FloatingParams();
    _log = FloatingLog(param.isShowLog, logKey ?? '');
    // 记录 controller 所有权：若外部未传入 controller，则由本实例创建并负责释放
    _commonControl = controller ?? FloatingCommonController();
    _listenerController = FloatingListenerController();
    _floatingView = FloatingView(
      child,
      _floatingData,
      param,
      _listenerController,
      _commonControl,
      _log,
    );
  }

  ///打开悬浮窗
  ///此方法配合 [close]方法进行使用
  open(BuildContext context) {
    if (_isShowing) return;
    final OverlayState? overlay = Overlay.of(context);
    if (overlay == null) {
      _log.log('open: Overlay.of(context) returned null, cannot insert floating overlay.');
      return;
    }
    _overlayEntry = OverlayEntry(builder: (context) {
      return _floatingView;
    });
    overlay.insert(_overlayEntry!);
    _isShowing = true;
    _isHidden = false;
    _notifyOpen();
  }

  ///关闭悬浮窗
  close() {
    if (!_isShowing) return;
    try {
      _overlayEntry?.remove();
      // 避免保留对已移除 OverlayEntry 的引用
      _overlayEntry = null;
    } catch (_) {}
    _isShowing = false;
    _isHidden = false;
    _notifyClose();
    // 注意：close() 仅移除 Overlay（保留状态与资源），若需要释放 controller/listeners
    // 请在确定不再使用时调用 dispose() 方法。这样可以避免 close 导致外部 controller 被误释放。
  }

  /// 释放内部资源：清空监听器并释放内部创建的 controller（如果有）
  ///
  /// 注意：此方法会释放由本实例创建的 controller（如果构造时没有传入外部 controller），
  /// 调用者在调用后不应再使用本 FloatingOverlay 或其 controller。
  void dispose() {
    try {
      clearFloatingListeners();
    } catch (_) {}
    try {
      _commonControl.dispose();
    } catch (_) {}
  }

  ///隐藏悬浮窗，保留其状态（不移除 OverlayEntry）
  ///只有在悬浮窗已经插入 Overlay 的状态下才可以使用，否则调用无效
  hide() {
    if (!_isShowing) return;
    _commonControl.setFloatingHide(true);
    _isHidden = true;
    _notifyHideFloating();
  }

  ///显示悬浮窗，恢复其状态（仅当 Overlay 已插入时有效）
  ///只有在悬浮窗是隐藏的状态下才可以使用，否则调用无效
  show() {
    if (!_isShowing) return;
    _commonControl.setFloatingHide(false);
    _isHidden = false;
    _notifyShowFloating();
  }

  ///添加监听
  addFloatingListener(FloatingEventListener listener) {
    _listenerController.addFloatingListener(listener);
  }

  /// 移除已添加的监听器
  bool removeFloatingListener(FloatingEventListener listener) {
    return _listenerController.removeFloatingListener(listener);
  }

  /// 清空所有监听器
  void clearFloatingListeners() {
    _listenerController.clearListeners();
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
