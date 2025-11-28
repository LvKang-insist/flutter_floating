# flutter_floating

![68747470733a2f2f67697465652e636f6d2f6c766b6e6167696e6973742f7069632d676f2d7069637572652d6265642f7261772f6d61737465722f696d616765732f32303232303231363138343530302e6a706567](https://raw.githubusercontent.com/LvKang-insist/PicGo/main/202206141432981.jpg)

一个轻量、灵活且功能完善的 Flutter 悬浮窗组件。

本库为你提供可在全局或单页面使用的悬浮窗管理与控制能力，支持拖动、吸附、回弹、位置缓存、回调监听、多指交互及屏幕旋转等常见场景。

## 安装

在你的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  flutter_floating: ^1.1.0
```

然后运行：

```bash
flutter pub get
```
## 示例

仓库自带 `example/`，包含多个使用场景.建议先运行示例查看效果与可配置项。

[在线预览](https://knglv.github.io/flutter_floating/web/)

## 主要特性

- 全局使用与单页面内使用，可插入N个悬浮窗，并全局管理
- 可配置的边缘吸附，吸附位置可选，吸附距离正值限制在内、负值允许超出、速度可调。
- 支持通过代码偏移悬浮窗位置，设置自动吸附等。
- 支持位置缓存（打开/关闭后保持位置）
- 完善的事件回调：按下、移动、抬起、打开、关闭、移动结束等
- 自适应大小与动画期间的位置适配
- 可设定禁止滑动区域（例如顶部/底部不可滑动区域）
- 支持运行时隐藏/显示，是否允许拖动，自适应屏幕旋转以及窗口大小变化等情况
- ...

## 快速开始

可通过 FloatingOverlay 创建一个通用的悬浮窗。也可以通过 floatingManager 来创建一个可以全局管理的悬浮窗。

```dart

late FloatingOverlay floating = FloatingOverlay(
  const FloatingIcon(),
  slideType: FloatingEdgeType.onRightAndTop,
  right: -20,
  params: FloatingParams(snapToEdgeSpace: -20),
  top: 100,
);
```

打开

```dart
  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    floating.open(context);
  });
}
```

关闭

```dart
floating.close()
```

销毁

```dart
floating.dispose()
```

### 页面内使用：

```dart

var floating = FloatingOverlay(
  Container(
    width: 100,
    height: 100,
    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
  ),
  slideType: FloatingEdgeType.onRightAndBottom,
  params: FloatingParams(
    isShowLog: false,
    isSnapToEdge: true,
    enablePositionCache: true,
    dragOpacity: 1,
    marginBottom: 100,
  ),
);

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [floating.getFloating()],
    ),
  );
}

@override
void dispose() {
  super.dispose();
  floating.dispose();
}
```

### 全局悬浮窗（使用 `FloatingManager` 管理）

- 创建
    ``` dart
   floatingManager.createFloating(
    "key_1",
    FloatingOverlay(
      const FloatingIcon(),
      slideType: FloatingEdgeType.onRightAndTop,
      right: -20,
      params: FloatingParams(snapToEdgeSpace: -20),
      top: 100,
    ),
  );
  ```
- 操作
    ```dart
    //获取
    floatingManager.getFloating("key_1");
    //关闭
    floatingManager.closeFloating("key_1");
    //销毁
    floatingManager.disposeFloating("key_1");
    //....
    ```
  


## 回调监听

可以为单个悬浮窗添加 `FloatingListener`，监听常见事件：

```dart
var listener = FloatingListener()
  ..openListener = () => print('open')
  ..closeListener = () => print('close')
  ..downListener = (x, y) => print('down: $x,$y')
  ..moveListener = (x, y) => print('move: $x,$y')
  ..upListener = (x, y) => print('up: $x,$y')
  ..moveEndListener = (x, y) => print('move end: $x,$y');
  ..
floatingOne.addFloatingListener(listener);
```

## 日志

创建悬浮窗时通过 `isShowLog` 控制是否打印日志。每个悬浮窗会使用不同的 key 来分组日志，便于调试。


## 贡献与联系

如果你在使用过程中发现 Bug 或有改进建议，欢迎提交 Issues 或 Pull Requests。示例与 demo 位于 `example/`
目录，阅读代码可快速上手。

作者：LvKang（邮箱：lv345_y@163.com）

许可：MIT（详见仓库 LICENSE）
