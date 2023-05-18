# floating

![68747470733a2f2f67697465652e636f6d2f6c766b6e6167696e6973742f7069632d676f2d7069637572652d6265642f7261772f6d61737465722f696d616765732f32303232303231363138343530302e6a706567](https://raw.githubusercontent.com/LvKang-insist/PicGo/main/202206141432981.jpg)

**Floating** 是一个灵活且强大的悬浮窗解决方案



### 特性

- 全局的悬浮窗管理机制
- 支持各项回调监听，如移动、按下等
- 支持自定义是否保存悬浮窗的位置信息
- 支持单页面及全局使用，可插入 N 个悬浮窗
- 支持自定义禁止滑动区域，例如在 距离顶部 50 到底部的区域内滑动等
- 完善的日志系统，可查看不同悬浮窗对应的 Log
- 支持自定义位置方向及悬浮窗的各项指标
- 支持越界回弹，边缘自动吸附(是否吸附，吸附位置可选)，多指触摸移动，自适应屏幕旋转以及小窗口等情况
- 自适应悬浮窗大小
- 适配悬浮窗动画，对悬浮窗大小改变时位置进行适配
- 代码内可更改浮窗位置
- .....

### 打开方式

项目迁移至 flutter3.0，3.0 以下可能无法使用，请自行升级flutters SDK
```
flutter_floating: ^1.0.6 
```
#### 效果图

|                             全局                             |                             小屏                             |                           缩放屏幕                           |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| ![全屏悬浮窗](https://cdn.jsdelivr.net/gh/LvKang-insist/PicGo/202202171737802.gif) | ![小屏悬浮窗](https://cdn.jsdelivr.net/gh/LvKang-insist/PicGo/202202172155850.gif) | ![缩放屏幕](https://cdn.jsdelivr.net/gh/LvKang-insist/PicGo/202202172155135.gif) |
|                           旋转屏幕                           |                           多指滑动                           |                                                              |
| ![旋转屏幕](https://cdn.jsdelivr.net/gh/LvKang-insist/PicGo/202202171740609.gif) | ![多指滑动](https://cdn.jsdelivr.net/gh/LvKang-insist/PicGo/202202171740850.gif) |                                                              |

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

#### 可选参数

```dart
///[child]需要悬浮的 widget
///[slideType]，可参考[FloatingSlideType]
///
///[top],[left],[left],[bottom] 对应 [slideType]，
///例如设置[slideType]为[FloatingSlideType.onRightAndBottom]，则需要传入[bottom]和[right]
///
///[isPosCache]启用之后当调用之后 [Floating.close] 重新调用 [Floating.open] 后会保持之前的位置
///[isSnapToEdge]是否自动吸附边缘，默认为 true ，请注意，移动默认是有透明动画的，如需要关闭透明度动画，
///请修改 [moveOpacity]为 1
///[slideTopHeight] 滑动边界控制，可滑动到顶部的距离
///[slideBottomHeight] 滑动边界控制，可滑动到底部的距离
///[slideStopType] 移动后回弹停靠的位置 [lideStopType]
Floating(
  Widget child, {
  FloatingSlideType slideType = FloatingSlideType.onRightAndBottom,
  double? top,
  double? left,
  double? right,
  double? bottom,
  double moveOpacity = 0.3,
  bool isPosCache = true,
  bool isShowLog = true,
  bool isSnapToEdge = true,
  this.slideTopHeight = 0,
  this.slideBottomHeight = 0,
  SlideStopType slideStopType = SlideStopType.slideStopAutoType,
})
```

#### 全局悬浮窗

全局的悬浮窗通过 FloatingManager 进行管理

- 创建悬浮窗

  ```dart
    floatingOne = floatingManager.createFloating(
          "1",///key
          Floating(const FloatingIncrement(),
              slideType: FloatingSlideType.onLeftAndTop,
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
    floating = Floating(const FloatingIncrement(),
        slideType: FloatingSlideType.onLeftAndTop,
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
- [修改悬浮窗位置](https://github.com/LvKang-insist/Floating/blob/master/lib/floating/manager/scroll_position_manager.dart)



### 最后

如果您在使用过程中有任何问题可直接发送邮件`lv345_y@163.com` 或者直接提 `Issues`,也可以直接加入群聊:
![](https://raw.githubusercontent.com/LvKang-insist/PicGo/main/img/202304141420430.jpeg)
