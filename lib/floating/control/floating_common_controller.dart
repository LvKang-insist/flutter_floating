import 'dart:async';
import 'dart:math';

import 'controller_type.dart';

/// FloatingCommonController：对外提供的控制器 API（中文注释）
///
/// 实现细节：控制器通过内部的 [commands] 流向 Floating 视图发送结构化命令。
/// 视图订阅该流并在收到命令时执行。对于需要等待完成的操作（如动画），
/// 控制器会创建一个 Completer 并将其放入命令中，视图在完成操作后调用
/// completer.complete(...)（可带返回值）。控制器在没有监听器的情况下
/// 会立刻完成对应的 Future，避免调用者无限等待。
class FloatingCommonController {
  // 私有命令流，库内部（part）可访问，外部无法访问
  final StreamController<_ControllerCommand> _commandController = StreamController.broadcast();

  /// 控制器命令流（私有），供库内部的 FloatingView 订阅
  Stream<_ControllerCommand> get commands => _commandController.stream;

  /// 关闭内部流，控制器不再使用时调用
  void dispose() {
    try {
      _commandController.close();
    } catch (_) {}
  }

  /// 获取 Floating 位置（异步实现）：发送 setPoint 命令并等待视图返回 Point
  Future<Point<double>?> currentPosition() async {
    final c = Completer<dynamic>();
    final cmd = _ControllerCommand(ControllerEnumType.setPoint, completer: c);
    try {
      _commandController.add(cmd);
    } catch (_) {
      c.complete(null);
    }
    if (!_hasListeners) c.complete(null);
    final res = await c.future;
    return res is Point<double> ? res : null;
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

  /// 设置隐藏（true 隐藏）
  Future<void> setFloatingHide(bool isHide) =>
      _emitCommand(ControllerEnumType.setEnableHide, value: isHide);

  /// 设置是否允许拖动（运行时切换）
  Future<void> setDragEnable(bool enable) =>
      _emitCommand(ControllerEnumType.setDragEnable, value: enable);

  /// 刷新 Floating（同步命令）
  void refresh() => _commandController.add(_ControllerCommand(ControllerEnumType.refresh));

  /// 设置滑动时间，单位毫秒（同步命令）
  void scrollTime(int millis) =>
      _commandController.add(_ControllerCommand(ControllerEnumType.scrollTime, value: millis));

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
      _emitCommand(ControllerEnumType.scrollTopLeft, value: Point<double>(left, top));

  /// 从当前滑动到距离顶部[top]和右边[right]的位置
  Future<void> scrollTopRight(double top, double right) =>
      _emitCommand(ControllerEnumType.scrollTopRight, value: Point<double>(right, top));

  /// 从当前滑动到距离底部[bottom]和左边[left]的位置
  Future<void> scrollBottomLeft(double bottom, double left) =>
      _emitCommand(ControllerEnumType.scrollBottomLeft, value: Point<double>(left, bottom));

  /// 从当前滑动到距离底部[bottom]和右边[right]的位置
  Future<void> scrollBottomRight(double bottom, double right) =>
      _emitCommand(ControllerEnumType.scrollBottomRight, value: Point<double>(right, bottom));
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
