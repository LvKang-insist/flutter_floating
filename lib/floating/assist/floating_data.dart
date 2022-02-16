import 'floating_slide_type.dart';

/// @name：floating_data
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/10 17:35
/// @des：悬浮窗数据记录

class FloatingData {
  double? left;

  double? top;

  double? right;

  double? bottom;

  FloatingSlideType slideType;

  FloatingData(this.slideType, {this.left, this.top, this.right, this.bottom});
}
