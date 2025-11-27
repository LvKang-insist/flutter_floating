import 'package:flutter/cupertino.dart';
import '../floating_overlay.dart';

/// @name：floating_manager
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/11 14:50
/// @des：[FloatingOverlay] 管理者

FloatingManager floatingManager = FloatingManager();

class FloatingManager {
  FloatingManager._single();

  static final FloatingManager _manager = FloatingManager._single();

  factory FloatingManager() => _manager;

  final Map<Object, FloatingOverlay> _floatingCache = {};

  static TransitionBuilder init({TransitionBuilder? builder}) {
    return (BuildContext context, Widget? child) {
      if (builder != null) {
        return builder(context, child);
      }
      return Container(child: child);
    };
  }

  ///创建一个可全局管理的 [FloatingOverlay]
  FloatingOverlay createFloating(Object key, FloatingOverlay floating) {
    bool contains = _floatingCache.containsKey(key);
    if (!contains) {
      _floatingCache[key] = floating;
    }
    return _floatingCache[key]!;
  }

  ///根据 [key] 拿到对应的 [FloatingOverlay]
  FloatingOverlay getFloating(Object key) {
    return _floatingCache[key]!;
  }

  ///查询 [key] 对应的 [FloatingOverlay] 是否存在
  bool containsFloating(Object key) {
    return _floatingCache.containsKey(key);
  }

  ///关闭 [key] 对应的 [FloatingOverlay]
  closeFloating(Object key) {
    var floating = _floatingCache[key];
    floating?.close();
  }

  ///关闭所有的 [FloatingOverlay]
  closeAllFloating() {
    _floatingCache.forEach((key, value) => value.close());
    _floatingCache.clear();
  }

  ///释放 [key] 对应的 [FloatingOverlay]
  disposeFloating(Object key) {
    var floating = _floatingCache[key];
    floating?.close();
    floating?.dispose();
    _floatingCache.remove(floating);
  }

  ///释放所有 [FloatingOverlay]
  disposeAllFloating() {
    _floatingCache.forEach((key, value) {
      value.close();
      value.dispose();
    });
    _floatingCache.clear();
  }

  ///悬浮窗数量
  int floatingSize() {
    return _floatingCache.length;
  }
}
