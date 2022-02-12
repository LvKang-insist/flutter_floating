/// @name：FloatingListener
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/11 23:16
/// @des：

class FloatingListener {
  Function? showListener;
  Function? closeListener;
  Function? hideFloatingListener;
  Function? showFloatingListener;
  Function(double x, double y)? downListener;
  Function(double x, double y)? upListener;
  Function(double x, double y)? moveListener;
  Function(double x, double y)? moveEndListener;
}
