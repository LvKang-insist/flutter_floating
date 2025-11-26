import 'dart:async';
import 'package:flutter_floating/floating/assist/fposition.dart';
import '../assist/snap_stop_type.dart';
import 'controller_type.dart';

/// FloatingCommonController：对外提供的控制器 API
///
/// 实现细节：控制器通过内部的 [commands] 流向 Floating 视图发送结构化命令。
/// 视图订阅该流并在收到命令时执行。对于需要等待完成的操作（如动画），
/// 控制器会创建一个 Completer 并将其放入命令中，视图在完成操作后调用
/// completer.complete(...)（可带返回值）。控制器在没有监听器的情况下
/// 会立刻完成对应的 Future，避免调用者无限等待。
class FloatingCommonController {
  // 私有命令流
  final StreamController<_ControllerCommand> _commandController = StreamController.broadcast();

  /// 控制器命令流（私有），供库内部的 FloatingView 订阅
  Stream<_ControllerCommand> get commands => _commandController.stream;

  /// 关闭内部流，控制器不再使用时调用
  void dispose() {
    try {
      _commandController.close();
    } catch (_) {}
  }

  bool get _hasListeners => !_commandController.isClosed && _commandController.hasListener;

  // 内部帮助方法：发送一个带 void completer 的命令并返回 Future<void>
  Future<void> _emitCommand(ControllerEnumType type, {dynamic value}) {
    final c = Completer<void>();
    final cmd = _ControllerCommand(type, value: value, completer: c);
    try {
      _commandController.add(cmd);
    } catch (_) {
      // 如果添加失败（没有 listener），立即完成
      c.complete();
    }
    if (!_hasListeners) c.complete();
    return c.future;
  }

  /// 获取 Floating 位置（异步实现）：发送 setPoint 命令并等待视图返回 Point
  Future<FPosition<double>?> currentPosition() async {
    final c = Completer<dynamic>();
    final cmd = _ControllerCommand(ControllerEnumType.getPoint, completer: c);
    try {
      _commandController.add(cmd);
    } catch (_) {
      c.complete(null);
    }
    if (!_hasListeners) c.complete(null);
    final res = await c.future;
    return res is FPosition<double> ? res : null;
  }

  /// 设置隐藏
  Future<void> setFloatingHide(bool isHide) =>
      _emitCommand(ControllerEnumType.setEnableHide, value: isHide);

  /// 设置是否允许拖动（运行时切换）
  Future<void> setDragEnable(bool enable) =>
      _emitCommand(ControllerEnumType.setDragEnable, value: enable);

  /// 设置宽高以适应悬浮窗位置
  /// [width]：宽度
  /// [height]：高度
  /// 在即将修改大小时，请调用此方法通知悬浮窗进行大小调整，以自适应悬浮窗位置。
  /// ps：此方法非必须调用，悬浮窗会监听组件大小自动调整。
  ///     但是监听大小意味着是在宽高变化之后才调整位置，部分情况下可能会有一帧的闪烁。
  ///     调用此方法可以在宽高变化之前就调整位置，避免闪烁。
  void setWAndH(double width, double height) => _commandController
      .add(_ControllerCommand(ControllerEnumType.sizeChange, value: FPosition(width, height)));

  /// 自动吸边，调用后，悬浮窗会自动滑动到屏幕边缘
  /// [type]：吸边类型，默认为 SnapEdgeType.snapEdgeAuto
  /// 注意：此方法在悬浮窗没有吸边时有效，如果悬浮窗已经吸边，则不会有任何效果
  void autoSnapEdge({SnapEdgeType type = SnapEdgeType.snapEdgeAuto}) =>
      _commandController.add(_ControllerCommand(ControllerEnumType.autoEdge, value: type));

  /// 设置滑动时间，单位毫秒（同步命令）
  void scrollTime(int millis) =>
      _commandController.add(_ControllerCommand(ControllerEnumType.scrollTime, value: millis));

  /// 从当前位置偏移[offset]的位置滑动
  Future<void> scrollBy(double x, double y) =>
      _emitCommand(ControllerEnumType.scrollBy, value: FPosition(x, y));

  /// 获取吸附后回弹至与边缘的距离
  Future<double> getSnapToEdgeSpace() async {
    var c = Completer<dynamic>();
    var cmd = _ControllerCommand(ControllerEnumType.getSnapToEdgeSpace, completer: c);
    try {
      _commandController.add(cmd);
    } catch (_) {
      c.complete(0.0);
    }
    if (!_hasListeners) c.complete(0.0);
    return c.future.then((value) => value is double ? value : 0.0);
  }

  /// 设置吸附后回弹至与边缘的距离，正值限制在内、负值允许超出。
  /// 同[FloatingParams.snapToEdgeSpace]
  void setSnapToEdgeSpace(double space) {
    _commandController.add(_ControllerCommand(ControllerEnumType.setSnapToEdgeSpace, value: space));
  }

  /// 配合[FloatingParams.snapToEdgeSpace]使用
  /// 若设置了边缘吸附距离，调用此方法，可在(切边)到该距离之间切换吸附位置
  /// 例如：当 snapToEdgeSpace 为 -20，则调用此方法后，会从 -20 滑动到 0 位置，
  /// 重复调用则会从 0 滑动到 -20 位置
  /// 注意1：此方法仅在设置了 snapToEdgeSpace 后有效
  /// 注意2：此方法不会触发自动吸边逻辑，仅在当前位置与边缘距离在 snapToEdgeSpace 范围内切换
  /// 注意3：如果当前位置不在边缘 和 snapToEdgeSpace 位置，调用此方法不会有任何效果
  Future<void> scrollSnapToEdgeSpaceToggle() =>
      _emitCommand(ControllerEnumType.scrollSnapToEdgeSpaceToggle);

  /// 从当前滑动到距离顶部[top]的位置
  Future<void> scrollTop(double top) => _emitCommand(ControllerEnumType.scrollTop, value: top);

  /// 从当前滑动到距离左边[left]的位置
  Future<void> scrollLeft(double left) => _emitCommand(ControllerEnumType.scrollLeft, value: left);

  /// 从当前滑动到距离右边[right]的位置
  Future<void> scrollRight(double right) =>
      _emitCommand(ControllerEnumType.scrollRight, value: right);

  /// 从当前滑动到距离底部[bottom]的位置
  Future<void> scrollBottom(double bottom) =>
      _emitCommand(ControllerEnumType.scrollBottom, value: bottom);

  /// 从当前滑动到距离顶部[top]和左边[left]的位置
  Future<void> scrollTopLeft(double top, double left) =>
      _emitCommand(ControllerEnumType.scrollTopLeft, value: FPosition<double>(left, top));

  /// 从当前滑动到距离顶部[top]和右边[right]的位置
  Future<void> scrollTopRight(double top, double right) =>
      _emitCommand(ControllerEnumType.scrollTopRight, value: FPosition<double>(right, top));

  /// 从当前滑动到距离底部[bottom]和左边[left]的位置
  Future<void> scrollBottomLeft(double bottom, double left) =>
      _emitCommand(ControllerEnumType.scrollBottomLeft, value: FPosition<double>(left, bottom));

  /// 从当前滑动到距离底部[bottom]和右边[right]的位置
  Future<void> scrollBottomRight(double bottom, double right) =>
      _emitCommand(ControllerEnumType.scrollBottomRight, value: FPosition<double>(right, bottom));
}

/// _ControllerCommand：控制器向视图发送的内部命令对象（私有）
/// - type: 命令类型（ControllerEnumType）
/// - value: 命令携带的参数（double、Point<double>、bool 等）
/// - completer: 可选的 Completer，用于在视图处理完成后返回结果或通知完成
class _ControllerCommand {
  final ControllerEnumType type;
  final dynamic value;
  final Completer<dynamic>? completer;

  _ControllerCommand(this.type, {this.value, this.completer});
}
