import 'package:example/button_widget.dart';
import 'package:example/page/internal_floating_page.dart';
import 'package:example/page/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/assist/floating_common_params.dart';
import 'package:flutter_floating/floating/assist/floating_edge_type.dart';
import 'package:flutter_floating/floating/floating.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';
import 'floating_icon.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Floating floatingOne = floatingManager.createFloating(
    "1",
    Floating(
      const FloatingIcon(),
      slideType: FloatingEdgeType.onRightAndBottom,
      left: 0,
      params: FloatingParams(
        snapToEdgeSpace: 30,
      ),
      bottom: 100,
    ),
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      floatingOne.open(context);
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
  }
}
