import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';

/// @name：page
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/16 22:27
/// @des：

class CustomPage extends StatefulWidget {
  const CustomPage({super.key});

  @override
  State<CustomPage> createState() => _CustomPageState();
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
                floatingManager.getFloating("key_1").close();
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
