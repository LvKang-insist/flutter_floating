import 'package:floating/floating/floating.dart';
import 'package:floating/floating/control/hide_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../data/floating_data.dart';
import '../enum/floating_slide_type.dart';

/// @name：floating
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/09 22:33
/// @des：

class FloatingView extends StatefulWidget {
  final Widget child;
  final FloatingData floatingData;
  final bool isPosCache;
  final double? width;
  final double? height;
  final HideController _hideControl;

  const FloatingView(
      this.child, this.floatingData, this.isPosCache, this._hideControl,
      {Key? key, this.width, this.height})
      : super(key: key);

  @override
  _FloatingViewState createState() => _FloatingViewState();
}

class _FloatingViewState extends State<FloatingView>
    with TickerProviderStateMixin {
  double _top = 0;
  double _left = 0;

  late FloatingData _floatingData;

  final double _defaultWidth = 100; //默认宽度

  final double _defaultHeight = 100; //默认高度

  late double _width;

  late double _height;

  double _parentWidget = 0; //记录屏幕或者父组件宽度，用来判断拖拽停后回归左边还是右边

  double _opacity = 1.0; // 悬浮组件透明度

  bool _isInitPosition = false;

  late Widget _contentWidget;

  late AnimationController _controller; //动画控制器

  late Animation<double> _animation; //动画

  bool isHide = false;

  @override
  void initState() {
    super.initState();
    _width = widget.width ?? _defaultWidth;
    _height = widget.height ?? _defaultHeight;
    _floatingData = widget.floatingData;
    widget._hideControl
        .setHideControl((isHide) => setState(() => this.isHide = isHide));
    _contentWidget = _content();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 0), vsync: this);
    _animation = Tween(begin: 0.0, end: 0.0).animate(_controller);
  }

  _content() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      //滑动
      onPanUpdate: (DragUpdateDetails details) {
        _left += details.delta.dx;
        _top += details.delta.dy;
        _opacity = 0.3;
        _changePosition();
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
        width: _width,
        height: _height,
        child: UnconstrainedBox(child: widget.child),
      ),
    );
  }

  ///边界判断
  _changePosition() {
    //不能超过左边界
    if (_left < 0) _left = 0;
    //不能超过右边界
    var w = MediaQuery.of(context).size.width;
    if (_left >= w - _width) {
      _left = w - _width;
    }

    if (_top < 0) _top = 0;
    var t = MediaQuery.of(context).size.height;
    if (_top >= t - _width) {
      _top = t - _width;
    }
    setState(() {
      _floatingData.left = _left;
      _floatingData.top = _top;
    });
  }

  ///中线回弹动画
  _animateMovePosition() {
    double centerX = _left + _width / 2.0;
    double toPositionX = 0;
    double needMoveLength = 0;

    //计算靠边的距离
    if (centerX <= _parentWidget / 2) {
      needMoveLength = _left;
    } else {
      //靠右边的距离
      needMoveLength = (_parentWidget - _left - _width);
    }
    //根据滑动距离计算滑动时间
    double parent = (needMoveLength / (_parentWidget / 2.0));
    int time = (600 * parent).ceil();

    if (centerX <= _parentWidget / 2.0) {
      toPositionX = 0; //回到左边缘
    } else {
      toPositionX = _parentWidget - _width; //回到右边缘
    }

    _controller.dispose();
    _controller = AnimationController(
        duration: Duration(milliseconds: time), vsync: this);
    _animation =
        Tween(begin: _left, end: toPositionX * 1.0).animate(_controller);
    _animation.addListener(() {
      _left = _animation.value.toDouble();
      setState(() {
        _floatingData.left = _left;
        _floatingData.top = _top;
      });
    });

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() => _opacity = 1.0);
        });
      }
    });
    _controller.forward();
  }

  _initPosition() {
    //使用缓存
    if (widget.isPosCache) {
      //如果之前没有缓存数据
      if (_floatingData.top == null && _floatingData.left == null) {
        setSlide();
      } else {
        //获取缓存数据
        _top = _floatingData.top ?? 0;
        _left = _floatingData.left ?? 0;
      }
    } else {
      setSlide();
    }
    _parentWidget = MediaQuery.of(context).size.width;
    _isInitPosition = true;
  }

  @override
  Widget build(BuildContext context) {
    !_isInitPosition ? _initPosition() : null;
    return Stack(
      children: [
        Positioned(
          child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 300),
              child: Offstage(
                offstage: isHide,
                child: _contentWidget,
              )),
          left: _left,
          top: _top,
        )
      ],
    );
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
    _floatingData.left = _left;
    _floatingData.top = _top;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
