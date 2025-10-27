
import 'package:flutter_floating/floating/assist/point.dart';

/// @name：FloatingListener
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/11 23:16
/// @des：

class FloatingEventListener {
  ///打开悬浮窗
  Function? openListener;

  ///关闭悬浮窗
  Function? closeListener;

  ///影藏悬浮窗
  Function? hideFloatingListener;

  ///显示悬浮窗
  Function? showFloatingListener;

  ///手指按下
  Function(FPosition<double>)? downListener;

  ///手指抬起
  Function(FPosition<double>)? upListener;

  ///手指移动
  Function(FPosition<double>)? moveListener;

  ///手指移动结束
  Function(FPosition<double>)? moveEndListener;
}
