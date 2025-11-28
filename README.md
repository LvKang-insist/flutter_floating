[![CI](https://img.shields.io/github/actions/workflow/status/kngLv/flutter_floating/flutter.yml?branch=main&style=flat-square)](https://github.com/kngLv/flutter_floating/actions) [![pub version](https://img.shields.io/pub/v/flutter_floating?style=flat-square)](https://pub.dev/packages/flutter_floating) [![license](https://img.shields.io/github/license/kngLv/flutter_floating?style=flat-square)](LICENSE)
[![stars](https://img.shields.io/github/stars/kngLv/flutter_floating?style=flat-square)](https://github.com/kngLv/flutter_floating/stargazers) [![issues](https://img.shields.io/github/issues/kngLv/flutter_floating?style=flat-square)](https://github.com/kngLv/flutter_floating/issues) [![pub downloads](https://img.shields.io/pub/dm/flutter_floating?style=flat-square)](https://pub.dev/packages/flutter_floating) [![platforms](https://img.shields.io/badge/platforms-android%20|%20ios%20|%20web%20|%20macos-blue?style=flat-square)](https://github.com/kngLv/flutter_floating)
[![release](https://img.shields.io/github/v/release/kngLv/flutter_floating?style=flat-square)](https://github.com/kngLv/flutter_floating/releases) [![last commit](https://img.shields.io/github/last-commit/kngLv/flutter_floating?style=flat-square)](https://github.com/kngLv/flutter_floating/commits) [![forks](https://img.shields.io/github/forks/kngLv/flutter_floating?style=flat-square)](https://github.com/kngLv/flutter_floating/network/members) [![pub points](https://img.shields.io/pub/points/flutter_floating?style=flat-square)](https://pub.dev/packages/flutter_floating)

# flutter_floating

一句话简介：轻量且可全局管理的 Flutter 悬浮窗组件，支持拖拽、吸附、位置缓存、多指交互与屏幕旋转适配，适合悬浮工具、快捷入口与悬浮播放器等场景。

快速预览：

[在线预览（Web Demo）](https://knglv.github.io/flutter_floating/web/)  ·  建议先运行 `example/` 查看完整示例

---

## 为什么选择本库

- 轻量无侵入：仅通过 `FloatingOverlay` 或 `FloatingManager` 即可在页面或全局插入悬浮窗。
- 场景覆盖广：支持吸附/回弹、位置缓存、禁止滑动区域、多指交互、运行时显示/隐藏与旋转适配。
- 易于调试：每个悬浮窗可开启日志分组，方便排查位置与事件问题。

## 一行安装

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  flutter_floating: ^1.1.0
```

然后运行：

```bash
flutter pub get
```

## 快速开始（最小示例）

将在页面内创建并自动打开一个悬浮窗：

```dart
late FloatingOverlay floating = FloatingOverlay(
  const FloatingIcon(),
  slideType: FloatingEdgeType.onRightAndTop,
  right: -20,
  params: FloatingParams(snapToEdgeSpace: -20),
  top: 100,
);

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    floating.open(context);
  });
}

@override
void dispose() {
  floating.dispose();
  super.dispose();
}
```

更多示例请查看仓库 `example/`。

## 主要特性（按场景说明）

- 全局/页面双模式：可通过 `FloatingManager` 全局管理多个悬浮窗，或在单页面内以 `Stack` 插入。
- 灵活吸附与回弹：可配置吸附方向、吸附距离（支持负值超出屏幕）、吸附速度与自动吸附开关。
- 位置控制与缓存：通过代码调整偏移，支持启用/禁用位置缓存（打开/关闭保持位置）。
- 完善事件回调：按下/移动/抬起/移动结束/打开/关闭等回调，便于埋点或自定义交互。
- 可配置可拖拽性与隐藏策略：运行时切换是否允许拖动、动态隐藏/显示、动画期间位置自适配。
- 禁止滑动区域支持：可指定顶部/底部或自定义区域为不可拖动区域。
- 自适应屏幕旋转与窗口变化：在旋转或窗口尺寸变化时保证位置合理。

## API 快速索引

- [`FloatingOverlay`](https://github.com/kngLv/flutter_floating/blob/master/lib/floating/floating_overlay.dart)：页面内浮窗封装，创建/打开/关闭/定位单个悬浮窗的入口（适合局部使用）。
- [`FloatingManager`](https://github.com/kngLv/flutter_floating/blob/master/lib/floating/manager/floating_manager.dart)：全局管理器，用于创建、获取、关闭和销毁全局悬浮窗（通过 key 管理）。
- [`FloatingCommonController`](https://github.com/kngLv/flutter_floating/blob/master/lib/floating/control/floating_common_controller.dart)：通用控制器，提供显示/隐藏、移动、设置位置、吸附与动画控制等 API，适合代码层面动态控制悬浮窗行为。
- [`FloatingListenerController`](https://github.com/kngLv/flutter_floating/blob/master/lib/floating/control/floating_listener_controller.dart)：事件监听控制器，方便注册/解绑按下、移动、抬起、打开、关闭等回调。
- [`FloatingParams`](https://github.com/kngLv/flutter_floating/blob/master/lib/floating/assist/floating_common_params.dart)：配置参数集合，控制吸附、缓存、透明度、边距、回弹与可拖拽性等行为。
- [`FloatingListener`](https://github.com/kngLv/flutter_floating/blob/master/lib/floating/listener/event_listener.dart)：事件回调容器，便于将多个回调以对象形式注册到悬浮窗上。
- [`FloatingCommonController` 示例`](https://github.com/kngLv/flutter_floating/blob/master/lib/floating/control/floating_common_controller.dart#L1)：在控制器源码中查看常用方法与示例用法（直接跳转到文件）。

示例：添加监听器

```text
var listener = FloatingListener()
  ..openListener = () => print('open')
  ..closeListener = () => print('close')
  ..downListener = (x, y) => print('down: \$x,\$y')
  ..moveListener = (x, y) => print('move: \$x,\$y')
  ..upListener = (x, y) => print('up: \$x,\$y')
  ..moveEndListener = (x, y) => print('move end: \$x,\$y');

floatingOne.addFloatingListener(listener);
```

## 运行示例（本地）

1. 克隆仓库并进入 `example/`：

```bash
git clone https://github.com/kngLv/flutter_floating.git
cd flutter_floating/example
flutter pub get
flutter run -d <device>
```

2. 在线预览（Web）： https://knglv.github.io/flutter_floating/web/

## 兼容性

- Flutter >= 2.10（请以 `pubspec.yaml` 中的环境为准）
- 支持平台：Android / iOS / web / macOS（取决于示例与平台实现）

## 日志与调试

创建悬浮窗时通过 `FloatingParams.isShowLog` 控制是否打印分组日志，便于按悬浮窗 key 查看行为。

## 贡献

欢迎 Issues、PR 与示例改进。建议：

- 提交 Issue 时附上截图/录屏与最小复现代码。
- PR 请基于 `main` 分支并附加简要说明与 demo（若改动行为请同步更新 example）。

## 联系与许可

作者：LvKang（邮箱：lv345_y@163.com）

许可：MIT（详见仓库 LICENSE）

---

感谢你使用 `flutter_floating`，如果它帮到了你，欢迎点个 Star ⭐️！
