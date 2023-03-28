import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          child: Text(
            '$_counter',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
