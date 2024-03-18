/// @name：floating_demo
/// @package：
/// @author：345 QQ:1831712732
/// @time：2023/12/13 21:59
/// @des：
///

import 'package:flutter/material.dart';
import 'package:flutter_floating/import_floating.dart';

import 'music_floating.dart';

///开发者自定义悬浮窗的圆以及删除按钮
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
      close: GestureDetector(
        onTap: () {
          //删除按钮监听
          var floating = floatingManager.getFloating("1");
          if (floating.getFloatingPoint().x == 0) {
            floating.getScrollManager().scrollLeft(-100);
          } else {
            floating
                .getScrollManager()
                .scrollLeft(floating.getFloatingPoint().x + 200);
          }
          Future.delayed(const Duration(milliseconds: 310), () {
            floating.close();
          });
        },
        child: Container(
          color: Colors.black,
        ),
      ),
    );
  }
}
