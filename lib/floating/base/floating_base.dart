
import 'package:flutter/cupertino.dart';
import '../assist/Point.dart';
import '../manager/scroll_position_manager.dart';

abstract class FloatingBase {
  Widget getFloating();

  ScrollPositionManager getScrollManager();

  Point<num> getFloatingPoint();
}
