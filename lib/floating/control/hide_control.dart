import 'package:flutter/material.dart';

/// @name：hide_control
/// @package：
/// @author：345 QQ:1831712732
/// @time：2022/02/11 00:27
/// @des：

class HideController {
  Function(bool isHide)? _hideControl;


  setFloatingHide(bool isHide){
    _hideControl?.call(isHide);
  }

  setHideControl(Function(bool isHide) hideControl) {
    _hideControl = hideControl;
  }
}
