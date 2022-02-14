import 'package:floating/floating/floating.dart';
import 'package:floating/floating/enum/floating_slide_type.dart';
import 'package:floating/floating/listener/floating_listener.dart';
import 'package:floating/floating/manager/floating_manager.dart';
import 'package:floating/floating_increment.dart';
import 'package:floating/test.dart';
import 'package:flutter/material.dart';

import 'button_widget.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: _navigatorKey,
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
  @override
  void initState() {
    super.initState();
    floatingManager.createFloating(
        "1",
        Floating(MyApp._navigatorKey, const FloatingIncrement(),
            width: 50,
            height: 50,
            slideType: FloatingSlideType.onLeftAndTop,
            left: 0,
            top: 150));
    var oneListener = FloatingListener()
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
    floatingManager.getFloating("1").addFloatingListener(oneListener);
    floatingManager.createFloating(
        "2",
        Floating(MyApp._navigatorKey, const FloatingIncrement(),
            width: 50,
            height: 50,
            slideType: FloatingSlideType.onRightAndTop,
            right: 0,
            top: 150));
    var twoListener = FloatingListener()
      ..openListener = () {
        print('显示2');
      }
      ..closeListener = () {
        print('关闭2');
      };
    floatingManager.getFloating("2").addFloatingListener(twoListener);
    floatingManager.createFloating(
        "3",
        Floating(MyApp._navigatorKey, const FloatingIncrement(),
            width: 50,
            height: 50,
            slideType: FloatingSlideType.onLeftAndBottom,
            left: 0,
            bottom: 0));

    var fourListener = FloatingListener()
      ..showFloatingListener = () {
        print('显示4');
      }
      ..hideFloatingListener = () {
        print('隐藏4');
      };
    floatingManager.createFloating(
        "4",
        Floating(MyApp._navigatorKey, const FloatingIncrement(),
            width: 50,
            height: 50,
            slideType: FloatingSlideType.onRightAndBottom,
            right: 0,
            bottom: 0));
    floatingManager.getFloating("4").addFloatingListener(fourListener);
  }

  void _incrementCounter() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const FloatingIncrement();
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
                "显示/关闭左上角悬浮窗",
                () {
                  var floating = floatingManager.getFloating("1");
                  floating.isShowing ? floating.close() : floating.open();
                },
              ),
              ButtonWidget("显示/关闭右上角悬浮窗", () {
                var floating = floatingManager.getFloating("2");
                floating.isShowing ? floating.close() : floating.open();
              }),
              ButtonWidget("显示/关闭左下角悬浮窗", () {
                var floating = floatingManager.getFloating("3");
                floating.isShowing ? floating.close() : floating.open();
              }),
              ButtonWidget("显示/隐藏右下角悬浮窗", () {
                var floating = floatingManager.getFloating("4");
                if (isOpen) {
                  floating.isShowing
                      ? floating.hideFloating()
                      : floating.showFloating();
                } else {
                  floating.open();
                  isOpen = true;
                }
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Text("跳"),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
