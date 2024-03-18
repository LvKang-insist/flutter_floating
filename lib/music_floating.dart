import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_floating/AnimationHelper.dart';
import 'package:flutter_floating/floating/assist/Point.dart';
import 'package:flutter_floating/floating/listener/event_listener.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';

///悬浮窗内部动画，非必要无需修改
class MusicFloat extends StatefulWidget {
  final String floatingKey;

  //头像
  final Widget child;
  final double childWidth;
  final double childHeight;

  //关闭按钮
  final Widget close;
  final double closeWidth;
  final double closeHeight;

  //间距
  final double space;

  const MusicFloat(
      {Key? key,
      required this.floatingKey,
      required this.child,
      required this.close,
      this.childWidth = 50,
      this.childHeight = 50,
      this.closeHeight = 20,
      this.closeWidth = 20,
      this.space = 5})
      : super(key: key);

  @override
  State<MusicFloat> createState() => _MusicFloatState();
}

class _MusicFloatState extends State<MusicFloat> with TickerProviderStateMixin {
  /// 0，左边  1，右边   2，回弹左边  3，回弹右边
  var stateType = -1;

  AnimationController? _controller;

  ///
  Animation<Decoration>? _animation;
  Animation<double>? _animationWidth;

  //内部宽高度
  double width = 100;

  //内部动画时间
  int duration = 150;

  //外部动画时间
  int startBoxDur = 1200;
  int endBoxDur = 50;

  //当前位置，0左边，1右边，默认为1
  int currentType = 1;

  @override
  void initState() {
    super.initState();
    width = widget.space +
        widget.childWidth +
        widget.space +
        widget.closeWidth +
        widget.space * 2;
    var floating = floatingManager.getFloating(widget.floatingKey);
    var listener = FloatingEventListener();
    floating.addFloatingListener(listener);
    var _controller = getAnimController();

    ///初始化位置
    _animation = (currentType == 0
            ? AnimationHelper.leftToCenter()
            : AnimationHelper.rightToCenter())
        .animate(_controller);
    _animationWidth =
        Tween<double>(begin: width, end: widget.childWidth + widget.space * 2)
            .animate(_controller)
          ..addListener(() {
            setState(() {});
          });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });
    listener
      ..moveListener = (Point e, type) {
        if (stateType != 0 && stateType != 1) {
          //左边
          if (type == 0) {
            stateType = 0;
            setAnimState();
          }
          //右边
          if (type == 1) {
            stateType = 1;
            setAnimState();
          }
        }
      }
      ..moveEndListener = (e, type) {
        //左边
        if (type == 0) {
          stateType = 2;
          setAnimState();
        }
        //右边
        if (type == 1) {
          stateType = 3;
          setAnimState();
        }
      };
  }

  reset() {
    _controller = null;
    // _controllerBox = null;
    _animation = null;
    // _animationBox = null;
    _animationWidth = null;
  }

  AnimationController getAnimController() {
    return AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration),
    );
  }

  AnimationController getBoxAnimController(int duration) {
    return AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration),
    );
  }

  setAnimState() {
    // reset();
    _controller = getAnimController();
    switch (stateType) {
      case 0:
        {
          _animation = AnimationHelper.leftToCenter().animate(_controller!)
            ..addListener(() {
              setState(() {});
            });
          _animationWidth = Tween<double>(
                  begin: width, end: widget.childWidth + widget.space * 2)
              .animate(_controller!)
            ..addListener(() {
              setState(() {});
            });
          break;
        }
      case 1:
        {
          _animation = AnimationHelper.rightToCenter().animate(_controller!)
            ..addListener(() {
              setState(() {});
            });
          _animationWidth = Tween<double>(
                  begin: width, end: widget.childWidth + widget.space * 2)
              .animate(_controller!)
            ..addListener(() {
              setState(() {});
            });
          break;
        }
      case 2:
        {
          currentType = 0;
          _animation = AnimationHelper.centerToLeft().animate(_controller!)
            ..addListener(() {
              setState(() {});
            });
          _animationWidth = Tween<double>(
                  begin: widget.childWidth + widget.space * 2, end: width)
              .animate(_controller!)
            ..addListener(() {
              setState(() {});
            });
          break;
        }
      case 3:
        {
          currentType = 1;
          _animation = AnimationHelper.centerToRight().animate(_controller!)
            ..addListener(() {
              setState(() {});
            });
          _animationWidth = Tween<double>(
                  begin: widget.childWidth + widget.space * 2, end: width)
              .animate(_controller!)
            ..addListener(() {
              setState(() {});
            });
          break;
        }
    }
    setState(() {
      _controller?.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: duration),
      width: _animationWidth!.value,
      height: widget.childHeight + widget.space * 2,
      child: DecoratedBoxTransition(
        decoration: _animation!,
        child: Stack(children: [
          Positioned(
            left: currentType == 0 ? null : widget.space,
            right: currentType == 1 ? null : widget.space,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: widget.childWidth,
              height: widget.childHeight,
              child: widget.child,
            ),
          ),
          if (stateType != 0 && stateType != 1)
            Positioned(
                child: UnconstrainedBox(
                  child: SizedBox(
                      child: widget.close,
                      width: widget.closeWidth,
                      height: widget.closeHeight),
                ),
                left: currentType == 1
                    ? widget.childWidth + widget.space * 2
                    : null,
                right: currentType == 0
                    ? widget.childWidth + widget.space * 2
                    : null,
                top: 0,
                bottom: 0)
        ]),
      ),
    );
  }
}
