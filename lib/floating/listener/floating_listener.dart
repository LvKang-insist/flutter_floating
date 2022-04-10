/// @name：FloatingListener
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/11 23:16
/// @des：

class FloatingListener {
  ///打开悬浮窗
  Function? openListener;

  ///关闭悬浮窗
  Function? closeListener;

  ///影藏悬浮窗
  Function? hideFloatingListener;

  ///显示悬浮窗
  Function? showFloatingListener;

  ///手指按下
  Function(double x, double y)? downListener;

  ///手指抬起
  Function(double x, double y)? upListener;

  ///手指移动
  Function(double x, double y)? moveListener;

  ///手指移动结束
  Function(double x, double y)? moveEndListener;
}
