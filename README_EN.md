[![pub version](https://img.shields.io/pub/v/flutter_floating?style=flat-square)](https://pub.dev/packages/flutter_floating) [![license](https://img.shields.io/github/license/kngLv/flutter_floating?style=flat-square)](LICENSE) [![pub downloads](https://img.shields.io/pub/dm/flutter_floating?style=flat-square)](https://pub.dev/packages/flutter_floating) [![stars](https://img.shields.io/github/stars/kngLv/flutter_floating?style=flat-square)](https://github.com/kngLv/flutter_floating/stargazers) [![issues](https://img.shields.io/github/issues/kngLv/flutter_floating?style=flat-square)](https://github.com/kngLv/flutter_floating/issues)

# flutter_floating

A lightweight, globally-manageable Flutter floating window component that supports dragging, edge snapping, position persistence, multi-touch interaction, and rotation/window-size adaptation. It's suitable for floating tools, quick-access shortcuts, floating players, and similar use cases.

Quick preview:

[Online demo (Web)](https://knglv.github.io/flutter_floating/web/) · It's recommended to run the `example/` app locally to explore all features.

---

## Why choose this library

- Lightweight and non-intrusive: insert a floating window into a page or the whole app using only `FloatingOverlay` or `FloatingManager`.
- Broad scenario coverage: supports snapping/elastic rebound, position caching, disabling scroll areas, multi-touch, runtime show/hide, and rotation handling.
- Easy to debug: you can enable grouped logs per floating window to inspect position and event flows.

## Install in one line

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_floating: ^1.1.0
```

Then run:

```bash
flutter pub get
```

## Key features (by scenario)

- Global / per-page modes: manage multiple floating windows globally with `FloatingManager`, or insert a floating widget inside a page's `Stack` for local usage.
- Flexible snapping and rebound: configure snap direction, snap distance (supports negative values to move partly off-screen), snap speed, and automatic snapping on release.
- Position control and persistence: change offsets programmatically and enable/disable position caching.
- Rich event callbacks: press/move/up/move-end/open/close callbacks for analytics or custom interactions.
- Configurable draggability and hide/show strategies: toggle draggability at runtime, hide or show dynamically, and adapt during animations.
- Manual runtime control: set offsets, set snapping edges, or switch snap edges on the fly.
- Disabled drag regions: mark the top/bottom or a custom area as non-draggable.
- Rotation and window-change adaptation: keep positions sensible during rotation or window size changes.

## Quick start (minimal examples)

### Global floating

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

// Close
floating.close();

// Dispose
floating.dispose();
```


### Per-page usage

Create and open a floating widget inside a page's widget tree:

```dart
late FloatingOverlay floating = FloatingOverlay(
  const FloatingIcon(),
  slideType: FloatingEdgeType.onRightAndTop,
  right: -20,
  params: FloatingParams(snapToEdgeSpace: -20),
  top: 100,
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

## Global creation and management

```dart
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

// Get
floatingManager.getFloating("key_1");
// Close
floatingManager.closeFloating("key_1");
// Dispose
floatingManager.disposeFloating("key_1");
// ...
```

See the `example/` folder for more usage examples.

## API quick index

- [`FloatingOverlay`](https://github.com/kngLv/flutter_floating/blob/master/lib/floating/floating_overlay.dart): A per-page floating wrapper—entry point for creating/opening/closing/positioning a single floating widget (great for local usage).
- [`FloatingManager`](https://github.com/kngLv/flutter_floating/blob/master/lib/floating/manager/floating_manager.dart): Global manager for creating, retrieving, closing, and disposing global floating windows (managed by key).
- [`FloatingCommonController`](https://github.com/kngLv/flutter_floating/blob/master/lib/floating/control/floating_common_controller.dart): A common controller providing show/hide, move, set position, snapping, and animation APIs for programmatic control.
- [`FloatingParams`](https://github.com/kngLv/flutter_floating/blob/master/lib/floating/assist/floating_common_params.dart): Configuration parameters for snapping, persistence, opacity, margins, rebound, draggability, etc.
- [`FloatingListener`](https://github.com/kngLv/flutter_floating/blob/master/lib/floating/listener/event_listener.dart): Container for event callbacks so you can register multiple listeners as an object.

Example: adding a listener

```text
var listener = FloatingEventListener()
  ..openListener = () => print('open')
  ..closeListener = () => print('close')
  ..downListener = (x, y) => print('down: \$x,\$y')
  ..moveListener = (x, y) => print('move: \$x,\$y')
  ..upListener = (x, y) => print('up: \$x,\$y')
  ..moveEndListener = (x, y) => print('move end: \$x,\$y');

floatingOne.addFloatingListener(listener);
```

## Running the example (locally)

1. Clone the repo and open the `example/` folder:

```bash
git clone https://github.com/kngLv/flutter_floating.git
cd flutter_floating/example
flutter pub get
flutter run -d <device>
```

2. Online demo (Web): https://knglv.github.io/flutter_floating/web/


## Frequently Asked Questions

- Chinese FAQ: [QA.md](QA.md)
- English FAQ: [QA_EN.md](QA_EN.md)

## Compatibility

- Flutter >= 2.10 (see `pubspec.yaml` for exact environment settings)
- Supported platforms: Android / iOS / web / macOS (platform support depends on the example and platform implementation)

## Logging & debugging

Use `FloatingParams.isShowLog` when creating a floating to enable grouped logs so you can inspect behavior by floating key.

## Contributing

Issues, PRs, and example improvements are welcome. Tips:

- Include screenshots/screencasts and a minimal repro when opening an issue.
- Base PRs on the `main` branch and include a short description and a demo if possible. Update the example if behavior changes.

## Contact & license

Author: LvKang (email: lv345_y@163.com)

License: MIT (see the repository LICENSE)

---

Thanks for using `flutter_floating` — if it helped you, please give it a Star ⭐️!

