import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

    floating = Floating(MyApp.navigatorKey, const FloatingIncrement(),
        width: 50,
        height: 50,
        slideType: FloatingSlideType.onLeftAndTop,
        left: 0,
        top: 150,
        isShowLog: false,
        slideBottomHeight: 100);
    floating.open();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("功能页面"),
      ),
      body: Container(),
    );
  }

  @override
  void dispose() {
    floating.close();
    super.dispose();
  }
}
