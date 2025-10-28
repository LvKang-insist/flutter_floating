import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../assist/floating_common_params.dart';
import '../assist/floating_data.dart';
import '../assist/floating_edge_type.dart';
import '../assist/fposition.dart';
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
    with TickerProviderStateMixin, FloatingScrollMixin, WidgetsBindingObserver {
  final _floatingGlobalKey = GlobalKey();
  RenderBox? renderBox;

  // 最近一次感知到的父容器/窗口尺寸，用于比较变化
  Size? _lastParentSize;

  // 尺寸变化去抖计时器（避免短时间内频繁 setState 导致性能问题）
  Timer? _resizeDebounce;

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

  // 订阅控制器命令流的订阅对象，记录为 dynamic 类型以兼容私有命令类
  StreamSubscription<dynamic>? _controllerSub;

  // 节流：移动通知上次发送时间戳（毫秒）
  int _lastNotifyAt = 0;

  // 节流间隔（毫秒），从参数中读取
  late int _notifyThrottleMs;

  // 初始化对外控制器命令的监听
  void initListener() {
    try {
      // 订阅控制器命令流，出现错误时记录日志但不抛出
      _controllerSub = widget._commonControl.commands.listen(
        _onControllerCommand,
        onError: (e, s) => widget._log.log('控制器命令流错误: $e\n$s'),
      );
    } catch (e, s) {
      // 将 stackTrace 一并记录，便于排查订阅失败原因
      widget._log.log('订阅控制器命令失败: $e\n$s');
    }
  }

  // 统一处理来自控制器的命令，减少重复代码
  void _onControllerCommand(dynamic cmd) {
    if (cmd == null) return;
    final dynamic v = cmd.value;
    final Completer<dynamic>? completer = cmd.completer as Completer<dynamic>?;
    final type = cmd.type;

    switch (type) {
      case ControllerEnumType.sizeChange:
        final size = v as FPosition<double>;
        sizeChange(size.x, size.y);
        break;

      case ControllerEnumType.getPoint:
        _completeSafely(completer, FPosition<double>(fx, fy));
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

      case ControllerEnumType.scrollBy:
        final offset = v as FPosition<double>;
        final targetX = fx + offset.x;
        final targetY = fy + offset.y;
        if (targetX < 0 ||
            targetY < 0 ||
            targetX > (_parentWidth - _fWidth) ||
            targetY > (_parentHeight - _fHeight)) {
          _completeSafely(completer);
          return;
        }
        scrollXY(targetX, targetY, onComplete: () => _completeSafely(completer));
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
        // 未知命令，忽略
        break;
    }
  }

  // 安全地完成 completer：避免重复完成导致异常
  void _completeSafely(Completer<dynamic>? completer, [dynamic value]) {
    if (completer == null) return;
    try {
      if (completer.isCompleted) return;
      if (value != null) {
        completer.complete(value);
      } else {
        completer.complete();
      }
    } catch (e) {
      // 记录完成时的异常，保持原有行为（吞掉异常）但记录方便排查
      widget._log.log('completer 完成时异常: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _floatingData = widget.floatingData;
    _params = widget.params;
    // 从参数读取节流间隔
    _notifyThrottleMs = (_params.notifyThrottleMs <= 0) ? 0 : _params.notifyThrottleMs;
    // 注册 window metrics 监听（用于捕获桌面窗口 resize / 系统 UI 变化等）
    WidgetsBinding.instance.addObserver(this);
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
  void didChangeMetrics() {
    // 在下一帧读取 MediaQuery 的 size（safe，避免在非 build 阶段直接依赖 context）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      _maybeHandleParentSize(size);
    });
  }

  // 处理父容器/窗口尺寸变化（带去抖）
  void _maybeHandleParentSize(Size newSize) {
    if (_lastParentSize != null && _lastParentSize == newSize) return;
    _lastParentSize = newSize;
    _resizeDebounce?.cancel();
    _resizeDebounce = Timer(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        _parentWidth = newSize.width;
        _parentHeight = newSize.height;
        _calcNewPositionByRatio();
        _saveCacheData(fx, fy);
      });
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
                child: LayoutBuilder(builder: (context, constraints) {
                  // 使用 constraints 或 MediaQuery 作为有效尺寸来源
                  final effectiveSize =
                      (constraints.maxWidth.isFinite && constraints.maxHeight.isFinite)
                          ? Size(constraints.maxWidth, constraints.maxHeight)
                          : MediaQuery.of(context).size;
                  // 如果检测到父尺寸发生变化，通过 post frame callback 安全地处理变化（避免在 build 中直接 setState）
                  if (_lastParentSize == null ||
                      _lastParentSize!.width != effectiveSize.width ||
                      _lastParentSize!.height != effectiveSize.height) {
                    // 在下一帧通过 _maybeHandleParentSize 执行实际的更新与 debounce。
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _maybeHandleParentSize(effectiveSize);
                    });
                  }
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
        _animateMovePosition();
      },
      //滑动取消
      onPanCancel: () {
        if (!_checkStartScroll()) return;
        _changePosition();
      },
      child: Container(
        key: _floatingGlobalKey,
        child: widget.child,
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
  ///由于 NotificationListener 监听到宽高改变是在 build 之后(即宽高已经改变才通知)，
  ///此时计算位置导致的结果是：悬浮窗会先以新宽高渲染一次，然后再跳到正确位置，体验不好。
  ///所以这里由外部在宽高改变时调用，从而避免上述问题。
  sizeChange(var newW, var newH) {
    if (newW == _fWidth && newH == _fHeight) return;
    _setParentSize();
    double oldW = _fWidth;
    double oldH = _fHeight;
    _fWidth = newW;
    _fHeight = newH;
    setState(() {
      _setFloatingPosition(oldW, oldH);
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
  _setFloatingPosition(double oldW, double oldH) {
    // 计算可用高度和宽度
    double availableHeight = _parentHeight - _params.marginTop - _params.marginBottom;
    double availableWidth = _parentWidth - _params.snapToEdgeSpace * 2;
    // 计算剩余高度和宽度
    double remainHeight = availableHeight - _fHeight;
    double remainWidth = availableWidth - _fWidth;
    // 无法完全显示：从起始点角落边缘开始显示
    // 可完全显示，但需要调整：从右下角边缘开始显示
    void _adjustBottom() {
      if (fy == _parentHeight - oldH - _params.marginBottom) {
        fy = _parentHeight - _fHeight - _params.marginBottom;
        return;
      }
      if ((fy + oldH / 2) > (_parentHeight / 2)) {
        double currentBottom = _parentHeight - fy - oldH;
        fy = _parentHeight - currentBottom - _fHeight;
        return;
      }
    }

    void _adjustRight() {
      if (fx == _parentWidth - oldW - _params.snapToEdgeSpace) {
        fx = _parentWidth - _fWidth - _params.snapToEdgeSpace;
        return;
      }
      if ((fx + oldW / 2) > (_parentWidth / 2)) {
        double currentRight = _parentWidth - fx - oldW;
        fx = _parentWidth - currentRight - _fWidth;
        return;
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
    // 移除 window metrics 监听
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    // 取消可能的 debounce 计时器
    _resizeDebounce?.cancel();
    // 取消控制器订阅，记录可能的异常
    if (_controllerSub != null) {
      try {
        _controllerSub!.cancel();
      } catch (e) {
        widget._log.log('取消控制器订阅时异常: $e');
      }
      _controllerSub = null;
    }
    disposeScrollAnim();
    super.dispose();
  }

  _notifyMove(double x, double y) {
    // 节流高频移动回调，避免外层 listener 被频繁触发导致性能问题
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastNotifyAt < _notifyThrottleMs) return;
    _lastNotifyAt = now;
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
