# floating

![f50c51e174e43911530beb1a8bdbbaef](https://gitee.com/lvknaginist/pic-go-picure-bed/raw/master/images/20220216184500.jpeg)

**Floating** 是一个灵活且强大的悬浮窗解决方案



### 特性

- 全局的悬浮窗管理机制
- 支持各项回调监听，如移动、按下等
- 支持自定义是否保存悬浮窗的位置信息
- 支持单页面及全局使用，可插入 N 个悬浮窗
- 支持自定义禁止滑动区域，例如在 距离顶部 50 到底部的区域内滑动等
- 完善的日志系统，可查看不同悬浮窗对应的 Log
- 支持自定义位置方向及悬浮窗的各项指标
- 支持越界回弹，多指触摸移动，自适应屏幕旋转以及小窗口等情况
- .....

### 依赖方式

.............

#### 效果图

|                             全局                             |                             小屏                             |                           缩放屏幕                           |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![69ec62dbd7cbf2ba1b35e8451969c2ef](https://cdn.jsdelivr.net/gh/LvKang-insist/PicGo/202202171737802.gif) | <img src="https://cdn.jsdelivr.net/gh/LvKang-insist/PicGo/202202171857879.gif" alt="G-空白格-2022-02-02-18.22" style="zoom:80%;" /> | ![93d3d636180fc8b3f7fb7571ed4a6cba](https://cdn.jsdelivr.net/gh/LvKang-insist/PicGo/202202171739883.gif) |
|                           旋转屏幕                           |                           多指滑动                           |                                                              |
| ![e9b163becd3371257abc9f000ab68da3](https://cdn.jsdelivr.net/gh/LvKang-insist/PicGo/202202171740609.gif) | ![051e018f2dc2f218b2dc992f74fa891c](https://cdn.jsdelivr.net/gh/LvKang-insist/PicGo/202202171740850.gif) |                                                              |

### 可自由控制的日志查看

创建悬浮窗的时候通过 `isShowLog` 属性控制，不同的悬浮窗 Log 会通过不同 key 显示出来

```dart
I/flutter (24648): Floating_Log 1 ： 按下 X:0.0 Y:150.0
I/flutter (24648): Floating_Log 1 ： 抬起 X:0.0 Y:150.0
I/flutter (24648): Floating_Log 1 ： 移动 X:0.36363636363636687 Y:150.0
I/flutter (24648): Floating_Log 1 ： 移动 X:0.36363636363636687 Y:149.63636363636363
I/flutter (24648): Floating_Log 1 ： 移动 X:0.7272727272727337 Y:149.63636363636363
I/flutter (24648): Floating_Log 1 ： 移动 X:1.0909090909091006 Y:149.27272727272725
I/flutter (24648): Floating_Log 1 ： 移动 X:1.4545454545454675 Y:149.27272727272725
I/flutter (24648): Floating_Log 1 ： 移动 X:1.4545454545454675 Y:148.90909090909088
I/flutter (24648): Floating_Log 1 ： 移动 X:0.0 Y:145.9999999999999
I/flutter (24648): Floating_Log 1 ： 移动结束 X:0.0 Y:145.9999999999999
```

```dart
I/flutter (24648): Floating_Log 1645091422285 ： 按下 X:342.72727272727275 Y:480.9090909090909
I/flutter (24648): Floating_Log 1645091422285 ： 抬起 X:342.72727272727275 Y:480.9090909090909
I/flutter (24648): Floating_Log 1645091422285 ： 移动 X:342.72727272727275 Y:480.5454545454545
I/flutter (24648): Floating_Log 1645091422285 ： 移动 X:342.72727272727275 Y:480.18181818181813
I/flutter (24648): Floating_Log 1645091422285 ： 移动 X:342.72727272727275 Y:479.81818181818176
I/flutter (24648): Floating_Log 1645091422285 ： 移动 X:342.72727272727275 Y:479.4545454545454
I/flutter (24648): Floating_Log 1645091422285 ： 移动 X:342.72727272727275 Y:479.090909090909
I/flutter (24648): Floating_Log 1645091422285 ： 移动 X:342.72727272727275 Y:478.72727272727263
```



### 使用方式

#### 初始化

```dart
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
```

#### 全局悬浮窗

全局的悬浮窗通过 FloatingManager 进行管理

- 创建悬浮窗

  ```dart
    floatingOne = floatingManager.createFloating(
          "1",///key
          Floating(MyApp._navigatorKey, const FloatingIncrement(),
              width: 50,
              height: 50,
              slideType: FloatingSlideType.onLeftAndTop,
              left: 0,
              top: 150,
              isShowLog: false,
              slideBottomHeight: 100));
  ```

- 通过 FloatingManager 获取 key 对应的悬浮窗

  ```dart
  floatingManager.getFloating("1");
  ```

- 关闭 key 对应的悬浮窗

  ```dart
  floatingManager.closeFloating("1");
  ```

- 关闭所有悬浮窗

  ```dart
  floatingManager.closeAllFloating();
  ```

- .....

#### 单悬浮窗创建

单悬浮窗可用于某个页面中，页面退出后关闭即可。

```dart
class CustomPage extends StatefulWidget {
  const CustomPage({Key? key}) : super(key: key);

  @override
  _CustomPageState createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  late Floating floating;

  @override
  void initState() {
    super.initState();

    floating = Floating(MyApp.navigatorKey, const FloatingIncrement(),
        width: 50,
        height: 50,
        slideType: FloatingSlideType.onLeftAndTop,
        left: 0,
        top: 150,
        isShowLog: false,
        slideBottomHeight: 100);
    floating.open();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("功能页面"),
      ),
      body: Container(),
    );
  }

  @override
  void dispose() {
    floating.close();
    super.dispose();
  }
}
```

#### 添加悬浮窗各项回调

```dart
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
floatingOne.addFloatingListener(oneListener);
```

### 其他使用方式

- [使用方式](https://github.com/LvKang-insist/Floating/blob/master/lib/main.dart)
- [悬浮窗对应方法](https://github.com/LvKang-insist/Floating/blob/master/lib/floating/floating.dart)
- [全局悬浮窗管理对应方法](https://github.com/LvKang-insist/Floating/blob/master/lib/floating/manager/floating_manager.dart)
