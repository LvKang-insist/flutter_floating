import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';

import 'floating/assist/floating_slide_type.dart';
import 'floating/floating.dart';
import 'floating_increment.dart';
import 'main.dart';

/// @name：page
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/16 22:27
/// @des：

class CustomPage extends StatefulWidget {
  const CustomPage({Key? key}) : super(key: key);

  @override
  _CustomPageState createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  late Floating floating;

  @override
  void initState() {
    super.initState();
    floating = Floating(const FloatingIncrement(),
        slideType: FloatingSlideType.onLeftAndTop,
        left: 0,
        top: 150,
        isShowLog: false,
        slideBottomHeight: 100);
    floating.open(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("功能页面"),
      ),
      body: Container(
        child: GestureDetector(
          child: const Text(
            "关闭悬浮窗",
            style: TextStyle(fontSize: 30),
          ),
          onTap: () {
            floatingManager.getFloating("1").close();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
