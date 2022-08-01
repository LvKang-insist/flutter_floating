import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';

import 'floating/assist/floating_slide_type.dart';
import 'floating/floating.dart';
import 'floating_increment.dart';

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


  @override
  void initState() {
    super.initState();
  }

  // var s = Get.put(AwesomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("功能页面"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // AwesomeView(),
            GestureDetector(
              child: const Text(
                "关闭悬浮窗",
                style: TextStyle(fontSize: 30),
              ),
              onTap: () {
                floatingManager.getFloating("1").close();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// class AwesomeController extends GetxController {
//   final String title = 'My Awesome View';
// }
//
//
//
// // 一定要记住传递你用来注册控制器的`Type`!
// class AwesomeView extends GetView<AwesomeController> {
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         floatingManager
//             .createFloating(
//                 "1",
//                 Floating(const FloatingIncrement(),
//                     slideType: FloatingSlideType.onLeftAndTop,
//                     left: 0,
//                     top: 150,
//                     isShowLog: false,
//                     slideBottomHeight: 100))
//             .open(context);
//       },
//       child: Container(
//         padding: EdgeInsets.all(20),
//         child: Text(controller.title), // 只需调用 "controller.something"。
//       ),
//     );
//   }
// }
