import 'package:flutter/material.dart';
import 'package:flutter_floating/flating_play.dart';
import 'package:flutter_floating/floating_icon.dart';

import 'button_widget.dart';
import 'floating/assist/floating_slide_type.dart';
import 'floating/floating.dart';
import 'floating/listener/event_listener.dart';
import 'floating/manager/floating_manager.dart';
import 'floating_increment.dart';
import 'page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static GlobalKey<NavigatorState> globalKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: globalKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Floating'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Floating floatingOne;
  late Floating floatingTwo;

  @override
  void initState() {
    super.initState();
    
    //因为获取状态栏高度，所以延时一帧
    floatingOne = floatingManager.createFloating(
        "1",
        Floating(const FloatingIcon(),
            slideType: FloatingSlideType.onLeftAndTop,
            isShowLog: false,
            isSnapToEdge: false,
            isPosCache: true,
            moveOpacity: 1,
            left: 0,
            top: 150,
            slideBottomHeight: 100));
    var oneListener = FloatingEventListener()
      ..openListener = () {
        print('显示1');
      }
      ..closeListener = () {
        print('关闭1');
      }
      ..downListener = (x, y) {
        print('按下1');
      }
      ..upListener = (x, y) {
        print('抬起1');
      }
      ..moveListener = (x, y) {
        print('移动 $x  $y  1');
      }
      ..moveEndListener = (x, y) {
        print('移动结束 $x  $y  1');
      };
    floatingOne.addFloatingListener(oneListener);
    floatingTwo = floatingManager.createFloating(
        "2",
        Floating(
          const FloatingIncrement(),
          slideType: FloatingSlideType.onRightAndTop,
          isShowLog: false,
          right: 50,
          isSnapToEdge: true,
          top: 100,
        ));
  }

  void _startCustomPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const CustomPage();
    }));
  }

  var isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 30),
              ButtonWidget(
                "显示/关闭左上角没有回弹的悬浮窗",
                () {
                  var floating = floatingManager.getFloating("1");
                  floating.isShowing
                      ? floating.close()
                      : floating.open(context);
                },
              ),
              ButtonWidget("显示右上角悬浮窗", () {
                if (!isOpen) {
                  floatingTwo.open(context);
                  isOpen = true;
                } else {
                  floatingTwo.showFloating();
                }
              }),
              ButtonWidget("隐藏右上角悬浮窗", () {
                floatingTwo.hideFloating();
              }),
              ButtonWidget("添加没有移动动画的悬浮窗", () {
                floatingManager
                    .createFloating(
                        DateTime.now().millisecondsSinceEpoch,
                        Floating(const FloatingIncrement(),
                            slideType: FloatingSlideType.onLeftAndTop,
                            left: 0,
                            isShowLog: false,
                            isPosCache: true,
                            moveOpacity: 1,
                            top: floatingManager.floatingSize() * 80))
                    .open(context);
              }),
              ButtonWidget("添加禁止滑动到状态栏和底部的悬浮窗", () {
                floatingManager
                    .createFloating(
                        DateTime.now().millisecondsSinceEpoch,
                        Floating(const FloatingIncrement(),
                            slideType: FloatingSlideType.onRightAndBottom,
                            right: 100,
                            bottom: floatingManager.floatingSize() * 80,
                            //禁止滑动到状态栏
                            slideTopHeight: MediaQuery.of(context).padding.top,
                            slideBottomHeight: 60))
                    .open(context);
              }),
              ButtonWidget("跳转页面", () => _startCustomPage()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startCustomPage,
        tooltip: 'Increment',
        child: const Text("跳"),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    super.dispose();
    floatingTwo.close();
  }
}
