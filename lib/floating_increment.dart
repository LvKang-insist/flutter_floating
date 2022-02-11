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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _counter++),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: Colors.blue, borderRadius: BorderRadius.circular(50)),
        alignment: Alignment.center,
        child: Text("$_counter",
            style: const TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }
}
