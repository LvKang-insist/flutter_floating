import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// @name：AnimationHelper
/// @package：
/// @author：345 QQ:1831712732
/// @time：2023/12/10 17:11
/// @des：

class AnimationHelper {
  static DecorationTween leftToCenter() {
    /// 从左边到中间
    return DecorationTween(
      begin: BoxDecoration(
        color: const Color(0xFFC6D4D4),
        border: Border.all(style: BorderStyle.none),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            bottomLeft: Radius.circular(0),
            topRight: Radius.circular(100),
            bottomRight: Radius.circular(100)),
      ),
      end: BoxDecoration(
        color: const Color(0xFFC6D4D4),
        border: Border.all(style: BorderStyle.none),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            bottomLeft: Radius.circular(100),
            topRight: Radius.circular(100),
            bottomRight: Radius.circular(100)),
      ),
    );
  }

  ///从右边到中间
  static DecorationTween rightToCenter() {
    /// 在两种不同的装饰属性中变换，从圆形变成方形，红色变成白色背景，无阴影变成有阴影
    return DecorationTween(
      begin: BoxDecoration(
        color: const Color(0xFFC6D4D4),
        border: Border.all(style: BorderStyle.none),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            bottomLeft: Radius.circular(100),
            topRight: Radius.circular(0),
            bottomRight: Radius.circular(0)),
      ),
      end: BoxDecoration(
        color: const Color(0xFFC6D4D4),
        border: Border.all(style: BorderStyle.none),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            bottomLeft: Radius.circular(100),
            topRight: Radius.circular(100),
            bottomRight: Radius.circular(100)),
      ),
    );
  }

  ///从中间到左边
  static DecorationTween centerToLeft() {
    /// 在两种不同的装饰属性中变换，从圆形变成方形，红色变成白色背景，无阴影变成有阴影
    return DecorationTween(
      begin: BoxDecoration(
        color: const Color(0xFFC6D4D4),
        border: Border.all(style: BorderStyle.none),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            bottomLeft: Radius.circular(100),
            topRight: Radius.circular(100),
            bottomRight: Radius.circular(100)),
      ),
      end: BoxDecoration(
        color: const Color(0xFFC6D4D4),
        border: Border.all(style: BorderStyle.none),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            bottomLeft: Radius.circular(0),
            topRight: Radius.circular(100),
            bottomRight: Radius.circular(100)),
      ),
    );
  }

  ///从中间到右边
  static DecorationTween centerToRight() {
    /// 在两种不同的装饰属性中变换，从圆形变成方形，红色变成白色背景，无阴影变成有阴影
    return DecorationTween(
      begin: BoxDecoration(
        color: const Color(0xFFC6D4D4),
        border: Border.all(style: BorderStyle.none),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            bottomLeft: Radius.circular(100),
            topRight: Radius.circular(100),
            bottomRight: Radius.circular(100)),
      ),
      end: BoxDecoration(
        color: const Color(0xFFC6D4D4),
        border: Border.all(style: BorderStyle.none),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            bottomLeft: Radius.circular(100),
            topRight: Radius.circular(0),
            bottomRight: Radius.circular(0)),
      ),
    );
  }
}
