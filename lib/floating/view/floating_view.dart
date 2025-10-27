import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../assist/floating_common_params.dart';
import '../assist/floating_data.dart';
import '../assist/floating_edge_type.dart';
import '../assist/point.dart';
import '../assist/snap_stop_type.dart';
import '../control/controller_type.dart';
import '../control/floating_common_controller.dart';
import '../control/floating_listener_controller.dart';
import '../utils/floating_log.dart';
import 'floating_scroll_mixin.dart';

/// @name：floating
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/09 22:33
/// @des：悬浮窗容器

class FloatingView extends StatefulWidget {
  final Widget child;
  final FloatingData floatingData;
  final FloatingListenerController _listenerController;
  final FloatingLog _log;
  final FloatingCommonController _commonControl;
  final FloatingParams params;

  const FloatingView(
    this.child,
    this.floatingData,
    this.params,
    this._listenerController,
    this._commonControl,
    this._log, {
    Key? key,
  }) : super(key: key);

  @override
  _FloatingViewState createState() => _FloatingViewState();
}

class _FloatingViewState extends State<FloatingView>
    with TickerProviderStateMixin, FloatingScrollMixin {
  final _floatingGlobalKey = GlobalKey();
  RenderBox? renderBox;

  late FloatingData _floatingData;

  late FloatingParams _params;

  final double _defaultWidth = 100; //默认宽度

  final double _defaultHeight = 100; //默认高度

  double _fWidth = 0; //悬浮窗宽度
  double _fHeight = 0; //悬浮窗高度

  double _parentWidth = 0; //记录屏幕或者父组件宽度
  double _parentHeight = 0; //记录屏幕或者父组件高度

  // 顶部边距与剩余高度之比
  /// _top / (_parentHeight - margeTop - margeBottom - heightInRange)
  double? _topToRemainHeightRatio;

  // 左侧边距与剩余宽度之比
  /// _left / (_parentWidth - snapToEdgeSpace * 2 - widthInRange)
  double? _leftToRemainWidthRatio;

  double _opacity = 1.0; // 悬浮组件透明度

  bool _isInitPosition = false;

  late Widget _contentWidget;

  bool isHide = false;
  StreamSubscription? _controllerSub;

  initListener() {
    // subscribe to controller commands stream (private _commands, accessible within the same library part)
    _controllerSub = widget._commonControl.commands.listen(_onControllerCommand);
  }

  // Handle commands from the controller in a single place to improve readability
  void _onControllerCommand(cmd) {
    final v = cmd.value;
    final Completer<void>? completer = cmd.completer;
    final type = cmd.type;

    switch (type) {
      case ControllerEnumType.refresh:
        refresh();
        break;

      case ControllerEnumType.setPoint:
        _completeSafely(completer, FPosition(fx, fy));
        break;

      case ControllerEnumType.setEnableHide:
        setState(() => isHide = v as bool);
        _completeSafely(completer);
        break;

      case ControllerEnumType.setDragEnable:
        setState(() => _params = _params.copyWith(isDragEnable: v as bool));
        _completeSafely(completer);
        break;

      case ControllerEnumType.scrollTime:
        scrollTimeMillis = v as int;
        break;

      case ControllerEnumType.scrollTop:
        scrollXY(fx, v as double, onComplete: () => _completeSafely(completer));
        break;

      case ControllerEnumType.scrollLeft:
        scrollXY(v as double, fy, onComplete: () => _completeSafely(completer));
        break;

      case ControllerEnumType.scrollRight:
        final targetX = _parentWidth - (v as double) - _fWidth;
        scrollXY(targetX, fy, onComplete: () => _completeSafely(completer));
        break;

      case ControllerEnumType.scrollBottom:
        final targetY = _parentHeight - (v as double) - _fHeight;
        scrollXY(fx, targetY, onComplete: () => _completeSafely(completer));
        break;

      case ControllerEnumType.scrollTopLeft:
        final ptTL = v as FPosition<double>;
        scrollXY(ptTL.x, ptTL.y, onComplete: () => _completeSafely(completer));
        break;

      case ControllerEnumType.scrollTopRight:
        final ptTR = v as FPosition<double>;
        final tx = _parentWidth - ptTR.x - _fWidth;
        scrollXY(tx, ptTR.y, onComplete: () => _completeSafely(completer));
        break;

      case ControllerEnumType.scrollBottomLeft:
        final ptBL = v as FPosition<double>;
        final ty = _parentHeight - ptBL.y - _fHeight;
        scrollXY(ptBL.x, ty, onComplete: () => _completeSafely(completer));
        break;

      case ControllerEnumType.scrollBottomRight:
        final ptBR = v as FPosition<double>;
        final txBR = _parentWidth - ptBR.x - _fWidth;
        final tyBR = _parentHeight - ptBR.y - _fHeight;
        scrollXY(txBR, tyBR, onComplete: () => _completeSafely(completer));
        break;

      default:
        // Unknown command - ignore
        break;
    }
  }

  // Safely complete a completer with optional value while swallowing exceptions (keeps previous behavior)
  void _completeSafely(Completer<void>? completer, [dynamic value]) {
    try {
      if (completer == null) return;
      if (value != null) {
        // If a value is provided, try to complete with it
        // Note: original code completed with a FPosition in setPoint case
        completer.complete(value);
      } else {
        completer.complete();
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _floatingData = widget.floatingData;
    _params = widget.params;
    initScrollAnim();
    initListener();
    _contentWidget = _content();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setParentSize();
      _setFloatingSize();
      setState(() => initFloatingPosition());
      _setPositionToRemainRatio();
    });
  }

  @override
  handlerSaveCacheDataAndNotify(double x, double y) {
    setState(() {
      _saveCacheData(x, y);
      _notifyMove(x, y);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: fx,
          top: fy,
          child: AnimatedOpacity(
              opacity: _opacity,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 200),
              child: Offstage(
                offstage: isHide,
                child: OrientationBuilder(builder: (context, orientation) {
                  _checkParentSizeChange();
                  return Opacity(child: _contentWidget, opacity: _isInitPosition ? 1 : 0);
                }),
              )),
        )
      ],
    );
  }

  _content() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _notifyDown(fx, fy),
      onTapCancel: () => _notifyUp(fx, fy),
      //滑动
      onPanUpdate: (DragUpdateDetails details) {
        if (!_checkStartScroll()) return;
        fx += details.delta.dx;
        fy += details.delta.dy;
        if (_opacity != _params.dragOpacity) _opacity = _params.dragOpacity;
        _changePosition();
        _notifyMove(fx, fy);
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
              if (notification is SizeChangedLayoutNotification) {
                _checkFloatingSizeChange();
              }
              return false;
            },
            child: SizeChangedLayoutNotifier(child: widget.child)),
      ),
    );
  }

  ///检测是否开启滑动
  bool _checkStartScroll() => _params.isDragEnable;

  ///初始位置计算
  initFloatingPosition() {
    if (_params.enablePositionCache && (_floatingData.top != null && _floatingData.left != null)) {
      _setCacheData();
      _isInitPosition = true;
      return;
    }
    void _topInit() => fy = _floatingData.top ?? _params.marginTop;

    void _leftInit() => fx = _floatingData.left ?? _params.snapToEdgeSpace;

    void _rightInit() =>
        fx = _parentWidth - (_floatingData.right ?? _params.snapToEdgeSpace) - _fWidth;

    void _bottomInit() =>
        fy = _parentHeight - (_floatingData.bottom ?? _params.marginBottom) - _fHeight;

    switch (_floatingData.slideType) {
      case FloatingEdgeType.onLeftAndTop:
        _topInit();
        _leftInit();
        break;
      case FloatingEdgeType.onLeftAndBottom:
        _leftInit();
        _bottomInit();
        break;
      case FloatingEdgeType.onRightAndTop:
        _rightInit();
        _topInit();
        break;
      case FloatingEdgeType.onRightAndBottom:
        _rightInit();
        _bottomInit();
        break;
      case FloatingEdgeType.onPoint:
        fy = _floatingData.position?.y ?? _params.marginBottom;
        fx = _floatingData.position?.x ?? _params.snapToEdgeSpace;
        break;
    }
    _saveCacheData(fx, fy);
    _isInitPosition = true;
  }

  ///判断屏幕尺寸变化
  _checkParentSizeChange() {
    //如果屏幕宽高为0，直接退出
    if (_parentWidth == 0 || _parentHeight == 0) return;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if (width != _parentWidth || height != _parentHeight) {
      _parentWidth = width;
      _parentHeight = height;
      setState(() => _calcNewPositionByRatio());
      _saveCacheData(fx, fy);
    }
  }

  ///边界判断
  _changePosition() {
    var type = _floatingData.slideType;
    //定义左右边界；
    List<double> leftBorder = [0, _parentWidth - _fWidth];

    // <0 表示允许超出边界外移动, >0且未开启吸附表示限制在边界内移动
    if (_params.snapToEdgeSpace < 0 || !_params.isSnapToEdge) {
      leftBorder[0] += _params.snapToEdgeSpace;
      leftBorder[1] -= _params.snapToEdgeSpace;
    }
    // 处理无法移动的情况
    if (leftBorder[1] < leftBorder[0]) {
      if (type == FloatingEdgeType.onRightAndBottom || type == FloatingEdgeType.onRightAndTop) {
        leftBorder[0] = leftBorder[1];
      } else {
        leftBorder[1] = leftBorder[0];
      }
    }
    fx = max(leftBorder[0], min(leftBorder[1], fx));
    //定义一个上边界
    List<double> topBorder = [_params.marginTop, _parentHeight - _fHeight - _params.marginBottom];
    // 处理无法移动的情况
    if (topBorder[1] < topBorder[0]) {
      if (type == FloatingEdgeType.onRightAndBottom || type == FloatingEdgeType.onLeftAndBottom) {
        topBorder[0] = topBorder[1];
      } else {
        topBorder[1] = topBorder[0];
      }
    }
    fy = max(topBorder[0], min(topBorder[1], fy));
    setState(() {
      _saveCacheData(fx, fy);
    });
  }

  ///中线回弹动画
  _animateMovePosition() {
    if (!_params.isSnapToEdge) {
      _recoverOpacity();
      _saveCacheData(fx, fy);
      _setPositionToRemainRatio();
      _notifyMoveEnd(fx, fy);
      return;
    }
    double toPositionX = 0;
    double needMoveLength = 0;

    void _setPositionToLeft() {
      needMoveLength = fx; //靠左边的距离
      toPositionX = 0 + _params.snapToEdgeSpace; //回到左边缘距离
    }

    void _setPositionToRight() {
      needMoveLength = (_parentWidth - fx - _fWidth); //靠右边的距离
      toPositionX = _parentWidth - _fWidth - _params.snapToEdgeSpace; //回到右边缘距离
    }

    switch (_params.snapEdgeType) {
      case SnapEdgeType.snapEdgeLeft:
        _setPositionToLeft();
        break;
      case SnapEdgeType.snapEdgeRight:
        _setPositionToRight();
        break;
      case SnapEdgeType.snapEdgeAuto:
        double centerX = fx + _fWidth / 2.0; //中心点位置
        (centerX < _parentWidth / 2) ? _setPositionToLeft() : _setPositionToRight();
        break;
    }

    //根据滑动距离计算滑动时间
    double parent = (needMoveLength / (_parentWidth / 2.0));
    int time = (_params.snapToEdgeSpeed * parent).ceil();

    //执行动画
    animationSlide(fx, toPositionX, time, () {
      //恢复透明度
      _recoverOpacity();
      _setPositionToRemainRatio();
      _saveCacheData(fx, fy);
      //结束后进行通知
      _notifyMoveEnd(fx, fy);
    });
  }

  refresh() {
    //停止后靠边操作
    // _animateMovePosition();
  }

  ///恢复透明度
  _recoverOpacity() {
    if (_opacity != 1.0) {
      setState(() => _opacity = 1.0);
    }
  }

  /// 当外尺寸变化时，需重新计算坐标，以使悬浮窗尽可能显示
  _calcNewPositionByRatio() {
    _calcNewTopByRatio();
    _calcNewLeftByRatio();
  }

  _calcNewLeftByRatio() {
    void setBySlide() {
      if (_floatingData.slideType == FloatingEdgeType.onRightAndBottom ||
          _floatingData.slideType == FloatingEdgeType.onRightAndTop) {
        fx = _parentWidth - _fWidth - _params.snapToEdgeSpace;
      } else {
        fx = _params.snapToEdgeSpace;
      }
    }

    //计算可用宽度，减去左右两侧的预留宽度（相对于 snapToEdgeSpace）
    double availableWidth = _parentWidth - _params.snapToEdgeSpace * 2;
    if (availableWidth <= 0) {
      setBySlide();
      if (_params.isSnapToEdge) _calcNewLeftWhenSnapToEdge();
      return;
    }
    double widthInRange = min(availableWidth, _fWidth);
    double remainWidth = availableWidth - widthInRange;
    if (remainWidth <= 0) {
      setBySlide();
    } else {
      // left position should be offset from snapToEdgeSpace
      fx = _params.snapToEdgeSpace + (_leftToRemainWidthRatio ?? 0) * remainWidth;
    }
    if (_params.isSnapToEdge) _calcNewLeftWhenSnapToEdge();
  }

  /// 处理吸附在左右两侧的情况
  _calcNewLeftWhenSnapToEdge() {
    _slideLeft() => fx = _params.snapToEdgeSpace;

    _slideRight() => fx = _parentWidth - _fWidth - _params.snapToEdgeSpace;

    switch (_params.snapEdgeType) {
      case SnapEdgeType.snapEdgeLeft:
        _slideLeft();
        break;
      case SnapEdgeType.snapEdgeRight:
        _slideRight();
        break;
      case SnapEdgeType.snapEdgeAuto:
        var centerX = _parentWidth / 2.0; //中心位置
        ((fx + _fWidth / 2) < centerX) ? _slideLeft() : _slideRight();
        break;
    }
  }

  _calcNewTopByRatio() {
    void setBySlide() {
      if (_floatingData.slideType == FloatingEdgeType.onLeftAndBottom ||
          _floatingData.slideType == FloatingEdgeType.onRightAndBottom) {
        fy = _parentHeight - _params.marginBottom - _fHeight;
      } else {
        fy = _params.marginTop;
      }
    }

    // 可用高度，减去顶部和底部的预留高度
    double availableHeight = _parentHeight - _params.marginTop - _params.marginBottom;
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
      // 根据剩余高度和距离顶部的高度比,计算新的顶部距离（加上 marginTop 偏移）
      fy = _params.marginTop + (_topToRemainHeightRatio ?? 0) * remainHeight;
    }
  }

  /// 对于进入或退出画中画(pip)，以及分屏/折叠屏/可变小窗等场景下
  /// 需要处理屏幕或父组件尺寸（暂称 外尺寸）与悬浮窗的位置问题

  /// 在保证预留距离的前提下，当外尺寸变化时，悬浮窗位置需要按比例调整，以尽量显示
  /// 即 边距 与 剩余尺寸 之比。剩余尺寸 = 外尺寸 - 预留距离 - 预留范围内的悬浮窗高度。
  /// 正常情况下，初始化、悬浮窗移动、悬浮窗尺寸变化时，调用 [_setPositionToRemainRatio]
  /// 更新时，如果剩余尺寸 ≤ 0，不计算、不改变该比例，以便外尺寸恢复时复原悬浮窗位置。
  /// 且若此时比例为空，则根据FloatingSlideType赋予初值0或1
  _setPositionToRemainRatio() {
    _setTopToRemainHeightRatio();
    _setLeftToRemainWidthRatio();
  }

  _setTopToRemainHeightRatio() {
    double initWhenNoRemainHeight() {
      switch (_floatingData.slideType) {
        case FloatingEdgeType.onLeftAndTop:
        case FloatingEdgeType.onRightAndTop:
        case FloatingEdgeType.onPoint:
          return 0;
        case FloatingEdgeType.onLeftAndBottom:
        case FloatingEdgeType.onRightAndBottom:
          return 1;
      }
    }

    // 计算可用高度，减去顶部和底部的预留高度
    double availableHeight = _parentHeight - _params.marginTop - _params.marginBottom;
    if (availableHeight <= 0) {
      //可用高度小于等于0时，设置比例为初始值
      _topToRemainHeightRatio ??= initWhenNoRemainHeight();
      return;
    }
    // 计算悬浮窗在可用高度范围内的高度（不包含 margin）
    double heightInRange = min(availableHeight, _fHeight);
    // 剩余可用高度
    double remainHeight = availableHeight - heightInRange;
    if (remainHeight <= 0) {
      //剩余高度小于等于0时，设置比例为初始值
      _topToRemainHeightRatio ??= initWhenNoRemainHeight();
    } else {
      //计算顶部距离（相对于 marginTop 的偏移）与剩余高度之比
      double offsetFromMargin = (fy - _params.marginTop).clamp(0.0, remainHeight);
      _topToRemainHeightRatio = offsetFromMargin / remainHeight;
    }
  }

  _setLeftToRemainWidthRatio() {
    double initWhenNoRemainWidth() {
      switch (_floatingData.slideType) {
        case FloatingEdgeType.onLeftAndTop:
        case FloatingEdgeType.onLeftAndBottom:
          return 0;
        case FloatingEdgeType.onRightAndTop:
        case FloatingEdgeType.onRightAndBottom:
        case FloatingEdgeType.onPoint:
          return 1;
      }
    }

    // 计算可用宽度，减去左右两侧的预留宽度（相对于 snapToEdgeSpace）
    double availableWidth = _parentWidth - _params.snapToEdgeSpace * 2;
    if (availableWidth <= 0) {
      //可用宽度小于等于0时，设置比例为初始值
      _leftToRemainWidthRatio ??= initWhenNoRemainWidth();
      return;
    }
    // 计算悬浮窗在可用宽度范围内的宽度
    double widthInRange = min(availableWidth, _fWidth);
    // 根据外部宽度和悬浮窗宽度计算剩余宽度
    double remainWidth = availableWidth - widthInRange;
    if (remainWidth <= 0) {
      //剩余宽度小于等于0时，设置比例为初始值
      _leftToRemainWidthRatio ??= initWhenNoRemainWidth();
    } else {
      //计算左侧距离（相对于 snapToEdgeSpace 的偏移）与剩余宽度之比
      double offsetFromSnap = (fx - _params.snapToEdgeSpace).clamp(0.0, remainWidth);
      _leftToRemainWidthRatio = offsetFromSnap / remainWidth;
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

  ///检测悬浮窗尺寸变化
  _checkFloatingSizeChange() {
    renderBox ??= _floatingGlobalKey.currentContext?.findRenderObject() as RenderBox?;
    var w = renderBox?.size.width ?? _defaultWidth;
    var h = renderBox?.size.height ?? _defaultHeight;
    if (w == _fWidth && h == _fHeight) return;
    _setParentSize();
    _setFloatingSize();
    setState(() {
      _setFloatingPosition();
      _setPositionToRemainRatio();
      _saveCacheData(fx, fy);
    });
  }

  _setParentSize() {
    if (_parentHeight == 0 || _parentWidth == 0) {
      _parentWidth = MediaQuery.of(context).size.width;
      _parentHeight = MediaQuery.of(context).size.height;
    }
  }

  _setFloatingSize() {
    renderBox ??= _floatingGlobalKey.currentContext?.findRenderObject() as RenderBox?;
    _fWidth = renderBox?.size.width ?? _defaultWidth;
    _fHeight = renderBox?.size.height ?? _defaultHeight;
  }

  // 悬浮窗尺寸变化时，根据起始点重新计算坐标
  _setFloatingPosition() {
    // 计算可用高度和宽度
    double availableHeight = _parentHeight - _params.marginTop - _params.marginBottom;
    double availableWidth = _parentWidth - _params.snapToEdgeSpace * 2;
    // 计算剩余高度和宽度
    double remainHeight = availableHeight - _fHeight;
    double remainWidth = availableWidth - _fWidth;
    // 无法完全显示：从起始点角落边缘开始显示
    // 可完全显示，但需要调整：从右下角边缘开始显示
    void _adjustBottom() {
      double currentBottom = _parentHeight - fy - _fHeight;
      // 需要向上调整才能完全显示
      if (currentBottom <= _params.marginBottom) {
        fy = _parentHeight - _params.marginBottom - _fHeight;
      }
    }

    void _adjustRight() {
      double currentRight = _parentWidth - fx - _fWidth;
      // 需要向左调整才能完全显示
      if (currentRight <= _params.snapToEdgeSpace) {
        fx = _parentWidth - _params.snapToEdgeSpace - _fWidth;
      }
    }

    void _topSet() => remainHeight <= 0 ? fy = _params.marginTop : _adjustBottom();

    void _bottomSet() =>
        remainHeight <= 0 ? fy = _parentHeight - _params.marginBottom - _fHeight : _adjustBottom();

    void _leftSet() {
      if (remainWidth <= 0) {
        fx = _params.snapToEdgeSpace;
      } else {
        _adjustRight();
      }
    }

    void _rightSet() {
      if (remainWidth <= 0) {
        fx = _parentWidth - _fWidth - _params.snapToEdgeSpace;
      } else {
        _adjustRight();
      }
    }

    switch (_floatingData.slideType) {
      case FloatingEdgeType.onLeftAndTop:
      case FloatingEdgeType.onPoint:
        _leftSet();
        _topSet();
        break;
      case FloatingEdgeType.onLeftAndBottom:
        _leftSet();
        _bottomSet();
        break;
      case FloatingEdgeType.onRightAndTop:
        _rightSet();
        _topSet();
        break;
      case FloatingEdgeType.onRightAndBottom:
        _rightSet();
        _bottomSet();
        break;
    }
    _saveCacheData(fx, fy);
  }

  ///保存缓存位置
  _saveCacheData(double left, double top) {
    if (_params.enablePositionCache) {
      _floatingData.left = left;
      _floatingData.top = top;
    }
  }

  ///设置缓存数据
  _setCacheData() {
    fy = _floatingData.top ?? 0;
    fx = _floatingData.left ?? 0;
  }

  @override
  void dispose() {
    _controllerSub?.cancel();
    _controllerSub = null;
    disposeScrollAnim();
    super.dispose();
  }

  _notifyMove(double x, double y) {
    widget._log.log("移动 X:$x Y:$y");
    widget._listenerController.notifyTouchMove(FPosition(x, y));
  }

  _notifyMoveEnd(double x, double y) {
    widget._log.log("移动结束 X:$x Y:$y");
    widget._listenerController.notifyTouchMoveEnd(FPosition(x, y));
  }

  _notifyDown(double x, double y) {
    widget._log.log("按下 X:$x Y:$y");
    widget._listenerController.notifyTouchDown(FPosition(x, y));
  }

  _notifyUp(double x, double y) {
    widget._log.log("抬起 X:$x Y:$y");
    widget._listenerController.notifyTouchUp(FPosition(x, y));
  }
}
