import 'package:flutter/animation.dart';

mixin FloatingScrollMixin on TickerProvider {
  double y = 0; //悬浮窗距屏幕或父组件顶部的距离
  double x = 0; //悬浮窗距屏幕或父组件左侧的距离

  int scrollTimeMillis = 300; //滑动时间

  late AnimationController _slideController; //中线回弹动画控制器
  late Animation<double> _slideAnimation; //动画
  late AnimationController _scrollController; //滑动动画控制器

  initScrollAnim() {
    _slideController = AnimationController(duration: const Duration(milliseconds: 0), vsync: this);
    _slideAnimation = Tween(begin: 0.0, end: 0.0).animate(_slideController);
    _scrollController = AnimationController(duration: const Duration(milliseconds: 0), vsync: this);
  }

  disposeScrollAnim() {
    _slideController.dispose();
    _scrollController.dispose();
  }


  animationSlide(double left, double toPositionX, int time, Function completed) {
    _slideController.dispose();
    _slideController = AnimationController(duration: Duration(milliseconds: time), vsync: this);
    _slideAnimation = Tween(begin: left, end: toPositionX * 1.0).animate(_slideController);
    //回弹动画
    _slideAnimation.addListener(() {
      x = _slideAnimation.value.toDouble();
      handlerSaveCacheDataAndNotify(x, y);
    });
    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        completed.call();
      }
    });
    _slideController.forward();
  }

  scrollXY(double x, double y) {
    if ((x > 0 || y > 0) && (this.x != x || this.y != y)) {
      _scrollController.dispose();
      _scrollController =
          AnimationController(duration: Duration(milliseconds: scrollTimeMillis), vsync: this);
      var t = Tween(begin: y, end: y).animate(_scrollController);
      var l = Tween(begin: x, end: x).animate(_scrollController);
      _scrollController.addListener(() {
        y = t.value.toDouble();
        x = l.value.toDouble();
        handlerSaveCacheDataAndNotify(x, y);
      });
      _scrollController.forward();
    }
  }

  scrollX(double left) {
    if (left > 0 && x != left) {
      _scrollController.dispose();
      _scrollController =
          AnimationController(duration: Duration(milliseconds: scrollTimeMillis), vsync: this);
      var anim = Tween(begin: x, end: left).animate(_scrollController);
      anim.addListener(() {
        x = anim.value.toDouble();
        handlerSaveCacheDataAndNotify(x, y);
      });
      _scrollController.forward();
    }
  }

  scrollY(double top) {
    if (top > 0 && y != top) {
      _scrollController.dispose();
      _scrollController =
          AnimationController(duration: Duration(milliseconds: scrollTimeMillis), vsync: this);
      var anim = Tween(begin: y, end: top).animate(_scrollController);
      anim.addListener(() {
        y = anim.value.toDouble();
        handlerSaveCacheDataAndNotify(x, y);
      });
      _scrollController.forward();
    }
  }

  handlerSaveCacheDataAndNotify(double x, double y);
}
