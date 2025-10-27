import 'package:flutter/animation.dart';

mixin FloatingScrollMixin on TickerProvider {
  double fy = 0; //悬浮窗距屏幕或父组件顶部的距离
  double fx = 0; //悬浮窗距屏幕或父组件左侧的距离

  int scrollTimeMillis = 300; //滑动时间

  late AnimationController _slideController; //中线回弹动画控制器
  late Animation<double> _slideAnimation; //动画
  late AnimationController _scrollController; //滑动动画控制器

  // 存储当前添加的 listeners，以便在下一次动画前移除，避免累积
  VoidCallback? _slideListener;
  VoidCallback? _scrollListener;

  initScrollAnim() {
    _slideController = AnimationController(duration: const Duration(milliseconds: 0), vsync: this);
    _slideAnimation = Tween(begin: 0.0, end: 0.0).animate(_slideController);
    _scrollController = AnimationController(duration: const Duration(milliseconds: 0), vsync: this);
  }

  disposeScrollAnim() {
    // 移除可能残留的 listeners
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

  animationSlide(double left, double toPositionX, int time, VoidCallback? completed) {
    // 停止并重用已有 controller，设置时长
    if (_slideController.isAnimating) _slideController.stop();
    _slideController.duration = Duration(milliseconds: time);

    // 移除上一次 listener
    if (_slideListener != null) {
      try {
        _slideAnimation.removeListener(_slideListener!);
      } catch (_) {}
      _slideListener = null;
    }

    // tween 从当前 x 到目标位置，确保能从任意起点动画到目标
    _slideAnimation = Tween(begin: fx, end: toPositionX * 1.0).animate(_slideController);
    // 回弹动画监听
    _slideListener = () {
      fx = _slideAnimation.value.toDouble();
      handlerSaveCacheDataAndNotify(fx, fy);
    };
    _slideAnimation.addListener(_slideListener!);

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

  scrollXY(double x, double y, {VoidCallback? onComplete}) {
    // allow animating to zero and ensure we tween from current values to targets
    if ((fx != x) || (fy != y)) {
      if (_scrollController.isAnimating) _scrollController.stop();
      _scrollController.duration = Duration(milliseconds: scrollTimeMillis);

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

  scrollX(double left) {
    // allow scrolling to 0 (edge) as well
    if (left >= 0 && fx != left) {
      scrollXY(left, fy);
    }
  }

  scrollY(double top) {
    // allow scrolling to 0 (edge) as well
    if (top >= 0 && fy != top) {
      scrollXY(fx, top);
    }
  }

  handlerSaveCacheDataAndNotify(double x, double y);
}
