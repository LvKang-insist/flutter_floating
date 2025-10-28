import 'package:flutter/animation.dart';

// FloatingScrollMixin 提供悬浮窗在屏幕上平移动画与立即设置位置的逻辑。
// 主要职责：
// - 管理 X/Y 两个坐标（fx, fy），以及基于 AnimationController 的平移动画。
// - 在动画时添加/移除监听器以更新位置并保存缓存/通知。
// - 当传入的时长为 0 或者负数时，避免调用 AnimationController.forward（会触发 Flutter 的断言），改为同步设置最终位置并回调。
// 该 mixin 需要一个 TickerProvider（通常是 State 对象）作为 vsync。
mixin FloatingScrollMixin on TickerProvider {
  double fy = 0; //悬浮窗距屏幕或父组件顶部的距离
  double fx = 0; //悬浮窗距屏幕或父组件左侧的距离

  int scrollTimeMillis = 300; // 滑动时间（毫秒），用于 scrollXY 的默认时长

  late AnimationController _slideController; // 中线回弹动画控制器
  late Animation<double> _slideAnimation; // 回弹动画的值流
  late AnimationController _scrollController; // 平移动画控制器（同时驱动 x/y）

  // 存储当前添加的 listeners，以便在下一次动画前移除，避免累积导致内存泄漏
  VoidCallback? _slideListener;
  VoidCallback? _scrollListener;

  // 初始化动画控制器（通常在 State.initState 中调用）
  initScrollAnim() {
    // 初始使用 0 时长；实际执行动画前会根据需要设置合适 duration
    _slideController = AnimationController(duration: const Duration(milliseconds: 0), vsync: this);
    _slideAnimation = Tween(begin: 0.0, end: 0.0).animate(_slideController);
    _scrollController = AnimationController(duration: const Duration(milliseconds: 0), vsync: this);
  }

  // 释放资源（通常在 State.dispose 中调用）
  disposeScrollAnim() {
    // 尝试移除残留的 listener
    if (_slideListener != null) {
      try {
        _slideAnimation.removeListener(_slideListener!);
      } catch (_) {}
      _slideListener = null;
    }
    if (_scrollListener != null) {
      try {
        _scrollController.removeListener(_scrollListener!);
      } catch (_) {}
      _scrollListener = null;
    }
    _slideController.dispose();
    _scrollController.dispose();
  }

  // animationSlide：将当前 fx 从当前位置动画到 toPositionX
  // 参数：
  // - left: （未使用的历史参数，保留以兼容调用）
  // - toPositionX: 目标 X 位置
  // - time: 动画时长（毫秒），如果为 0 或负数则直接设置目标位置而不启用动画
  // - completed: 动画完成或立即设置后的回调
  animationSlide(double left, double toPositionX, int time, VoidCallback? completed) {
    // 停止并重用已有 controller，设置时长
    if (_slideController.isAnimating) _slideController.stop();
    _slideController.duration = Duration(milliseconds: time);

    // 关键保护：如果时长为 0 或负数，不要调用 .forward()，因为在 Flutter 内部这会触发
    // 'simulationDuration > Duration.zero' 的断言。改为立即把位置设置为目标值，并调用完成回调。
    // 使用 null 合并以保证在空安全下不会对 null 调用比较运算符。
    if ((_slideController.duration ?? Duration.zero) <= Duration.zero) {
      // 立即应用最终位置并通知（同步完成）
      fx = toPositionX * 1.0;
      handlerSaveCacheDataAndNotify(fx, fy);
      try {
        if (completed != null) completed();
      } catch (_) {}
      return;
    }

    // 移除上一次 listener，避免重复添加
    if (_slideListener != null) {
      try {
        _slideAnimation.removeListener(_slideListener!);
      } catch (_) {}
      _slideListener = null;
    }

    // tween 从当前 x 到目标位置，确保能从任意起点动画到目标
    _slideAnimation = Tween(begin: fx, end: toPositionX * 1.0).animate(_slideController);
    // 回弹动画监听：更新 fx 并保存/通知
    _slideListener = () {
      fx = _slideAnimation.value.toDouble();
      handlerSaveCacheDataAndNotify(fx, fy);
    };
    _slideAnimation.addListener(_slideListener!);

    // 状态监听：动画完成后移除 listener 并回调
    void _statusHandler(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        // remove listener after complete to avoid leak
        if (_slideListener != null) {
          try {
            _slideAnimation.removeListener(_slideListener!);
          } catch (_) {}
          _slideListener = null;
        }
        // 调用外部回调（如果有）
        try {
          if (completed != null) completed();
        } catch (_) {}
        _slideController.removeStatusListener(_statusHandler);
      }
    }

    _slideController.addStatusListener(_statusHandler);
    _slideController.forward(from: 0.0);
  }

  // scrollXY：同时动画/设置 fx 和 fy 的值
  // 如果目标值与当前值相同则直接返回
  // 当内部的动画时长（scrollTimeMillis）为 0 或负数时，立即设置最终值并回调 onComplete
  scrollXY(double x, double y, {VoidCallback? onComplete}) {
    // 仅当目标与当前有差异时才处理
    if ((fx != x) || (fy != y)) {
      if (_scrollController.isAnimating) _scrollController.stop();
      _scrollController.duration = Duration(milliseconds: scrollTimeMillis);

      // 零时长保护：避免使用 .forward() 启动长度为 0 的动画（会触发断言），直接写最终值并回调
      if ((_scrollController.duration ?? Duration.zero) <= Duration.zero) {
        fy = y;
        fx = x;
        handlerSaveCacheDataAndNotify(fx, fy);
        try {
          if (onComplete != null) onComplete();
        } catch (_) {}
        return;
      }

      // remove previous listener if any
      if (_scrollListener != null) {
        try {
          _scrollController.removeListener(_scrollListener!);
        } catch (_) {}
        _scrollListener = null;
      }

      // create animations for x and y driven by the same controller
      final animY = Tween(begin: fy, end: y).animate(_scrollController);
      final animX = Tween(begin: fx, end: x).animate(_scrollController);

      _scrollListener = () {
        fy = animY.value.toDouble();
        fx = animX.value.toDouble();
        handlerSaveCacheDataAndNotify(fx, fy);
      };

      _scrollController.addListener(_scrollListener!);

      void _statusHandler(AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (_scrollListener != null) {
            try {
              _scrollController.removeListener(_scrollListener!);
            } catch (_) {}
            _scrollListener = null;
          }
          // 调用外部回调（如果传入）
          try {
            if (onComplete != null) onComplete();
          } catch (_) {}
          _scrollController.removeStatusListener(_statusHandler);
        }
      }

      _scrollController.addStatusListener(_statusHandler);
      _scrollController.forward(from: 0.0);
    }
  }

  // 辅助：只对 X 方向执行滚动
  scrollX(double left) {
    // allow scrolling to 0 (edge) as well
    if (left >= 0 && fx != left) {
      scrollXY(left, fy);
    }
  }

  // 辅助：只对 Y 方向执行滚动
  scrollY(double top) {
    // allow scrolling to 0 (edge) as well
    if (top >= 0 && fy != top) {
      scrollXY(fx, top);
    }
  }

  // 抽象方法：实现类需保存缓存并通知外部位置变化
  handlerSaveCacheDataAndNotify(double x, double y);
}
