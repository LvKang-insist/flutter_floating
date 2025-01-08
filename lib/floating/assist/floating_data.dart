import 'package:flutter_floating/floating/assist/Point.dart';

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

  double snapToEdgeSpace = 0;
  Point<double>? point;

  FloatingSlideType slideType;
  bool dynamicSlideType = false;

  FloatingData(
    this.slideType, {
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.point,
    this.snapToEdgeSpace = 0,
    this.dynamicSlideType = false,
  });
}
