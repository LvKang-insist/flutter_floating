
import 'package:flutter/cupertino.dart';
import '../assist/Point.dart';

abstract class FloatingBase {
  Widget getFloating();

  Point<num> getFloatingPoint();
}
