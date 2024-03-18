import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';


///演示播放器页面
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
