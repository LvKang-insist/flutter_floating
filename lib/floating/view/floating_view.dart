import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_floating/floating/assist/slide_stop_type.dart';
import 'package:flutter_floating/floating/control/common_control.dart';

import '../assist/Point.dart';
import '../assist/floating_data.dart';
import '../assist/floating_slide_type.dart';
import '../control/scroll_position_control.dart';
import '../listener/event_listener.dart';
import '../utils/floating_log.dart';
import 'dart:math';

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
  final int edgeSpeed; //吸附边缘速度

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
      this.edgeSpeed = 0,
      this.slideStopType = SlideStopType.slideStopAutoType})
      : super(key: key);

  @override
  _FloatingViewState createState() => _FloatingViewState();
}

class _FloatingViewState extends State<FloatingView>
    with TickerProviderStateMixin {
  final _floatingGlobalKey = GlobalKey();
  RenderBox? renderBox;

  double _top = 0; //悬浮窗距屏幕或父组件顶部的距离
  double _left = 0; //悬浮窗距屏幕或父组件左侧的距离

  late FloatingData _floatingData;

  final double _defaultWidth = 100; //默认宽度

  final double _defaultHeight = 100; //默认高度

  double _fWidth = 0; //悬浮窗宽度
  double _fHeight = 0; //悬浮窗高度

  double _parentWidth = 0; //记录屏幕或者父组件宽度
  double _parentHeight = 0; //记录屏幕或者父组件高度

  /// 对于进入或退出画中画(pip)，以及分屏/折叠屏/可变小窗等场景下
  /// 需要处理屏幕或父组件尺寸（暂称 外尺寸）与悬浮窗的位置问题

  /// 在保证预留距离的前提下，当外尺寸变化时，悬浮窗位置需要按比例调整，以尽量显示
  /// 即 边距 与 剩余尺寸 之比。剩余尺寸 = 外尺寸 - 预留距离 - 预留范围内的悬浮窗高度。
  /// 正常情况下，初始化、悬浮窗移动、悬浮窗尺寸变化时，调用 [_setPositionToRemainRatio]
  /// 更新时，如果剩余尺寸 ≤ 0，不计算、不改变该比例，以便外尺寸恢复时复原悬浮窗位置。
  /// 且若此时比例为空，则根据FloatingSlideType赋予初值0或1
  ///
  /// 当外尺寸变化时，调用 [_calcNewPositionByRatio] 计算坐标，以使悬浮窗尽可能显示

  // 顶部边距与剩余高度之比
  /// _top / (_parentHeight - slideTopHeight - slideBottomHeight - heightInRange)
  double? _topToRemainHeightRatio;

  // 左侧边距与剩余宽度之比
  /// _left / (_parentWidth - snapToEdgeSpace * 2 - widthInRange)
  double? _leftToRemainWidthRatio;

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
    widget._commonControl.setHideControlListener(
        (isHide) => setState(() => this.isHide = isHide));
    _isStartScroll = widget._commonControl.getInitIsScroll();
    widget._commonControl
        .setIsStartScrollListener((isScroll) => _isStartScroll = isScroll);
    widget._commonControl.setFloatingPoint((Point<double> point) {
      point.x = _left;
      point.y = _top;
    });
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setPositionToRemainRatio();
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
                  setSlide();
                  _setPositionToRemainRatio();
                  _saveCacheData(_left, _top);
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
    return w != _fWidth || h != _fHeight;
  }

  _resetFloatingSize() {
    renderBox ??=
        _floatingGlobalKey.currentContext?.findRenderObject() as RenderBox?;
    _fWidth = renderBox?.size.width ?? _defaultWidth;
    _fHeight = renderBox?.size.height ?? _defaultHeight;
  }

  ///边界判断
  _changePosition() {
    var type = _floatingData.slideType;
    //定义一个左边界；
    List<double> leftBorder = [0, _parentWidth - _fWidth];
    // 开启吸附时，_floatingData.snapToEdgeSpace为负值则扩展边界，为正由回弹处理
    // 未开启吸附时，_floatingData.snapToEdgeSpace直接作为边界
    if (_floatingData.snapToEdgeSpace < 0 || !widget.isSnapToEdge) {
      leftBorder[0] += _floatingData.snapToEdgeSpace;
      leftBorder[1] -= _floatingData.snapToEdgeSpace;
    }
    // 处理无法移动的情况
    if (leftBorder[1] < leftBorder[0]) {
      if (type == FloatingSlideType.onRightAndBottom ||
          type == FloatingSlideType.onRightAndTop) {
        leftBorder[0] = leftBorder[1];
      } else {
        leftBorder[1] = leftBorder[0];
      }
    }
    _left = max(leftBorder[0], min(leftBorder[1], _left));
    //定义一个上边界
    List<double> topBorder = [
      widget.slideTopHeight,
      _parentHeight - _fHeight - widget.slideBottomHeight
    ];
    // 处理无法移动的情况
    if (topBorder[1] < topBorder[0]) {
      if (type == FloatingSlideType.onRightAndBottom ||
          type == FloatingSlideType.onLeftAndBottom) {
        topBorder[0] = topBorder[1];
      } else {
        topBorder[1] = topBorder[0];
      }
    }
    _top = max(topBorder[0], min(topBorder[1], _top));
    setState(() {
      _saveCacheData(_left, _top);
    });
  }

  ///中线回弹动画
  _animateMovePosition() {
    if (!widget.isSnapToEdge) {
      _recoverOpacity();
      _saveCacheData(_left, _top);
      _setPositionToRemainRatio();
      _notifyMoveEnd(_left, _top);
      return;
    }
    double toPositionX = 0;
    double needMoveLength = 0;

    void _setPositionToLeft() {
      needMoveLength = _left; //靠左边的距离
      toPositionX = 0 + _floatingData.snapToEdgeSpace; //回到左边缘距离
    }

    void _setPositionToRight() {
      needMoveLength = (_parentWidth - _left - _fWidth); //靠右边的距离
      toPositionX =
          _parentWidth - _fWidth - _floatingData.snapToEdgeSpace; //回到右边缘距离
    }

    switch (widget.slideStopType) {
      case SlideStopType.slideStopLeftType:
        _setPositionToLeft();
        break;
      case SlideStopType.slideStopRightType:
        _setPositionToRight();
        break;
      case SlideStopType.slideStopAutoType:
        double centerX = _left + _fWidth / 2.0; //中心点位置
        (centerX < _parentWidth / 2)
            ? _setPositionToLeft()
            : _setPositionToRight();
        break;
    }

    //根据滑动距离计算滑动时间
    double parent = (needMoveLength / (_parentWidth / 2.0));
    int time = (widget.edgeSpeed * parent).ceil();

    //执行动画
    _animationSlide(_left, toPositionX, time, () {
      //恢复透明度
      _recoverOpacity();
      _setPositionToRemainRatio();
      _saveCacheData(_left, _top);
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
    control.setScrollRight((right) => _scrollX(_parentWidth - right - _fWidth));
    control.setScrollBottom(
        (bottom) => _scrollY(_parentHeight - bottom - _fHeight));

    control.setScrollTopLeft((top, left) => _scrollXY(left, top));
    control.setScrollTopRight(
        (top, right) => _scrollXY(_parentWidth - right - _fWidth, top));
    control.setScrollBottomLeft(
        (bottom, left) => _scrollXY(left, _parentHeight - bottom - _fHeight));
    control.setScrollBottomRight((bottom, right) => _scrollXY(
        _parentWidth - right - _fWidth, _parentHeight - bottom - _fHeight));
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
        setInitSlide();
      } else {
        _setCacheData();
      }
    } else {
      setInitSlide();
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
      _parentWidth = width;
      _parentHeight = height;
      setState(() {
        _calcNewPositionByRatio();
      });
      _saveCacheData(_left, _top);
    }
  }

  // 悬浮窗尺寸变化时，根据起始点重新计算坐标
  setSlide() {
    // 计算可用高度和宽度
    double availableHeight =
        _parentHeight - widget.slideTopHeight - widget.slideBottomHeight;
    double availableWidth = _parentWidth - _floatingData.snapToEdgeSpace * 2;
    // 计算剩余高度和宽度
    double remainHeight = availableHeight - _fHeight;
    double remainWidth = availableWidth - _fWidth;
    // 无法完全显示：从起始点角落边缘开始显示
    // 可完全显示，但需要调整：从右下角边缘开始显示
    void _adjustBottom() {
      double currentBottom = _parentHeight - _top - _fHeight;
      // 需要向上调整才能完全显示
      if (currentBottom <= widget.slideBottomHeight) {
        _top = _parentHeight - widget.slideBottomHeight - _fHeight;
      }
    }

    void _adjustRight() {
      double currentRight = _parentWidth - _left - _fWidth;
      // 需要向左调整才能完全显示
      if (currentRight <= _floatingData.snapToEdgeSpace) {
        _left = _parentWidth - _floatingData.snapToEdgeSpace - _fWidth;
      }
    }

    void _topSet() {
      if (remainHeight <= 0) {
        _top = widget.slideTopHeight;
      } else {
        _adjustBottom();
      }
    }

    void _bottomSet() {
      if (remainHeight <= 0) {
        _top = _parentHeight - widget.slideBottomHeight - _fHeight;
      } else {
        _adjustBottom();
      }
    }

    void _leftSet() {
      if (remainWidth <= 0) {
        _left = _floatingData.snapToEdgeSpace;
      } else {
        _adjustRight();
      }
    }

    void _rightSet() {
      if (remainWidth <= 0) {
        _left = _parentWidth - _fWidth - _floatingData.snapToEdgeSpace;
      } else {
        _adjustRight();
      }
    }

    switch (_floatingData.slideType) {
      case FloatingSlideType.onLeftAndTop:
      case FloatingSlideType.onPoint:
        _leftSet();
        _topSet();
        break;
      case FloatingSlideType.onLeftAndBottom:
        _leftSet();
        _bottomSet();
        break;
      case FloatingSlideType.onRightAndTop:
        _rightSet();
        _topSet();
        break;
      case FloatingSlideType.onRightAndBottom:
        _rightSet();
        _bottomSet();
        break;
    }
    _saveCacheData(_left, _top);
  }

  setInitSlide() {
    void _topInit() {
      _top = _floatingData.top ?? widget.slideTopHeight;
    }

    void _leftInit() {
      _left = _floatingData.left ?? _floatingData.snapToEdgeSpace;
    }

    void _rightInit() {
      _left = _parentWidth -
          (_floatingData.right ?? _floatingData.snapToEdgeSpace) -
          _fWidth;
    }

    void _bottomInit() {
      _top = _parentHeight -
          (_floatingData.bottom ?? widget.slideBottomHeight) -
          _fHeight;
    }

    switch (_floatingData.slideType) {
      case FloatingSlideType.onLeftAndTop:
        _topInit();
        _leftInit();
        break;
      case FloatingSlideType.onLeftAndBottom:
        _leftInit();
        _bottomInit();
        break;
      case FloatingSlideType.onRightAndTop:
        _rightInit();
        _topInit();
        break;
      case FloatingSlideType.onRightAndBottom:
        _rightInit();
        _bottomInit();
        break;
      case FloatingSlideType.onPoint:
        _top = _floatingData.point?.y ?? widget.slideBottomHeight;
        _left = _floatingData.point?.x ?? _floatingData.snapToEdgeSpace;
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

  _calcNewTopByRatio() {
    void setBySlide() {
      if (_floatingData.slideType == FloatingSlideType.onLeftAndBottom ||
          _floatingData.slideType == FloatingSlideType.onRightAndBottom) {
        _top = _parentHeight - widget.slideBottomHeight - _fHeight;
      } else {
        _top = widget.slideTopHeight;
      }
    }

    // 可用高度，减去顶部和底部的预留高度
    double availableHeight =
        _parentHeight - widget.slideTopHeight - widget.slideBottomHeight;
    if (availableHeight <= 0) {
      //可用高度小于等于0时，设置在初始位置
      setBySlide();
      return;
    }
    // 悬浮窗可用高度范围内的最小高度
    double heightInRange = min(availableHeight, _fHeight);
    // 计算剩余高度
    double remainHeight = availableHeight - heightInRange;
    if (remainHeight <= 0) {
      //剩余高度小于等于0时，设置在初始位置
      setBySlide();
    } else {
      // 根据剩余高度和距离顶部的高度比,计算新的顶部距离
      _top = _topToRemainHeightRatio! * remainHeight;
    }
  }

  // 处理吸附在左右两侧的情况
  _calcNewLeftWhenSnapToEdge() {
    _slideLeft() {
      _left = _floatingData.snapToEdgeSpace;
    }
    _slideRight() {
      _left = _parentWidth - _fWidth - _floatingData.snapToEdgeSpace;
    }
    switch (widget.slideStopType) {
      case SlideStopType.slideStopLeftType:
        _slideLeft();
        break;
      case SlideStopType.slideStopRightType:
        _slideRight();
        break;
      case SlideStopType.slideStopAutoType:
        var centerX = _parentWidth / 2.0; //中心位置
        ((_left + _fWidth / 2) < centerX) ? _slideLeft() : _slideRight();
        break;
    }
  }

  _calcNewLeftByRatio() {
    void setBySlide() {
      if (_floatingData.slideType == FloatingSlideType.onRightAndBottom ||
          _floatingData.slideType == FloatingSlideType.onRightAndTop) {
        _left = _parentWidth - _fWidth - _floatingData.snapToEdgeSpace;
      } else {
        _left = _floatingData.snapToEdgeSpace;
      }
    }

    //计算可用宽度，减去左右两侧的预留宽度
    double availableWidth = _parentWidth - _floatingData.snapToEdgeSpace * 2;
    if (availableWidth <= 0) {
      setBySlide();
      if (widget.isSnapToEdge) _calcNewLeftWhenSnapToEdge();
      return;
    }
    double widthInRange = min(availableWidth, _fWidth);
    double remainWidth = availableWidth - widthInRange;
    if (remainWidth <= 0) {
      setBySlide();
    } else {
      _left = _leftToRemainWidthRatio! * remainWidth;
    }
    if (widget.isSnapToEdge) _calcNewLeftWhenSnapToEdge();
  }

  _calcNewPositionByRatio() {
    _calcNewTopByRatio();
    _calcNewLeftByRatio();
  }

  _setTopToRemainHeightRatio() {
    double initWhenNoRemainHeight() {
      switch (_floatingData.slideType) {
        case FloatingSlideType.onLeftAndTop:
        case FloatingSlideType.onRightAndTop:
        case FloatingSlideType.onPoint:
          return 0;
        case FloatingSlideType.onLeftAndBottom:
        case FloatingSlideType.onRightAndBottom:
          return 1;
      }
    }

    // 计算可用高度，减去顶部和底部的预留高度
    double availableHeight =
        _parentHeight - widget.slideTopHeight - widget.slideBottomHeight;
    if (availableHeight <= 0) {
      //可用高度小于等于0时，设置比例为初始值
      _topToRemainHeightRatio ??= initWhenNoRemainHeight();
      return;
    }
    // 计算悬浮窗在可用高度范围内的高度
    double heightInRange = min(availableHeight - _top, _fHeight);
    // 根据外部高度和悬浮窗高度计算剩余高度
    double remainHeight = _parentHeight - heightInRange;
    if (remainHeight <= 0) {
      //剩余高度小于等于0时，设置比例为初始值
      _topToRemainHeightRatio ??= initWhenNoRemainHeight();
    } else {
      //计算顶部距离与剩余高度之比
      _topToRemainHeightRatio = _top / remainHeight;
    }
  }

  _setLeftToRemainWidthRatio() {
    double initWhenNoRemainWidth() {
      switch (_floatingData.slideType) {
        case FloatingSlideType.onLeftAndTop:
        case FloatingSlideType.onLeftAndBottom:
          return 0;
        case FloatingSlideType.onRightAndTop:
        case FloatingSlideType.onRightAndBottom:
        case FloatingSlideType.onPoint:
          return 1;
      }
    }

    // 计算可用宽度，减去左右两侧的预留宽度
    double availableWidth = _parentWidth - _floatingData.snapToEdgeSpace * 2;
    if (availableWidth <= 0) {
      //可用宽度小于等于0时，设置比例为初始值
      _leftToRemainWidthRatio ??= initWhenNoRemainWidth();
      return;
    }
    // 计算悬浮窗在可用宽度范围内的宽度
    double widthInRange = min(availableWidth - _left, _fWidth);
    // 根据外部宽度和悬浮窗宽度计算剩余宽度
    double remainWidth = _parentWidth - widthInRange;
    if (remainWidth <= 0) {
      //剩余宽度小于等于0时，设置比例为初始值
      _leftToRemainWidthRatio ??= initWhenNoRemainWidth();
    } else {
      //计算左侧距离与剩余宽度之比
      _leftToRemainWidthRatio = _left / remainWidth;
    }
  }

  _setPositionToRemainRatio() {
    _setTopToRemainHeightRatio();
    _setLeftToRemainWidthRatio();
  }

  _notifyMove(double x, double y) {
    widget._log.log("移动 X:$x Y:$y");
    for (var element in widget._listener) {
      element.moveListener?.call(Point(x, y));
    }
  }

  _notifyMoveEnd(double x, double y) {
    widget._log.log("移动结束 X:$x Y:$y");
    for (var element in widget._listener) {
      element.moveEndListener?.call(Point(x, y));
    }
  }

  _notifyDown(double x, double y) {
    widget._log.log("按下 X:$x Y:$y");
    for (var element in widget._listener) {
      element.downListener?.call(Point(x, y));
    }
  }

  _notifyUp(double x, double y) {
    widget._log.log("抬起 X:$x Y:$y");
    for (var element in widget._listener) {
      element.upListener?.call(Point(x, y));
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
