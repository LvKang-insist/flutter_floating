
import 'package:flutter_floating/floating/assist/Point.dart';

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
  Function(Point<double>)? downListener;

  ///手指抬起
  Function(Point<double>)? upListener;

  ///手指移动
  Function(Point<double>)? moveListener;

  ///手指移动结束
  Function(Point<double>)? moveEndListener;
}
