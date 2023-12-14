/// @name：floating_demo
/// @package：
/// @author：345 QQ:1831712732
/// @time：2023/12/13 21:59
/// @des：
///

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating/floating_icon.dart';

class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  @override
  Widget build(BuildContext context) {
    return MusicFloat(
      key: null,
      floatingKey: "1",
      child: Container(
        decoration:
            const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      ),
      close: const Icon(Icons.delete),
    );
  }
}
