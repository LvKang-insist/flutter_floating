
import '../floating.dart';

/// @name：floating_manager
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/11 14:50
/// @des：[Floating] 管理者

FloatingManager floatingManager = FloatingManager();

class FloatingManager {
  FloatingManager._single();

  static final FloatingManager _manager = FloatingManager._single();

  factory FloatingManager() => _manager;

  final Map<Object, Floating> _floatingCache = {};

  ///创建一个可全局管理的 [Floating]
  Floating createFloating(Object key, Floating floating) {
    bool contains = _floatingCache.containsKey(key);
    if (!contains) {
      _floatingCache[key] = floating..setLogKey(key.toString());
    }
    return _floatingCache[key]!;
  }

  ///根据 [key] 拿到对应的 [Floating]
  Floating getFloating(Object key) {
    return _floatingCache[key]!;
  }

  ///关闭 [key] 对应的 [Floating]
  closeFloating(Object key) {
    var floating = _floatingCache[key];
    floating?.close();
    _floatingCache.remove(key);
  }

  ///关闭所有的 [Floating]
  closeAllFloating() {
    _floatingCache.forEach((key, value) => value.close());
    _floatingCache.clear();
  }

  ///悬浮窗数量
  int floatingSize() {
    return _floatingCache.length;
  }
}
