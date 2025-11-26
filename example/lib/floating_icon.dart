import 'package:example/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/listener/event_listener.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

/// @name：floating_icon
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/06/02 17:50
/// @des：

class FloatingIcon extends StatefulWidget {
  final Function? scale;

  const FloatingIcon({super.key, this.scale});

  @override
  State<FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<FloatingIcon> {

  @override
  void initState() {
    super.initState();
    var one = floatingManager.getFloating('1');
    var listener = FloatingEventListener()
      ..openListener = () {
         com.content.value = "打开";
      }
      ..closeListener = () {
         com.content.value = "关闭";
      }
      ..hideFloatingListener = () {
         com.content.value = "隐藏";
      }
      ..showFloatingListener = () {
         com.content.value = "显示";
      }
      ..downListener = (point) {
         com.content.value = "按下 x:${point.x.toInt()}-y:${point.y.toInt()}";
      }
      ..upListener = (point) {
         com.content.value = "抬起 x:${point.x.toInt()}-y:${point.y.toInt()}";
      }
      ..moveListener = (point) {
         com.content.value = "移动中 x:${point.x.toInt()}-y:${point.y.toInt()}";
      }
      ..moveEndListener = (point) {
         com.content.value = "移动结束 x:${point.x.toInt()}-y:${point.y.toInt()}";
      };
    // WidgetsBinding.instance.addPostFrameCallback((v) {
    // });
    one.addFloatingListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        alignment: Alignment.center,
        height: com.wh.value,
        width: com.wh.value,
        decoration:
            BoxDecoration(color: Colors.tealAccent, borderRadius: BorderRadius.circular(20)),
        child: Text(
          com.content.value,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
        ),
      );
    });
  }
}
