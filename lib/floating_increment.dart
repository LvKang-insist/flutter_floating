import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

/// @name：floating_increment
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/10 23:21
/// @des：

class FloatingIncrement extends StatefulWidget {
  const FloatingIncrement({Key? key}) : super(key: key);

  @override
  _FloatingIncrementState createState() => _FloatingIncrementState();
}

class _FloatingIncrementState extends State<FloatingIncrement> {
  int _counter = 0;
  double width = 50;
  double height = 50;
  double x = 10;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onTap: () => setState(() {
          if (width < 200) {
            width = width + x;
            height = height + x;
          } else {
            width = width - x;
            height = height - x;
          }
          _counter++;
        }),
        child: AnimatedContainer(
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(50)),
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 300),
          child: Marquee(
            text: '欢迎使用一键式悬浮窗组件',
            style: const TextStyle(fontWeight: FontWeight.bold),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            blankSpace: 20.0,
            velocity: 100.0,
            pauseAfterRound: const Duration(seconds: 1),
            startPadding: 10.0,
            accelerationDuration: const Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: const Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        ),
      ),
    );
  }
}
