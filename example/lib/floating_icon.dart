import 'package:flutter/material.dart';

/// @name：floating_icon
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/06/02 17:50
/// @des：

class FloatingIcon extends StatefulWidget {
  const FloatingIcon({Key? key}) : super(key: key);

  @override
  State<FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<FloatingIcon> {
  String curState = "初始状态";

  @override
  void initState() {
    super.initState();
    // var one = floatingManager.getFloating('1');
    // var listener = FloatingEventListener()
    //   ..openListener = () {
    //     setState(() => curState = "打开");
    //   }
    //   ..closeListener = () {
    //     setState(() => curState = "关闭");
    //   }
    //   ..hideFloatingListener = () {
    //     setState(() => curState = "隐藏");
    //   }
    //   ..showFloatingListener = () {
    //     setState(() => curState = "显示");
    //   }
    //   ..downListener = (point) {
    //     setState(() => curState = "按下 x:${point.x} -- y:${point.y}");
    //   }
    //   ..upListener = (point) {
    //     setState(() => curState = "抬起 x:${point.x} -- y:${point.y}");
    //   }
    //   ..moveListener = (point) {
    //     setState(() => curState = "移动中 x:${point.x} -- y:${point.y}");
    //   }
    //   ..moveEndListener = (point) {
    //     setState(() => curState = "移动结束 x:${point.x} -- y:${point.y}");
    //   };
    // WidgetsBinding.instance.addPostFrameCallback((v){
    //   one.addFloatingListener(listener);
    // });
  }

  @override
  Widget build(BuildContext context) {
  //   return Container(
  //     decoration: BoxDecoration(color: Colors.tealAccent, borderRadius: BorderRadius.circular(20)),
  //     height: 100,
  //     width: 100,
  //     child: Text(
  //       curState,
  //       style: const TextStyle(
  //         fontSize: 16,
  //         color: Colors.black,
  //       ),
  //     ),
  //   );
    return Container(
      color: Colors.amberAccent,
      child: const Icon(Icons.add_photo_alternate, size: 70),
    );
  }
}
