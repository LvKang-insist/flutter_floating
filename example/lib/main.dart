import 'package:example/button_widget.dart';
import 'package:example/game.dart';
import 'package:example/page/internal_floating_page.dart';
import 'package:example/page/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating/flutter_floating.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'common.dart';
import 'floating_icon.dart';

void main() => runApp(GetMaterialApp(home: const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: globalKey,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Floating'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 late FloatingOverlay floating = floatingManager.createFloating(
    "key_1",
    FloatingOverlay(
      const FloatingIcon(),
      slideType: FloatingEdgeType.onRightAndTop,
      right: -20,
      params: FloatingParams(snapToEdgeSpace: -20),
      top: 100,
    ),
  );
  late FloatingCommonController controller = floating.controller;

  var canDrag = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      floating.open(context);
    });
  }

  void _startCustomPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const CustomPage();
    }));
  }

  void _startInternalFollowPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const InternalFloatingPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            ButtonWidget(
              text: "显示/关闭悬浮窗",
              callback: () {
                var floating = floatingManager.getFloating("key_1");
                floating.isShowing ? floating.close() : floating.open(context);
              },
            ),
            ButtonWidget(text: "跳转页面", callback: () => _startCustomPage()),
            ButtonWidget(text: "页面内悬浮窗", callback: () => _startInternalFollowPage()),
            Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    ButtonWidget(
                      text: '打开/关闭',
                      callback: () =>
                          floating.isShowing ? floating.close() : floating.open(context),
                    ),
                    ButtonWidget(
                      text: '显示/隐藏',
                      callback: () => floating.isHidden ? floating.show() : floating.hide(),
                    ),
                    ButtonWidget(
                      text: '允许拖动开/关',
                      callback: () => {
                        canDrag = !canDrag,
                        controller.setDragEnable(canDrag),
                      },
                    )
                  ],
                )),
                buildGameControllerWidget(),
                Expanded(
                    child: Column(
                  children: [
                    ButtonWidget(
                      text: '放大/缩小',
                      callback: () {
                        var v = com.wh.value == 100 ? 150.0 : 100.0;
                        controller.setWAndH(v, v);
                        com.wh.value = v;
                      },
                    ),
                    ButtonWidget(
                      text: '吸边距离修改',
                      callback: () async {
                        var space = await controller.getSnapToEdgeSpace();
                        if (space > 60) {
                          controller.setSnapToEdgeSpace(-30);
                        } else {
                          controller.setSnapToEdgeSpace(space + 15);
                        }
                      },
                    ),
                    ButtonWidget(
                      text: '吸边距离切换',
                      callback: () {
                        controller.scrollSnapToEdgeSpaceToggle();
                      },
                    ),
                  ],
                )),
              ],
            )
          ],
        ));
  }

  GameControllerWidget buildGameControllerWidget() {
    return GameControllerWidget(
      size: 180,
      onCenter: () => controller.autoSnapEdge(),
      onDown: () => controller.scrollBy(0, 30),
      onUp: () => controller.scrollBy(0, -30),
      onLeft: () => controller.scrollBy(-30, 0),
      onRight: () => controller.scrollBy(30, 0),
      onDownLeft: () => controller.scrollBy(-30, 30),
      onDownRight: () => controller.scrollBy(30, 30),
      onUpLeft: () => controller.scrollBy(-30, -30),
      onUpRight: () => controller.scrollBy(30, -30),
      onDownDoubleTap: () => controller.scrollBottom(50),
      onUpDoubleTap: () => controller.scrollTop(50),
      onLeftDoubleTap: () => controller.scrollLeft(50),
      onRightDoubleTap: () => controller.scrollRight(50),
      onDownLeftDoubleTap: () => controller.scrollBottomLeft(50, 50),
      onDownRightDoubleTap: () => controller.scrollBottomRight(50, 50),
      onUpLeftDoubleTap: () => controller.scrollTopLeft(50, 50),
      onUpRightDoubleTap: () => controller.scrollTopRight(50, 50),
    );
  }

  @override
  void dispose() {
    floatingManager.getFloating("key_1").dispose();
    floating.dispose();
    super.dispose();
  }
}
