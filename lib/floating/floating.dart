import 'package:flutter/cupertino.dart';
import 'package:flutter_floating/floating/assist/Point.dart';
import 'package:flutter_floating/floating/base/floating_base.dart';
import 'package:flutter_floating/floating/control/common_control.dart';
import 'package:flutter_floating/floating/listener/event_listener.dart';
import 'package:flutter_floating/floating/utils/floating_log.dart';
import 'package:flutter_floating/floating/view/floating_view.dart';
import 'assist/floating_common_params.dart';
import 'assist/floating_data.dart';
import 'assist/floating_slide_type.dart';

/// @name：floating
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/10 14:23
/// @des：

class Floating implements FloatingBase {
  late OverlayEntry _overlayEntry;

  late FloatingView _floatingView;

  late FloatingData _floatingData;

  late CommonControl _commonControl;

  late FloatingCommonParams _params;

  final List<FloatingEventListener> _listener = [];

  late FloatingLog _log;
  String logKey = "";

  ///是否真正显示
  bool get isShowing => _isShowing;
  bool _isShowing = false;

  ///[child]需要悬浮的 widget
  ///
  ///[top],[left],[left],[bottom],[point] 对应 [slideType]，设置与起始点的距离
  ///例如设置[slideType]为[FloatingSlideType.onRightAndBottom]，则需要传入[bottom]和[right]
  ///设置 [slideType]为 [FloatingSlideType.onPoint] 则需要传入 [point]
  ///

  ///
  Floating(
    Widget child, {
    FloatingSlideType slideType = FloatingSlideType.onRightAndBottom,
    double? top,
    double? left,
    double? right,
    double? bottom,
    Point<double>? point,
    FloatingCommonParams? params,
  }) {
    _floatingData =
        FloatingData(slideType, left: left, right: right, top: top, bottom: bottom, point: point);
    _params = params ?? FloatingCommonParams();
    _log = FloatingLog(_params.isShowLog);
    _commonControl = CommonControl();
    _floatingView = FloatingView(
      child,
      _floatingData,
      _params,
      _listener,
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

  ///是否允许拖动悬浮窗
  ///[isScroll] true 表示启动，否则关闭
  isEnableDrag(bool isScroll) {
    _params.isEnableDrag = isScroll;
  }

  ///设置 [FloatingLog] 标识
  setLogKey(String key) {
    _log.logKey = key;
  }

  refresh() {
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


  /// 获取悬浮窗位置
  @override
  Point<num> getFloatingPoint() => _commonControl.getPoint();
}
