import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../assist/floating_data.dart';
import '../assist/floating_slide_type.dart';
import '../assist/hide_control.dart';
import '../listener/floating_listener.dart';
import '../utils/floating_log.dart';

/// @name：floating
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/09 22:33
/// @des：

class FloatingView extends StatefulWidget {
  final Widget child;
  final FloatingData floatingData;
  final bool isPosCache;
  final bool isSnapToEdge;
  final HideController _hideControl;
  final List<FloatingListener> _listener;
  final FloatingLog _log;
  final double slideTopHeight;
  final double slideBottomHeight;
  final double moveOpacity; // 悬浮组件透明度

  const FloatingView(this.child, this.floatingData, this.isPosCache,
      this.isSnapToEdge, this._hideControl, this._listener, this._log,
      {Key? key,
      this.slideTopHeight = 0,
      this.slideBottomHeight = 0,
      this.moveOpacity = 0.3})
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

  late AnimationController _controller; //动画控制器

  late Animation<double> _animation; //动画

  bool isHide = false;

  @override
  void initState() {
    super.initState();
    _floatingData = widget.floatingData;
    widget._hideControl
        .setHideControl((isHide) => setState(() => this.isHide = isHide));
    _contentWidget = _content();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 0), vsync: this);
    _animation = Tween(begin: 0.0, end: 0.0).animate(_controller);
    _initPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 300),
              child: Offstage(
                offstage: isHide,
                child: OrientationBuilder(builder: (context, orientation) {
                  checkScreenChange();
                  return Opacity(
                    child: _contentWidget,
                    opacity: _isInitPosition ? 1 : 0,
                  );
                }),
              )),
          left: _left,
          top: _top,
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
        _left += details.delta.dx;
        _top += details.delta.dy;
        _opacity = widget.moveOpacity;
        _changePosition();
        _notifyMove(_left, _top);
      },
      //滑动结束
      onPanEnd: (DragEndDetails details) {
        _changePosition();
        //停止后靠边操作
        _animateMovePosition();
      },
      //滑动取消
      onPanCancel: () {
        _changePosition();
      },
      child: Container(
        key: _floatingGlobalKey,
        child: widget.child,
      ),
    );
  }

  _resetWidthHeight() {
    renderBox ??=
        _floatingGlobalKey.currentContext?.findRenderObject() as RenderBox?;
    _width = renderBox?.size.width ?? _defaultWidth;
    _height = renderBox?.size.height ?? _defaultHeight;
  }

  ///边界判断
  _changePosition() {
    _resetWidthHeight();
    _setParentHeightAndWidget();
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
    if (!widget.isSnapToEdge) return;
    _setParentHeightAndWidget();
    double centerX = _left + _width / 2.0;
    double toPositionX = 0;
    double needMoveLength = 0;

    //计算靠边的距离
    if (centerX <= _parentWidth / 2) {
      needMoveLength = _left;
    } else {
      //靠右边的距离
      needMoveLength = (_parentWidth - _left - _width);
    }
    //根据滑动距离计算滑动时间
    double parent = (needMoveLength / (_parentWidth / 2.0));
    int time = (600 * parent).ceil();

    if (centerX <= _parentWidth / 2.0) {
      toPositionX = 0; //回到左边缘
    } else {
      toPositionX = _parentWidth - _width; //回到右边缘
    }

    _controller.dispose();
    _controller = AnimationController(
        duration: Duration(milliseconds: time), vsync: this);
    _animation =
        Tween(begin: _left, end: toPositionX * 1.0).animate(_controller);
    _animation.addListener(() {
      _left = _animation.value.toDouble();
      setState(() {
        _saveCacheData(_left, _top);
        _notifyMove(_left, _top);
      });
    });

    if (_opacity != 1.0) {
      _animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() => _opacity = 1.0);
            _notifyMoveEnd(_left, _top);
          });
        }
      });
    }
    _controller.forward();
  }

  _initPosition() {
    _resetWidthHeight();
    //使用缓存
    if (widget.isPosCache) {
      //如果之前没有缓存数据
      if (_floatingData.top == null && _floatingData.left == null) {
        setSlide();
      } else {
        _setCacheData();
      }
    } else {
      setSlide();
    }
    _isInitPosition = true;
  }

  ///判断屏幕是否发生改变
  checkScreenChange() {
    _resetWidthHeight();
    _setParentHeightAndWidget();
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
        _top = MediaQuery.of(context).size.height -
            (_floatingData.bottom ?? 0) -
            _height;
        break;
      case FloatingSlideType.onRightAndTop:
        _top = _floatingData.top ?? 0;
        _left = MediaQuery.of(context).size.width -
            (_floatingData.right ?? 0) -
            _width;
        break;
      case FloatingSlideType.onRightAndBottom:
        _top = MediaQuery.of(context).size.height -
            (_floatingData.bottom ?? 0) -
            _height;
        _left = MediaQuery.of(context).size.width -
            (_floatingData.right ?? 0) -
            _width;
        break;
    }
    _saveCacheData(_left, _top);
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
      final schedulerPhase = SchedulerBinding.instance?.schedulerPhase;
      if (schedulerPhase == SchedulerPhase.persistentCallbacks) {
        SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
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
    _controller.dispose();
  }
}
