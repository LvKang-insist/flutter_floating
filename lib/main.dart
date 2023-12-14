import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/floating_demo.dart';
import 'package:flutter_floating/floating_icon.dart';
import 'package:flutter_floating/floating_scroll.dart';
import 'button_widget.dart';
import 'floating/assist/floating_slide_type.dart';
import 'floating/assist/slide_stop_type.dart';
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

  @override
  void initState() {
    super.initState();
  }

  void _startOpen() {
    floatingManager.closeAllFloating();
    var top =MediaQuery.of(context).padding.top;
    floatingOne = floatingManager.createFloating(
        "1",
        Floating(Demo(),
            slideType: FloatingSlideType.onRightAndBottom,
            isShowLog: false,
            isSnapToEdge: true,
            isPosCache: true,
            moveOpacity: 1,
            slideTopHeight: top,
            bottom: 100));
    floatingOne.open(context);
  }

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
              ButtonWidget("跳转播放器", () =>  _startCustomPage()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startOpen,
        tooltip: 'Increment',
        child: const Text("打开"),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _startCustomPage() {
    floatingOne.hideFloating();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const CustomPage();
    })).then((value) {
      floatingOne.showFloating();
    });
  }

  @override
  void dispose() {
    super.dispose();
    floatingOne.close();
  }
}
