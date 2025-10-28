import 'snap_stop_type.dart';

class FloatingParams {
  ///是否在调用 [Floating.open] 时，保持上一次 [Floating.close] 前的位置
  final bool enablePositionCache;

  ///是否自动吸附左右边缘，默认为 true
  final bool isSnapToEdge;

  ///是否允许拖动悬浮窗，默认为 true
  final bool isDragEnable;

  ///是否打印日志，默认为 false
  final bool isShowLog;

  ///拖动时的透明度，默认为 0.3
  ///请注意，移动默认是有透明动画的，如需要关闭透明度动画，请修改 [dragOpacity]为 1
  final double dragOpacity;

  ///拖动范围限制，与顶部的最小距离（可设为负数）
  final double marginTop;

  ///拖动范围限制，与底部的最小距离（可设为负数）
  final double marginBottom;

  ///吸附后回弹至与边缘的距离，正值限制在内、负值允许超出。
  final double snapToEdgeSpace;

  ///吸附边缘的速度，默认 250，越大越快
  final int snapToEdgeSpeed;

  ///拖动后吸附在哪一侧
  final SnapEdgeType snapEdgeType;

  /// 移动通知节流间隔（毫秒），默认 16ms（约 60fps）
  final int notifyThrottleMs;

  const FloatingParams({
    this.enablePositionCache = true,
    this.isSnapToEdge = true,
    this.isDragEnable = true,
    this.isShowLog = false,
    this.dragOpacity = 0.3,
    this.marginTop = 0,
    this.marginBottom = 0,
    this.snapToEdgeSpace = 0,
    this.snapToEdgeSpeed = 250,
    this.snapEdgeType = SnapEdgeType.snapEdgeAuto,
    this.notifyThrottleMs = 16,
  });

  FloatingParams copyWith({
    bool? enablePositionCache,
    bool? isSnapToEdge,
    bool? isDragEnable,
    bool? isShowLog,
    double? dragOpacity,
    double? marginTop,
    double? marginBottom,
    double? snapToEdgeSpace,
    int? snapToEdgeSpeed,
    SnapEdgeType? snapEdgeType,
    int? notifyThrottleMs,
  }) {
    return FloatingParams(
      enablePositionCache: enablePositionCache ?? this.enablePositionCache,
      isSnapToEdge: isSnapToEdge ?? this.isSnapToEdge,
      isDragEnable: isDragEnable ?? this.isDragEnable,
      isShowLog: isShowLog ?? this.isShowLog,
      dragOpacity: dragOpacity ?? this.dragOpacity,
      marginTop: marginTop ?? this.marginTop,
      marginBottom: marginBottom ?? this.marginBottom,
      snapToEdgeSpace: snapToEdgeSpace ?? this.snapToEdgeSpace,
      snapToEdgeSpeed: snapToEdgeSpeed ?? this.snapToEdgeSpeed,
      snapEdgeType: snapEdgeType ?? this.snapEdgeType,
      notifyThrottleMs: notifyThrottleMs ?? this.notifyThrottleMs,
    );
  }
}
