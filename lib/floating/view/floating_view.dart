import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_floating/floating/assist/slide_stop_type.dart';
import 'package:flutter_floating/floating/control/common_control.dart';

import '../assist/floating_data.dart';
import '../assist/floating_slide_type.dart';
import '../control/scroll_position_control.dart';
import '../listener/event_listener.dart';
import '../utils/floating_log.dart';

/// @name：floating
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/09 22:33
/// @des：悬浮窗容器

class FloatingView extends StatefulWidget {
  final Widget child;
  final FloatingData floatingData;
  final bool isPosCache;
  final bool isSnapToEdge;
  final List<FloatingEventListener> _listener;
  final ScrollPositionControl _scrollPositionControl;
  final FloatingLog _log;
  final double slideTopHeight;
  final double slideBottomHeight;
  final double moveOpacity; // 悬浮组件透明度
  final SlideStopType slideStopType;
  final CommonControl _commonControl;

  const FloatingView(
      this.child,
      this.floatingData,
      this.isPosCache,
      this.isSnapToEdge,
      this._listener,
      this._scrollPositionControl,
      this._commonControl,
      this._log,
      {Key? key,
      this.slideTopHeight = 0,
      this.slideBottomHeight = 0,
      this.moveOpacity = 0.3,
      this.slideStopType = SlideStopType.slideStopAutoType})
      : super(key: key);

  @override
  _FloatingViewState createState() => _FloatingViewState();
}

class _FloatingViewState extends State<FloatingView>
    with TickerProviderStateMixin {
  final _floatingGlobalKey = GlobalKey();
  RenderBox? renderBox;

  double _top = 0;
  double _left = 0;

  late FloatingData _floatingData;

  final double _defaultWidth = 100; //默认宽度

  final double _defaultHeight = 100; //默认高度

  double _width = 0;

  double _height = 0;

  double _parentWidth = 0; //记录屏幕或者父组件宽度
  double _parentHeight = 0; //记录屏幕或者父组件宽度

  double _opacity = 1.0; // 悬浮组件透明度

  bool _isInitPosition = false;

  late Widget _contentWidget;

  late AnimationController _slideController; //动画控制器
  late Animation<double> _slideAnimation; //动画

  late AnimationController _scrollController; //动画控制器

  bool isHide = false;

  bool _isStartScroll = true; //是否启动悬浮窗滑动

  @override
  void initState() {
    super.initState();
    _floatingData = widget.floatingData;
    widget._commonControl
        .setHideControlListener((isHide) => setState(() => this.isHide = isHide));
    _isStartScroll = widget._commonControl.getInitIsScroll();
    widget._commonControl
        .setIsStartScrollListener((isScroll) => _isStartScroll = isScroll);
    _contentWidget = _content();
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 0), vsync: this);
    _slideAnimation = Tween(begin: 0.0, end: 0.0).animate(_slideController);
    _scrollController = AnimationController(
        duration: const Duration(milliseconds: 0), vsync: this);
    _setScrollControl();
    setState(() {
      _setParentHeightAndWidget();
      _resetFloatingSize();
      _initPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: _left,
          top: _top,
          child: AnimatedOpacity(
              opacity: _opacity,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 200),
              child: Offstage(
                offstage: isHide,
                child: OrientationBuilder(builder: (context, orientation) {
                  _checkScreenChange();
                  return Opacity(
                    child: _contentWidget,
                    opacity: _isInitPosition ? 1 : 0,
                  );
                }),
              )),
        )
      ],
    );
  }

  _content() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _notifyDown(_left, _top),
      onTapCancel: () => _notifyUp(_left, _top),
      //滑动
      onPanUpdate: (DragUpdateDetails details) {
        if (!_checkStartScroll()) return;
        _left += details.delta.dx;
        _top += details.delta.dy;
        _opacity = widget.moveOpacity;
        _changePosition();
        _notifyMove(_left, _top);
      },
      //滑动结束
      onPanEnd: (DragEndDetails details) {
        if (!_checkStartScroll()) return;
        _changePosition();
        //停止后靠边操作
        _animateMovePosition();
      },
      //滑动取消
      onPanCancel: () {
        if (!_checkStartScroll()) return;
        _changePosition();
      },
      child: Container(
        key: _floatingGlobalKey,
        child: NotificationListener(
            onNotification: (notification) {
              if (notification is SizeChangedLayoutNotification &&
                  _isFloatingChangeSize()) {
                _setParentHeightAndWidget();
                _resetFloatingSize();
                setState(() {
                  if (_left + _width > _parentWidth) {
                    _left = _parentWidth - _width;
                  }
                  if (_top + _height > _parentHeight) {
                    _top = _parentHeight - _height;
                  }
                });
              }
              return false;
            },
            child: SizeChangedLayoutNotifier(child: widget.child)),
      ),
    );
  }

  ///floating 宽高是否改变，true 表示改变
  bool _isFloatingChangeSize() {
    renderBox ??=
        _floatingGlobalKey.currentContext?.findRenderObject() as RenderBox?;
    var w = renderBox?.size.width ?? _defaultWidth;
    var h = renderBox?.size.height ?? _defaultHeight;
    return w != _width || h != _height;
  }

  _resetFloatingSize() {
    renderBox ??=
        _floatingGlobalKey.currentContext?.findRenderObject() as RenderBox?;
    _width = renderBox?.size.width ?? _defaultWidth;
    _height = renderBox?.size.height ?? _defaultHeight;
  }

  ///边界判断
  _changePosition() {
    //不能超过左边界
    if (_left < 0) _left = 0;
    //不能超过右边界
    var w = _parentWidth;
    if (_left >= w - _width) {
      _left = w - _width;
    }
    if (_top < widget.slideTopHeight) _top = widget.slideTopHeight;
    var t = _parentHeight;
    if (_top >= t - _height - widget.slideBottomHeight) {
      _top = t - _height - widget.slideBottomHeight;
    }
    setState(() {
      _saveCacheData(_left, _top);
    });
  }

  ///中线回弹动画
  _animateMovePosition() {
    if (!widget.isSnapToEdge) {
      _recoverOpacity();
      _notifyMoveEnd(_left, _top);
      return;
    }
    double toPositionX = 0;
    double needMoveLength = 0;

    switch (widget.slideStopType) {
      case SlideStopType.slideStopLeftType:
        needMoveLength = _left; //靠左边的距离
        toPositionX = 0; //回到左边缘距离
        break;
      case SlideStopType.slideStopRightType:
        needMoveLength = (_parentWidth - _left - _width); //靠右边的距离
        toPositionX = _parentWidth - _width; //回到右边缘距离
        break;
      case SlideStopType.slideStopAutoType:
        double centerX = _left + _width / 2.0; //中心点位置
        if (centerX <= _parentWidth / 2) {
          needMoveLength = _left; //靠左边的距离
        } else {
          needMoveLength = (_parentWidth - _left - _width); //靠右边的距离
        }
        if (centerX <= _parentWidth / 2.0) {
          toPositionX = 0; //回到左边缘
        } else {
          toPositionX = _parentWidth - _width; //回到右边缘
        }
        break;
    }

    //根据滑动距离计算滑动时间
    double parent = (needMoveLength / (_parentWidth / 2.0));
    int time = (500 * parent).ceil();

    //执行动画
    _animationSlide(_left, toPositionX, time, () {
      //恢复透明度
      _recoverOpacity();
      //结束后进行通知
      _notifyMoveEnd(_left, _top);
    });
  }

  _animationSlide(
      double left, double toPositionX, int time, Function completed) {
    _slideController.dispose();
    _slideController = AnimationController(
        duration: Duration(milliseconds: time), vsync: this);
    _slideAnimation =
        Tween(begin: left, end: toPositionX * 1.0).animate(_slideController);
    //回弹动画
    _slideAnimation.addListener(() {
      _left = _slideAnimation.value.toDouble();
      setState(() {
        _saveCacheData(_left, _top);
        _notifyMove(_left, _top);
      });
    });
    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        completed.call();
      }
    });
    _slideController.forward();
  }

  _setScrollControl() {
    var control = widget._scrollPositionControl;
    control.setScrollTop((top) => _scrollY(top));
    control.setScrollLeft((left) => _scrollX(left));
    control.setScrollRight((right) => _scrollX(_parentWidth - right - _width));
    control.setScrollBottom(
        (bottom) => _scrollY(_parentHeight - bottom - _height));

    control.setScrollTopLeft((top, left) => _scrollXY(left, top));
    control.setScrollTopRight(
        (top, right) => _scrollXY(_parentWidth - right - _width, top));
    control.setScrollBottomLeft(
        (bottom, left) => _scrollXY(left, _parentHeight - bottom - _height));
    control.setScrollBottomRight((bottom, right) => _scrollXY(
        _parentWidth - right - _width, _parentHeight - bottom - _height));
  }

  _scrollXY(double x, double y) {
    if ((x > 0 || y > 0) && (_left != x || _top != y)) {
      var control = widget._scrollPositionControl;
      _scrollController.dispose();
      _scrollController = AnimationController(
          duration: Duration(milliseconds: control.timeMillis), vsync: this);
      var t = Tween(begin: _top, end: y).animate(_scrollController);
      var l = Tween(begin: _left, end: x).animate(_scrollController);
      _scrollController.addListener(() {
        _top = t.value.toDouble();
        _left = l.value.toDouble();
        setState(() {
          _saveCacheData(_left, _top);
          _notifyMove(_left, _top);
        });
      });
      _scrollController.forward();
    }
  }

  _scrollX(double left) {
    if (left > 0 && _left != left) {
      var control = widget._scrollPositionControl;
      _scrollController.dispose();
      _scrollController = AnimationController(
          duration: Duration(milliseconds: control.timeMillis), vsync: this);
      var anim = Tween(begin: _left, end: left).animate(_scrollController);
      anim.addListener(() {
        _left = anim.value.toDouble();
        setState(() {
          _saveCacheData(_left, _top);
          _notifyMove(_left, _top);
        });
      });
      _scrollController.forward();
    }
  }

  _scrollY(double top) {
    if (top > 0 && _top != top) {
      var control = widget._scrollPositionControl;
      _scrollController.dispose();
      _scrollController = AnimationController(
          duration: Duration(milliseconds: control.timeMillis), vsync: this);
      var anim = Tween(begin: _top, end: top).animate(_scrollController);
      anim.addListener(() {
        _top = anim.value.toDouble();
        setState(() {
          _saveCacheData(_left, _top);
          _notifyMove(_left, _top);
        });
      });
      _scrollController.forward();
    }
  }

  ///恢复透明度
  _recoverOpacity() {
    if (_opacity != 1.0) {
      setState(() => _opacity = 1.0);
    }
  }

  _initPosition() {
    //使用缓存
    if (widget.isPosCache) {
      //如果之前没有缓存数据
      if (_floatingData.top == null || _floatingData.left == null) {
        setSlide();
      } else {
        _setCacheData();
      }
    } else {
      setSlide();
    }
    _isInitPosition = true;
  }

  ///检测是否开启滑动
  bool _checkStartScroll() {
    return _isStartScroll;
  }

  ///判断屏幕是否发生改变
  _checkScreenChange() {
    //如果屏幕宽高为0，直接退出
    if (_parentWidth == 0 || _parentHeight == 0) return;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if (width != _parentWidth || height != _parentHeight) {
      setState(() {
        if (!widget.isSnapToEdge) {
          if (height > _parentHeight) {
            _top = _top * (height / _parentHeight);
          } else {
            _top = _top / (_parentHeight / height);
          }
          if (_left > _parentWidth) {
            _left = _left * (_width / _parentWidth);
          } else {
            _left = _left / (_parentWidth / width);
          }
        } else {
          if (_left < _parentWidth / 2) {
            _left = 0;
          } else {
            _left = width - _width;
          }
          if (height > _parentHeight) {
            _top = _top * (height / _parentHeight);
          } else {
            _top = _top / (_parentHeight / height);
          }
        }
        _parentWidth = width;
        _parentHeight = height;
      });
    }
  }

  setSlide() {
    switch (_floatingData.slideType) {
      case FloatingSlideType.onLeftAndTop:
        _top = _floatingData.top ?? 0;
        _left = _floatingData.left ?? 0;
        break;
      case FloatingSlideType.onLeftAndBottom:
        _left = _floatingData.left ?? 0;
        _top = _parentHeight - (_floatingData.bottom ?? 0) - _height;
        break;
      case FloatingSlideType.onRightAndTop:
        _top = _floatingData.top ?? 0;
        _left = _parentWidth - (_floatingData.right ?? 0) - _width;
        break;
      case FloatingSlideType.onRightAndBottom:
        _left = _parentWidth - (_floatingData.right ?? 0) - _width;
        _top = _parentHeight - (_floatingData.bottom ?? 0) - _height;
        break;
    }
    _saveCacheData(_left, _top);
  }

  ///清除缓存数据
  _clearCacheData() {
    _floatingData.left = null;
    _floatingData.top = null;
    _floatingData.right = null;
    _floatingData.bottom = null;
  }

  ///保存缓存位置
  _saveCacheData(double left, double top) {
    if (widget.isPosCache) {
      _floatingData.left = left;
      _floatingData.top = top;
    }
  }

  ///设置缓存数据
  _setCacheData() {
    _top = _floatingData.top ?? 0;
    _left = _floatingData.left ?? 0;
  }

  _setParentHeightAndWidget() {
    if (_parentHeight == 0 || _parentWidth == 0) {
      _parentWidth = MediaQuery.of(context).size.width;
      _parentHeight = MediaQuery.of(context).size.height;
    }
  }

  _notifyMove(double x, double y) {
    widget._log.log("移动 X:$x Y:$y");
    for (var element in widget._listener) {
      element.moveListener?.call(x, y);
    }
  }

  _notifyMoveEnd(double x, double y) {
    widget._log.log("移动结束 X:$x Y:$y");
    for (var element in widget._listener) {
      element.moveEndListener?.call(x, y);
    }
  }

  _notifyDown(double x, double y) {
    widget._log.log("按下 X:$x Y:$y");
    for (var element in widget._listener) {
      element.downListener?.call(x, y);
    }
  }

  _notifyUp(double x, double y) {
    widget._log.log("抬起 X:$x Y:$y");
    for (var element in widget._listener) {
      element.upListener?.call(x, y);
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
      if (schedulerPhase == SchedulerPhase.persistentCallbacks) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          super.setState(fn);
        });
      } else {
        super.setState(fn);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _slideController.dispose();
  }
}
