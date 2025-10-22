import 'package:flutter/material.dart';
import 'package:flutter_floating/floating_icon.dart';
import 'package:flutter_floating/test_floating/floating_scroll.dart';
import 'package:flutter_floating/page/internal_floating_page.dart';
import 'button_widget.dart';
import 'floating/assist/floating_slide_type.dart';
import 'floating/assist/slide_stop_type.dart';
import 'floating/floating.dart';
import 'floating/listener/event_listener.dart';
import 'floating/manager/floating_manager.dart';
import 'test_floating/floating_increment.dart';
import 'page/page.dart';

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
            slideType: FloatingSlideType.onRightAndBottom,
            isShowLog: false,
            isSnapToEdge: false,
            isPosCache: true,
            moveOpacity: 1,
            left: 100,
            bottom: 100,
            slideBottomHeight: 100));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      floatingOne.open(context);
    });
    floatingTwo = floatingManager.createFloating(
        "2",
        Floating(
          const FloatingScroll(),
          slideType: FloatingSlideType.onPoint,
          isShowLog: false,
          right: 50,
          isSnapToEdge: true,
          snapToEdgeSpace: 50,
          top: 100,
          slideStopType: SlideStopType.slideStopAutoType,
        ));
    var twoListener = FloatingEventListener()
      ..closeListener = () {
        // var point = floatingTwo.getFloatingPoint();
        // print('关闭  ${point.x}      --         ${point.y}');
      }
      ..hideFloatingListener = () {
        // var point = floatingTwo.getFloatingPoint();
        // print('隐藏  ${point.x}      --         ${point.y}');
      }
      ..moveEndListener = (point) {
        // var point = floatingTwo.getFloatingPoint();
        // print('移动结束  ${point.x}      --         ${point.y}');
      };
    floatingTwo.addFloatingListener(twoListener);
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
                  floating.isShowing ? floating.close() : floating.open(context);
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
              ButtonWidget("添加没有透明度动画的悬浮窗", () {
                floatingManager
                    .createFloating(
                        DateTime.now().millisecondsSinceEpoch,
                        Floating(const FloatingIcon(),
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
                        'test_slide_floating',
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
              ButtonWidget("页面内悬浮窗", () => _startInternalFollowPage()),
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
