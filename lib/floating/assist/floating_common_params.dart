import 'floating_slide_type.dart';
import 'slide_stop_type.dart';

class FloatingCommonParams {
  ///是否在调用 [Floating.open] 时，保持上一次 [Floating.close] 前的位置
  bool isPosCache = true;

  ///是否自动吸附左右边缘，默认为 true
  bool isSnapToEdge = true;

  ///是否允许拖动悬浮窗，默认为 true
  bool isEnableDrag = true;

  ///是否打印日志，默认为 false
  bool isShowLog = false;

  ///拖动时的透明度，默认为 0.3
  ///请注意，移动默认是有透明动画的，如需要关闭透明度动画，请修改 [dragOpacity]为 1
  double dragOpacity = 0.3;

  ///拖动范围限制，与顶部的最小距离（可设为负数）
  double margeTop = 0;

  ///拖动范围限制，与底部的最小距离（可设为负数）
  double margeBottom = 0;

  ///吸附后回弹至与边缘的距离，不开启吸附则用于范围限制（可设为负数）
  double snapToEdgeSpace = 0;

  ///吸附边缘的速度，默认 250，越大越快
  int snapToEdgeSpeed = 250;

  ///拖动后吸附在哪一侧
  SnapEdgeType snapEdgeType = SnapEdgeType.snapEdgeAuto;



  FloatingCommonParams({
    this.isPosCache = true,
    this.isSnapToEdge = true,
    this.isEnableDrag = true,
    this.isShowLog = false,
    this.dragOpacity = 0.3,
    this.margeTop = 0,
    this.margeBottom = 0,
    this.snapToEdgeSpace = 0,
    this.snapToEdgeSpeed = 250,
    this.snapEdgeType = SnapEdgeType.snapEdgeAuto,
  });
}
